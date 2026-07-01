<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="form-wrap">
        <h2>회원가입</h2>
        <c:if test="${not empty msg}">
            <div class="error-msg">${msg}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/member/join" method="post">
            <div class="form-group">
                <label>아이디</label>
                <div style="display:flex; gap:8px;">
                    <input type="text" id="loginId" name="loginId" placeholder="영문, 숫자 조합" required style="flex:1">
                    <button type="button" onclick="checkId()" class="btn btn-outline" style="white-space:nowrap">중복확인</button>
                </div>
                <span id="idMsg" style="font-size:12px; margin-top:4px; display:block;"></span>
            </div>
            <div class="form-group">
                <label>비밀번호</label>
                <input type="password" name="password" placeholder="비밀번호 입력" required>
            </div>
            <div class="form-group">
                <label>이름</label>
                <input type="text" name="name" placeholder="이름 입력" required>
            </div>
            <div class="form-group">
                <label>이메일</label>
                <input type="email" name="email" placeholder="이메일 입력" required>
            </div>
            <button type="submit" class="btn" style="width:100%; margin-top:4px;">가입하기</button>
        </form>
        <p style="text-align:center; margin-top:16px; font-size:13px; color:#888;">
            이미 계정이 있으신가요?
            <a href="${pageContext.request.contextPath}/member/login" style="color:#4f8ef7; font-weight:600;">로그인</a>
        </p>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<script>
function checkId() {
    var loginId = document.getElementById('loginId').value.trim();
    if (!loginId) { alert('아이디를 입력하세요.'); return; }
    fetch('${pageContext.request.contextPath}/member/checkId?loginId=' + encodeURIComponent(loginId))
        .then(res => res.text())
        .then(result => {
            var msg = document.getElementById('idMsg');
            if (result === 'duplicate') {
                msg.style.color = '#e03e3e';
                msg.textContent = '이미 사용 중인 아이디입니다.';
            } else {
                msg.style.color = '#2d8a4e';
                msg.textContent = '사용 가능한 아이디입니다.';
            }
        });
}
</script>
</body>
</html>
