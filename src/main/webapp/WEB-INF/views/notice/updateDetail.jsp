<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${notice.title} - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        body { background: #f4f5f7; }
        .wrap { max-width: 860px; margin: 0 auto; padding: 32px 20px 60px; }
        .back-btn {
            display: inline-flex; align-items: center; gap: 6px;
            color: #7c3aed; font-size: 14px; font-weight: 600;
            text-decoration: none; margin-bottom: 20px;
        }
        .back-btn:hover { text-decoration: underline; }
        .detail-card {
            background: #fff; border: 1px solid #e8eaed;
            border-radius: 14px; overflow: hidden;
        }
        .detail-header {
            background: linear-gradient(135deg, #7c3aed 0%, #4f8ef7 100%);
            padding: 28px 28px 24px;
            color: #fff;
        }
        .detail-header .label {
            font-size: 11px; font-weight: 700; letter-spacing: 1px;
            background: rgba(255,255,255,0.2); display: inline-block;
            padding: 3px 10px; border-radius: 20px; margin-bottom: 10px;
        }
        .detail-header h1 { font-size: 20px; font-weight: 800; line-height: 1.4; margin: 0 0 12px; }
        .detail-meta { font-size: 13px; opacity: .8; }
        .detail-body { padding: 28px; }
        .detail-body img { max-width: 100%; height: auto; border-radius: 6px; }
        .detail-body a { color: #7c3aed; }
        .official-link {
            display: inline-flex; align-items: center; gap: 6px;
            margin-top: 20px; padding: 10px 18px;
            background: #7c3aed; color: #fff; border-radius: 8px;
            font-size: 14px; font-weight: 600; text-decoration: none;
        }
        .official-link:hover { background: #6d28d9; }
        .empty { padding: 80px 0; text-align: center; color: #9ba3b4; font-size: 15px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="wrap">
    <a href="${pageContext.request.contextPath}/notice/update" class="back-btn">← 패치노트 목록으로</a>

    <c:choose>
        <c:when test="${not empty notice}">
            <div class="detail-card">
                <div class="detail-header">
                    <div class="label">📝 패치노트</div>
                    <h1><c:out value="${notice.title}"/></h1>
                    <div class="detail-meta">업데이트일: <c:out value="${notice.date}"/></div>
                </div>
                <div class="detail-body">
                    <c:choose>
                        <c:when test="${not empty noticeContents}">
                            ${noticeContents}
                        </c:when>
                        <c:otherwise>
                            <p style="color:#9ba3b4;">상세 내용을 불러올 수 없습니다.</p>
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${not empty notice.url}">
                        <br>
                        <a href="${notice.url}" target="_blank" class="official-link">🔗 공식 사이트에서 보기</a>
                    </c:if>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty">패치노트를 찾을 수 없습니다.</div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
