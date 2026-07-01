<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header>
    <div class="header-inner">
        <a href="${pageContext.request.contextPath}/" class="logo">🍁 Mapple</a>
        <nav>
            <a href="${pageContext.request.contextPath}/character/search">캐릭터 검색</a>
            <a href="${pageContext.request.contextPath}/ranking">랭킹</a>
            <a href="${pageContext.request.contextPath}/notice/event">이벤트</a>
            <a href="${pageContext.request.contextPath}/notice/cashshop">캐시샵</a>
            <a href="${pageContext.request.contextPath}/notice/update">패치노트</a>
            <a href="${pageContext.request.contextPath}/announcement">공지사항</a>
            <div class="nav-dropdown">
                <a href="${pageContext.request.contextPath}/lookbook">룩북/분석 ▾</a>
                <div class="nav-dropdown-menu">
                    <a href="${pageContext.request.contextPath}/lookbook">룩북</a>
                    <a href="${pageContext.request.contextPath}/lookbook/analysis">코디 분석</a>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/board/list">게시판</a>
            <c:choose>
                <c:when test="${not empty sessionScope.loginMember}">
                    <a href="${pageContext.request.contextPath}/member/mypage">
                        <c:choose>
                            <c:when test="${sessionScope.loginMember.role == 'ADMIN'}">관리자</c:when>
                            <c:otherwise>${sessionScope.loginMember.name}</c:otherwise>
                        </c:choose>님
                    </a>
                    <c:choose>
                        <c:when test="${sessionScope.loginMember.role == 'ADMIN'}">
                            <a href="${pageContext.request.contextPath}/member/admin/list">관리자</a>
                            <a href="${pageContext.request.contextPath}/inquiry/admin/list">문의관리</a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/inquiry/write">문의하기</a>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/member/logout">로그아웃</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/member/join">회원가입</a>
                    <a href="${pageContext.request.contextPath}/member/login" class="btn-login">로그인</a>
                </c:otherwise>
            </c:choose>
        </nav>
    </div>
</header>
