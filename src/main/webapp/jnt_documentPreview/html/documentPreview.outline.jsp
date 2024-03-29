<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="dm" uri="http://www.jahia.org/tags/document-management" %>
<jcr:nodeProperty name="j:node" node="${currentNode}" var="docProperty"/>
<c:set var="doc" value="${not empty docProperty ? docProperty.node : null}"/>
<c:if test="${renderContext.editMode}">
    <c:if test="${not empty doc}">
        <template:addResources type="css" resources="files.css"/>
        <span class="icon ${functions:fileIcon(doc.name)}"></span>
        <a href="<c:url value='${doc.url}'/>">${fn:escapeXml(doc.name)}</a>
        (<fmt:message key="jnt_documentPreview.noPreviewInEditMode"/>)
    </c:if>
    <c:if test="${empty doc}">
       <fmt:message key="jnt_documentPreview.noDocumentSelected"/> 
    </c:if>
</c:if>
<c:if test="${!renderContext.editMode}">
<c:if test="${not empty doc && dm:isViewable(doc)}">
    <c:url var="swfUrl" value="${dm:getViewUrl(doc, true)}" context="/"/>
    <c:if test="${not empty swfUrl}">
        <template:addResources type="javascript" resources="jquery.min.js,flexpaper/flexpaper_flash.min.js,jahia.swfview.min.js"/>
        <jcr:nodeProperty name="j:width" node="${currentNode}" var="width"/>
        <jcr:nodeProperty name="j:height" node="${currentNode}" var="height"/>
        <c:set var="w" value="${functions:default(width.string, '640')}"/><c:set var="w" value="${w == 0 ? '100%' : functions:stringConcatenation(w, 'px', '')}"/>
        <c:set var="h" value="${functions:default(height.string, '480')}"/><c:set var="h" value="${h == 0 ? '100%' : functions:stringConcatenation(h, 'px', '')}"/>
        <a class="jahia-doc-viewer" id="jahia-doc-viewer-${currentNode.identifier}" rel="${swfUrl}" style="width:${w}; height:${h}; display:block"></a>
        <template:addResources type="inlinejavascript">
            <script type="text/javascript">
            $(document).ready(function() {
            	<c:if test="${not empty param.documentPage}">
            		$("a.jahia-doc-viewer").docViewer({'StartAtPage':'${param.documentPage}',FitPageOnLoad:false,FitWidthOnLoad:true});
            	</c:if>
            	<c:if test="${empty param.documentPage}">
	        		$("a.jahia-doc-viewer").docViewer({FitPageOnLoad:false,FitWidthOnLoad:true});
	        	</c:if>
            });
            </script>
        </template:addResources>
    </c:if>
</c:if>
</c:if>