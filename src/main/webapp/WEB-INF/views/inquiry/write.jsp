<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>문의하기 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        .inquiry-wrap { max-width:700px; margin:40px auto; }
        .inquiry-wrap h2 { font-size:22px; font-weight:700; margin-bottom:24px; color:#222; }
        .form-group { margin-bottom:16px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:#555; margin-bottom:6px; }
        .form-group input, .form-group textarea {
            width:100%; padding:10px 12px; border:1.5px solid #e0e4ef; border-radius:8px;
            font-size:14px; font-family:inherit; box-sizing:border-box;
        }
        .form-group textarea { height:220px; resize:vertical; }
        .form-group input:focus, .form-group textarea:focus { border-color:#4f8ef7; outline:none; }
        .btn-row { display:flex; gap:10px; margin-top:20px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="inquiry-wrap">
        <h2>📨 관리자 문의</h2>
        <form action="${pageContext.request.contextPath}/inquiry/write" method="post">
            <div class="form-group">
                <label>제목</label>
                <input type="text" name="title" placeholder="문의 제목을 입력하세요" required maxlength="200">
            </div>
            <div class="form-group">
                <label>내용</label>
                <textarea name="content" placeholder="문의 내용을 자세히 작성해 주세요" required></textarea>
            </div>
            <div class="btn-row">
                <button type="submit" class="btn">문의 등록</button>
                <a href="${pageContext.request.contextPath}/inquiry/my" class="btn" style="background:#eef1f7;color:#555;">내 문의 목록</a>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
