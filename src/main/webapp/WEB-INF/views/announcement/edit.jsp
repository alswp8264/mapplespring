<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지 수정 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="form-wrap" style="max-width:720px;">
        <h2>공지 수정</h2>
        <form action="${pageContext.request.contextPath}/announcement/edit" method="post">
            <input type="hidden" name="announcementId" value="${ann.announcementId}">
            <div class="form-group">
                <label>제목</label>
                <input type="text" name="title" value="<c:out value='${ann.title}'/>" required>
            </div>
            <div class="form-group">
                <label>내용</label>
                <textarea name="content" rows="14" required><c:out value="${ann.content}"/></textarea>
            </div>
            <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:8px;">
                <a href="${pageContext.request.contextPath}/announcement/detail/${ann.announcementId}" class="btn btn-gray">취소</a>
                <button type="submit" class="btn">수정</button>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
