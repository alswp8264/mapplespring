<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>이벤트 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        body { background: #f4f5f7; }
        .ev-page-wrap {
            max-width: 1100px; margin: 0 auto; padding: 32px 20px 60px;
        }
        .ev-page-title {
            font-size: 22px; font-weight: 800; color: #1e2330;
            margin-bottom: 24px; display: flex; align-items: center; gap: 8px;
        }
        .ev-page-title span {
            width: 5px; height: 22px; background: #4f8ef7;
            border-radius: 3px; display: inline-block;
        }
        .ev-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 24px;
        }
        .ev-card {
            background: #fff;
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid #e8eaed;
            text-decoration: none;
            color: inherit;
            transition: transform 0.15s, box-shadow 0.15s;
            display: flex;
            flex-direction: column;
        }
        .ev-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.12);
        }
        .ev-card-thumb {
            width: 100%;
            aspect-ratio: 4/3;
            overflow: hidden;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex; align-items: flex-start; justify-content: center;
        }
        .ev-card-thumb img {
            width: 100%; height: 100%;
            object-fit: cover;
            object-position: top;
            display: block;
            transition: transform 0.2s;
        }
        .ev-card:hover .ev-card-thumb img { transform: scale(1.04); }
        .ev-card-body {
            padding: 16px 18px 18px;
            flex: 1; display: flex; flex-direction: column; gap: 8px;
        }
        .ev-card-badge {
            display: inline-block;
            background: #eef3ff; color: #4f8ef7;
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
            width: fit-content;
        }
        .ev-card-title {
            font-size: 16px; font-weight: 700; color: #1e2330;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .ev-card-date {
            font-size: 13px; color: #9ba3b4; margin-top: auto;
        }
        @media (max-width: 600px) {
            .ev-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="ev-page-wrap">
    <div class="ev-page-title">
        <span></span>진행 중인 이벤트
    </div>

    <c:choose>
        <c:when test="${not empty eventList}">
            <div class="ev-grid">
                <c:forEach var="ev" items="${eventList}">
                    <a href="${pageContext.request.contextPath}/notice/event/detail?noticeId=${ev.notice_id}"
                       class="ev-card">
                        <div class="ev-card-thumb">
                            <c:choose>
                                <c:when test="${not empty ev.thumbnail}">
                                    <img src="${ev.thumbnail}" alt="${ev.title}"
                                         onerror="this.parentNode.style.background='linear-gradient(135deg,#667eea,#764ba2)';this.style.display='none'">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/resources/img/default_event.svg" alt="">
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="ev-card-body">
                            <span class="ev-card-badge">이벤트</span>
                            <div class="ev-card-title"><c:out value="${ev.title}"/></div>
                            <div class="ev-card-date">
                                <c:choose>
                                    <c:when test="${not empty ev.date_short}">
                                        <c:out value="${ev.date_short}"/>
                                    </c:when>
                                    <c:otherwise><c:out value="${ev.date}"/></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div style="padding:80px 0; text-align:center; color:#9ba3b4; font-size:15px;">
                현재 진행 중인 이벤트가 없습니다.
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
