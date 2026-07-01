<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>코디 분석 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

    <div class="home-section-header" style="margin-bottom:24px;">
        <h1 class="home-section-title">👗 코디 분석</h1>
        <a href="${pageContext.request.contextPath}/lookbook" class="home-section-more">룩북으로 →</a>
    </div>

    <%-- 총계 카드 --%>
    <div style="display:grid; grid-template-columns:repeat(3,1fr); gap:16px; margin-bottom:28px;">
        <div style="background:#fff; border:1px solid #e8eaed; border-radius:12px; padding:20px; text-align:center;">
            <div style="font-size:30px; font-weight:700; color:#4f8ef7;">${totalCount}</div>
            <div style="font-size:12px; color:#aaa; margin-top:4px;">총 등록된 룩</div>
        </div>
        <div style="background:#fff; border:1px solid #e8eaed; border-radius:12px; padding:20px; text-align:center;">
            <div style="font-size:30px; font-weight:700; color:#9b59b6;">${classStats.size()}</div>
            <div style="font-size:12px; color:#aaa; margin-top:4px;">등록된 직업 수</div>
        </div>
        <div style="background:#fff; border:1px solid #e8eaed; border-radius:12px; padding:20px; text-align:center;">
            <div style="font-size:30px; font-weight:700; color:#27ae60;">${worldStats.size()}</div>
            <div style="font-size:12px; color:#aaa; margin-top:4px;">참여 월드 수</div>
        </div>
    </div>

    <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:28px;">

        <%-- 직업별 분포 --%>
        <div style="background:#fff; border:1px solid #e8eaed; border-radius:12px; padding:20px;">
            <div style="font-size:14px; font-weight:700; margin-bottom:16px; color:#333;">직업별 코디 등록 현황</div>
            <c:choose>
                <c:when test="${not empty classStats}">
                    <c:set var="maxClass" value="${classStats[0]['cnt']}"/>
                    <c:forEach var="row" items="${classStats}">
                        <div class="dist-row">
                            <span class="dist-class"><c:out value="${row['charClass']}"/></span>
                            <div class="dist-bar-wrap">
                                <div class="dist-bar" style="width:${row['cnt']*100/maxClass}%"></div>
                            </div>
                            <span class="dist-cnt">${row['cnt']}명</span>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-notice" style="padding:30px 0;">데이터가 없습니다.</div>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- 월드별 분포 --%>
        <div style="background:#fff; border:1px solid #e8eaed; border-radius:12px; padding:20px;">
            <div style="font-size:14px; font-weight:700; margin-bottom:16px; color:#333;">월드별 분포</div>
            <c:choose>
                <c:when test="${not empty worldStats}">
                    <c:set var="maxWorld" value="${worldStats[0]['cnt']}"/>
                    <c:forEach var="row" items="${worldStats}">
                        <div class="dist-row">
                            <span class="dist-class"><c:out value="${row['charWorld']}"/></span>
                            <div class="dist-bar-wrap">
                                <div class="dist-bar" style="width:${row['cnt']*100/maxWorld}%; background:#9b59b6;"></div>
                            </div>
                            <span class="dist-cnt">${row['cnt']}명</span>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-notice" style="padding:30px 0;">데이터가 없습니다.</div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%-- 최근 등록된 룩 --%>
    <div style="margin-bottom:20px;">
        <div class="home-section-header" style="margin-bottom:16px;">
            <h2 class="home-section-title" style="font-size:15px;">최근 등록된 룩</h2>
        </div>
        <c:choose>
            <c:when test="${not empty recentList}">
                <div class="lookbook-grid">
                    <c:forEach var="lb" items="${recentList}">
                        <div class="lookbook-card">
                            <a href="${pageContext.request.contextPath}/character/search?charName=<c:out value='${lb.charName}'/>"
                               class="lookbook-img-link">
                                <div class="lookbook-img">
                                    <c:if test="${not empty lb.charImage}">
                                        <img src="${lb.charImage}" alt="">
                                    </c:if>
                                </div>
                            </a>
                            <div class="lookbook-body">
                                <div class="lookbook-title"><c:out value="${lb.title}"/></div>
                                <div class="lookbook-char">
                                    <strong>
                                        <a href="${pageContext.request.contextPath}/character/search?charName=<c:out value='${lb.charName}'/>">
                                            <c:out value="${lb.charName}"/>
                                        </a>
                                    </strong>
                                    <span>Lv.${lb.charLevel}</span>
                                </div>
                                <div class="lookbook-class">
                                    <c:out value="${lb.charClass}"/> · <c:out value="${lb.charWorld}"/>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-notice" style="padding:40px 0;">아직 등록된 룩이 없습니다. 캐릭터를 검색하고 룩북에 등록해보세요!</div>
            </c:otherwise>
        </c:choose>
    </div>

</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
