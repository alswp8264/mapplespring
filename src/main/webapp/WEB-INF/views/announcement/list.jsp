<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="board-header" style="border:none; padding-left:0;">
        <div class="section-title" style="margin:0;">📢 공지사항</div>
        <c:if test="${sessionScope.loginMember.role == 'ADMIN'}">
            <a href="${pageContext.request.contextPath}/announcement/write" class="btn">공지 작성</a>
        </c:if>
    </div>

    <div class="board-wrap">
        <table class="board-table">
            <thead>
                <tr>
                    <th style="width:70px;">번호</th>
                    <th>제목</th>
                    <th style="width:120px;">작성자</th>
                    <th style="width:120px;">작성일</th>
                    <th style="width:70px;">조회</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="a" items="${annList}">
                    <tr>
                        <td>${a.announcementId}</td>
                        <td class="title">
                            <a href="${pageContext.request.contextPath}/announcement/detail/${a.announcementId}">
                                <c:out value="${a.title}"/>
                            </a>
                        </td>
                        <td><c:out value="${a.writerName}"/></td>
                        <td><fmt:formatDate value="${a.regDate}" pattern="yyyy.MM.dd"/></td>
                        <td>${a.viewCnt}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty annList}">
                    <tr><td colspan="5" style="padding:40px; color:#aaa;">등록된 공지사항이 없습니다.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <c:if test="${dbError}">
        <p style="margin-top:14px; font-size:12px; color:#e07a00;">
            ※ 공지사항 테이블이 아직 생성되지 않았습니다. <code>src/main/resources/sql/announcement.sql</code> 을 Oracle(hr)에서 실행해 주세요.
        </p>
    </c:if>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
