<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>캐시샵 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

    <div class="home-section">
        <div class="home-section-header">
            <h2 class="home-section-title">캐시샵 판매 안내</h2>
        </div>

        <c:choose>
            <c:when test="${not empty cashList}">
                <div class="card-grid">
                    <c:forEach var="item" items="${cashList}">
                        <a href="${pageContext.request.contextPath}/notice/cashshop/detail?noticeId=${item.notice_id}"
                           class="slider-card">
                            <div class="slider-card-img">
                                <c:choose>
                                    <c:when test="${not empty item.thumbnail}">
                                        <img src="${item.thumbnail}" alt=""
                                             onerror="this.src='${pageContext.request.contextPath}/resources/img/default_cash.svg'">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/resources/img/default_cash.svg" alt="">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="slider-card-body">
                                <span class="badge badge-cash">캐시</span>
                                <div class="slider-card-title"><c:out value="${item.title}"/></div>
                                <div class="slider-card-date">
                                    <c:choose>
                                        <c:when test="${not empty item.date_sale_start}">
                                            <c:out value="${item.date_sale_start}"/>
                                            <c:if test="${not empty item.date_sale_end}"> ~ <c:out value="${item.date_sale_end}"/></c:if>
                                        </c:when>
                                        <c:otherwise><c:out value="${item.date}"/></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-notice">현재 캐시샵 판매 정보를 불러올 수 없습니다.</div>
            </c:otherwise>
        </c:choose>
    </div>

</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
