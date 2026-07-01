<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>패치노트 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        body { background: #f4f5f7; }
        .wrap { max-width: 860px; margin: 0 auto; padding: 32px 20px 60px; }
        .page-title {
            font-size: 22px; font-weight: 800; color: #1e2330;
            margin-bottom: 24px; display: flex; align-items: center; gap: 8px;
        }
        .page-title span { width: 5px; height: 22px; background: #7c3aed; border-radius: 3px; display: inline-block; }
        .patch-list { display: flex; flex-direction: column; gap: 0; background: #fff; border: 1px solid #e8eaed; border-radius: 12px; overflow: hidden; }
        .patch-item {
            display: flex; align-items: center; gap: 16px;
            padding: 16px 20px;
            border-bottom: 1px solid #f0f2f5;
            text-decoration: none; color: inherit;
            transition: background .12s;
        }
        .patch-item:last-child { border-bottom: none; }
        .patch-item:hover { background: #f8f9fb; }
        .patch-icon {
            flex-shrink: 0; width: 44px; height: 44px;
            background: linear-gradient(135deg, #7c3aed, #4f8ef7);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px;
        }
        .patch-title { font-size: 15px; font-weight: 600; color: #1e2330; flex: 1; }
        .patch-date { font-size: 12px; color: #9ba3b4; white-space: nowrap; }
        .empty { padding: 80px 0; text-align: center; color: #9ba3b4; font-size: 15px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="wrap">
    <div class="page-title"><span></span>📋 패치노트 / 업데이트</div>

    <c:choose>
        <c:when test="${not empty updateList}">
            <div class="patch-list">
                <c:forEach var="u" items="${updateList}">
                    <a href="${pageContext.request.contextPath}/notice/update/detail?noticeId=${u.notice_id}" class="patch-item">
                        <div class="patch-icon">📝</div>
                        <div class="patch-title"><c:out value="${u.title}"/></div>
                        <div class="patch-date"><c:out value="${u.date}"/></div>
                    </a>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty">패치노트 정보가 없습니다.</div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
