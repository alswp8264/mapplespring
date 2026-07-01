<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지 작성 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="form-wrap" style="max-width:720px;">
        <h2>공지 작성</h2>
        <form action="${pageContext.request.contextPath}/announcement/write" method="post">
            <div class="form-group">
                <label>제목</label>
                <input type="text" name="title" placeholder="제목을 입력하세요" required>
            </div>
            <div class="form-group">
                <label>내용</label>
                <textarea name="content" rows="14" placeholder="내용을 입력하세요" required></textarea>
            </div>
            <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:8px;">
                <a href="${pageContext.request.contextPath}/announcement" class="btn btn-gray">취소</a>
                <button type="submit" class="btn">등록</button>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
