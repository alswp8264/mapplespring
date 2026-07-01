<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>문의 관리 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        .inquiry-wrap { max-width:900px; margin:40px auto; }
        .inquiry-wrap h2 { font-size:22px; font-weight:700; margin-bottom:20px; }
        table { width:100%; border-collapse:collapse; background:#fff; border-radius:12px; overflow:hidden; box-shadow:0 2px 8px rgba(0,0,0,.06); }
        th { background:#f4f7fc; padding:12px 14px; font-size:13px; color:#555; text-align:left; border-bottom:1.5px solid #e8ecf5; }
        td { padding:12px 14px; font-size:13px; color:#333; border-bottom:1px solid #f0f3f9; }
        tr:hover td { background:#f9fbff; }
        .iq-status { display:inline-block; padding:3px 10px; border-radius:20px; font-size:12px; font-weight:700; }
        .iq-status.wait { background:#fff3e0; color:#e65100; }
        .iq-status.done { background:#e8f5e9; color:#2e7d32; }
        .btn-sm { padding:4px 12px; font-size:12px; border-radius:6px; background:#4f8ef7; color:#fff; border:none; cursor:pointer; text-decoration:none; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="inquiry-wrap">
        <h2>📨 문의 관리</h2>
        <table>
            <thead>
                <tr>
                    <th>#</th><th>작성자</th><th>제목</th><th>상태</th><th>작성일</th><th>답변</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty list}">
                        <tr><td colspan="6" style="text-align:center;color:#aaa;padding:30px;">문의가 없습니다.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="iq" items="${list}">
                            <tr>
                                <td>${iq.inquiryId}</td>
                                <td>${iq.loginId}</td>
                                <td>${iq.title}</td>
                                <td>
                                    <span class="iq-status <c:choose><c:when test='${iq.status=="답변완료"}'>done</c:when><c:otherwise>wait</c:otherwise></c:choose>">
                                        ${iq.status}
                                    </span>
                                </td>
                                <td><fmt:formatDate value="${iq.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/inquiry/admin/detail/${iq.inquiryId}" class="btn-sm">
                                        <c:choose>
                                            <c:when test="${iq.status=='답변완료'}">보기</c:when>
                                            <c:otherwise>답변하기</c:otherwise>
                                        </c:choose>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
