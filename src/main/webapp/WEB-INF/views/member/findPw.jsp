<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>비밀번호 찾기 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="form-wrap">
    <h2>비밀번호 찾기</h2>

    <c:if test="${not empty error}">
        <div class="error-msg">${error}</div>
    </c:if>

    <c:choose>
        <%-- 2단계: 본인확인 완료 → 새 비밀번호 설정 --%>
        <c:when test="${verified}">
            <div class="success-msg">본인확인 완료! 새 비밀번호를 설정하세요. (아이디: <strong>${loginId}</strong>)</div>
            <form action="${pageContext.request.contextPath}/member/findPw/reset" method="post">
                <div class="form-group">
                    <label>새 비밀번호</label>
                    <input type="password" name="newPw" required minlength="4">
                </div>
                <button type="submit" class="btn" style="width:100%; margin-top:4px;">비밀번호 변경</button>
            </form>
        </c:when>
        <%-- 1단계: 본인확인 --%>
        <c:otherwise>
            <p style="font-size:13px; color:#666; margin-bottom:16px;">
                가입 시 입력한 아이디 · 이름 · 이메일로 본인확인 후 새 비밀번호를 설정합니다.
            </p>
            <form action="${pageContext.request.contextPath}/member/findPw/verify" method="post">
                <div class="form-group">
                    <label>아이디</label>
                    <input type="text" name="loginId" required>
                </div>
                <div class="form-group">
                    <label>이름</label>
                    <input type="text" name="name" required>
                </div>
                <div class="form-group">
                    <label>이메일</label>
                    <input type="email" name="email" required>
                </div>
                <button type="submit" class="btn" style="width:100%; margin-top:4px;">본인확인</button>
            </form>
            <p style="text-align:center; margin-top:16px; font-size:13px;">
                <a href="${pageContext.request.contextPath}/member/findId">아이디 찾기</a> ·
                <a href="${pageContext.request.contextPath}/member/login">로그인</a>
            </p>
        </c:otherwise>
    </c:choose>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
