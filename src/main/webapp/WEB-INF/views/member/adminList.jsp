<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원 관리 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

    <div class="section-title" style="margin-bottom:16px">🛠 관리자 — 회원 관리</div>

    <%-- 관리 바로가기 --%>
    <div style="display:flex; gap:8px; margin-bottom:18px; flex-wrap:wrap;">
        <a href="${pageContext.request.contextPath}/announcement/write" class="btn">공지 작성</a>
        <a href="${pageContext.request.contextPath}/board/admin/reports" class="btn btn-danger">🚩 신고 관리</a>
        <a href="${pageContext.request.contextPath}/board/list" class="btn btn-outline">게시판 관리</a>
        <a href="${pageContext.request.contextPath}/lookbook" class="btn btn-outline">룩북 관리</a>
    </div>

    <%-- 검색/필터 --%>
    <form action="${pageContext.request.contextPath}/member/admin/list" method="get"
          style="display:flex; gap:8px; margin-bottom:16px; flex-wrap:wrap; align-items:center;">
        <input type="text" name="keyword" value="<c:out value='${keyword}'/>" placeholder="아이디 또는 이름 검색"
               class="rank-class-input" style="width:220px;">
        <select name="role" class="rank-select">
            <option value="">전체 권한</option>
            <option value="USER"  ${roleFilter == 'USER'  ? 'selected' : ''}>USER</option>
            <option value="ADMIN" ${roleFilter == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
        </select>
        <button type="submit" class="btn">검색</button>
        <a href="${pageContext.request.contextPath}/member/admin/list" class="btn btn-gray">초기화</a>
    </form>

    <div style="background:#fff; border:1px solid #e8eaed; border-radius:16px; overflow:hidden;">
        <table class="data-table">
            <thead>
                <tr>
                    <th>번호</th><th>아이디</th><th>이름</th><th>이메일</th>
                    <th>권한</th><th>벤 상태</th><th>가입일</th><th>관리</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="m" items="${memberList}">
                    <tr>
                        <td>${m.memberId}</td>
                        <td>${m.loginId}</td>
                        <td>${m.name}</td>
                        <td>${m.email}</td>
                        <td>
                            <span style="padding:3px 10px; border-radius:12px; font-size:11px; font-weight:600;
                                background:${m.role == 'ADMIN' ? '#fff0e0' : '#f0f4ff'};
                                color:${m.role == 'ADMIN' ? '#e07a00' : '#4f8ef7'}">${m.role}</span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty m.banUntil}">
                                    <span style="color:#e03e3e; font-size:12px; font-weight:600;">🔴 벤</span><br>
                                    <span style="color:#aaa; font-size:11px;"><fmt:formatDate value="${m.banUntil}" pattern="MM/dd HH:mm"/> 까지</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color:#aaa; font-size:12px;">-</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><fmt:formatDate value="${m.regDate}" pattern="yyyy.MM.dd"/></td>
                        <td style="display:flex; gap:6px; flex-wrap:wrap; align-items:center;">
                            <c:if test="${not empty m.banUntil}">
                                <form action="${pageContext.request.contextPath}/member/admin/unban/${m.memberId}"
                                      method="post" style="display:inline;"
                                      onsubmit="return confirm('[${m.loginId}] 벤을 해제할까요?')">
                                    <button type="submit" class="btn-sm" style="background:#e8f5e9; color:#2e7d32; border:none;">벤 해제</button>
                                </form>
                            </c:if>
                            <c:choose>
                                <c:when test="${m.role == 'ADMIN' || m.memberId == sessionScope.loginMember.memberId}">
                                    <span style="color:#bbb; font-size:11px;">-</span>
                                </c:when>
                                <c:otherwise>
                                    <form action="${pageContext.request.contextPath}/member/admin/delete/${m.memberId}"
                                          method="post" style="display:inline;"
                                          onsubmit="return confirm('[${m.loginId}] 회원을 삭제할까요? 복구할 수 없습니다.')">
                                        <button type="submit" class="btn-sm" style="color:#e03e3e; border-color:#f5c6c6;">삭제</button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty memberList}">
                    <tr><td colspan="7" style="padding:30px; color:#aaa;">회원이 없습니다.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>

</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
