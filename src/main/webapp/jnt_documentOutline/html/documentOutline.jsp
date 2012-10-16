<%@page import="java.io.IOException"%>
<%@page import="org.apache.pdfbox.pdmodel.interactive.documentnavigation.destination.PDDestination"%>
<%@page import="org.apache.pdfbox.pdmodel.interactive.documentnavigation.destination.PDPageDestination"%>
<%@page import="org.apache.pdfbox.pdmodel.interactive.documentnavigation.outline.PDOutlineItem"%>
<%@page import="org.apache.pdfbox.pdmodel.interactive.documentnavigation.outline.PDDocumentOutline"%>
<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="java.io.InputStream"%>
<%@page import="javax.servlet.jsp.JspWriter"%>
<%@page import="org.jahia.services.content.decorator.JCRFileContent"%>
<%@page import="org.apache.pdfbox.pdmodel.PDDocument"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<jcr:nodeProperty name="j:node" node="${currentNode}" var="docProperty"/>
<c:set var="doc" value="${not empty docProperty ? docProperty.node : null}"/>
<c:if test="${renderContext.editMode && empty doc}">
   <fmt:message key="jnt_documentPreview.noDocumentSelected"/> 
</c:if>
<c:if test="${not empty doc}">
	<c:set var="fileContent" value="${doc.fileContent}"/>
	<c:set var="boundComponent" value="${uiComponents:getBindedComponent(currentNode, renderContext, 'j:bindedComponent')}"/>
	<c:set var="previewNode" value="${not empty boundComponent && jcr:isNodeType(boundComponent, 'jnt:documentPreview') && boundComponent.properties['j:node'].string == doc.identifier ? boundComponent : null}"/>
	<c:set var="maxDepth" value="${functions:default(currentNode.properties['j:maxLevelDepth'].long, 2)}"/>
	<c:set var="useJavaScriptNavigation" value="${'javascript' == functions:default(currentNode.properties['j:navigationType'].string, 'javascript')}"/>
<ul>
<%!
private void renderOutline(PDOutlineItem item, int level, int maxDepth, String previewUrl, boolean useJavaScriptNavigation, JspWriter out) throws IOException {
    while(item != null) {
        PDDestination dest = item.getDestination();
        int pageNb = -1;
        if (dest instanceof PDPageDestination) {
            pageNb = ((PDPageDestination) dest).findPageNumber();
            pageNb = pageNb >= 0 ? pageNb + 1 : pageNb;
        }
        out.append("<li>");
        if (pageNb > 0 && previewUrl != null) { 
        	out.append("<a href=\"").append(previewUrl).append("?documentPage=").append(String.valueOf(pageNb)).append("\"");
        	if (useJavaScriptNavigation) {
        	    out.append(" class=\"jahia-doc-outline\" rel=\"").append(String.valueOf(pageNb)).append("\"");
        	}
        	out.append(">").append(item.getTitle()).append("</a>");
        	
        } else {
            out.append(item.getTitle());
        }
        out.append("</li>");
        if (level < maxDepth) {
            PDOutlineItem child = item.getFirstChild();
            if (child != null) {
                out.append("<ul>");
            	renderOutline(child, level++, maxDepth, previewUrl, useJavaScriptNavigation, out);
            	out.append("</ul>");
            }
        }
        item = item.getNextSibling();
    }
}
%>
<%
InputStream is = ((JCRFileContent) pageContext.getAttribute("fileContent")).downloadFile();
PDDocument doc = null;
try {
	doc = PDDocument.load(is);
	PDDocumentOutline root = doc.getDocumentCatalog().getDocumentOutline();
	PDOutlineItem item = null;
	if (root == null) {
	    pageContext.setAttribute("noOutline", Boolean.TRUE);
	} else {
		%>
		<c:if test="${not empty previewNode}">
			<c:url var="pageUrl" value="${url.mainResource}"/>
		</c:if>
	    <%
    	renderOutline(root.getFirstChild(), 1, ((Long) pageContext.getAttribute("maxDepth")).intValue(), (String) pageContext.getAttribute("pageUrl"), (Boolean) pageContext.getAttribute("useJavaScriptNavigation"), out);
	}
} finally {
    IOUtils.closeQuietly(is);
    if (doc != null) {
        doc.close();
    }
}
%>
<c:if test="${noOutline}"><li>No outline available in the document</li></c:if>
</ul>
<c:if test="${!noOutline && useJavaScriptNavigation}">
    <template:addResources type="inlinejavascript">
        <script type="text/javascript">
        $(document).ready(function() {
        	$("a.jahia-doc-outline").click(function() {
    	    		$('.jahia-doc-viewer').data('docViewer').getApi().gotoPage($(this).attr('rel'));	
	      			return false;
        		}
        	);
        });
        </script>
    </template:addResources>
</c:if>
</c:if>