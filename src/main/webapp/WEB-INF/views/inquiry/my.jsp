<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>내 문의 목록 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        .inquiry-wrap { max-width:800px; margin:40px auto; }
        .inquiry-wrap h2 { font-size:22px; font-weight:700; margin-bottom:20px; color:#222; }
        .inquiry-card {
            background:#fff; border:1.5px solid #e8ecf5; border-radius:12px;
            padding:18px 22px; margin-bottom:14px;
        }
        .inquiry-card .iq-title { font-size:15px; font-weight:700; color:#222; margin-bottom:6px; }
        .inquiry-card .iq-meta  { font-size:12px; color:#aaa; margin-bottom:10px; }
        .iq-status {
            display:inline-block; padding:3px 10px; border-radius:20px;
            font-size:12px; font-weight:700;
        }
        .iq-status.wait   { background:#fff3e0; color:#e65100; }
        .iq-status.done   { background:#e8f5e9; color:#2e7d32; }
        .iq-content { font-size:13px; color:#444; margin-bottom:10px; white-space:pre-wrap; }
        .iq-answer  { background:#f4f7fc; border-radius:8px; padding:12px 14px; font-size:13px; color:#333; margin-top:10px; white-space:pre-wrap; }
        .iq-answer strong { color:#4f8ef7; font-size:12px; display:block; margin-bottom:4px; }
        .btn-row { display:flex; gap:10px; margin-bottom:20px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="inquiry-wrap">
        <h2>📋 내 문의 목록</h2>
        <div class="btn-row">
            <a href="${pageContext.request.contextPath}/inquiry/write" class="btn">+ 새 문의</a>
        </div>
        <c:choose>
            <c:when test="${empty list}">
                <p style="color:#aaa; text-align:center; padding:40px 0;">등록된 문의가 없습니다.</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="iq" items="${list}">
                    <div class="inquiry-card">
                        <div style="display:flex; align-items:center; gap:10px; margin-bottom:4px;">
                            <span class="iq-status <c:choose><c:when test='${iq.status=="답변완료"}'>done</c:when><c:otherwise>wait</c:otherwise></c:choose>">
                                ${iq.status}
                            </span>
                            <span class="iq-title">${iq.title}</span>
                        </div>
                        <div class="iq-meta">
                            <fmt:formatDate value="${iq.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                        </div>
                        <div class="iq-content">${iq.content}</div>
                        <c:if test="${not empty iq.answer}">
                            <div class="iq-answer">
                                <strong>🛡 관리자 답변 · <fmt:formatDate value="${iq.answeredAt}" pattern="yyyy-MM-dd HH:mm"/></strong>
                                ${iq.answer}
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
