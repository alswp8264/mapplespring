<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>아이디 찾기 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="form-wrap">
    <h2>아이디 찾기</h2>

    <c:if test="${not empty foundId}">
        <div class="success-msg">회원님의 아이디는 <strong>${foundId}</strong> 입니다.</div>
        <a href="${pageContext.request.contextPath}/member/login" class="btn" style="width:100%; text-align:center;">로그인하러 가기</a>
    </c:if>

    <c:if test="${empty foundId}">
        <c:if test="${not empty error}">
            <div class="error-msg">${error}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/member/findId" method="post">
            <div class="form-group">
                <label>이름</label>
                <input type="text" name="name" required>
            </div>
            <div class="form-group">
                <label>이메일</label>
                <input type="email" name="email" required>
            </div>
            <button type="submit" class="btn" style="width:100%; margin-top:4px;">아이디 찾기</button>
        </form>
        <p style="text-align:center; margin-top:16px; font-size:13px;">
            <a href="${pageContext.request.contextPath}/member/findPw">비밀번호 찾기</a> ·
            <a href="${pageContext.request.contextPath}/member/login">로그인</a>
        </p>
    </c:if>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
