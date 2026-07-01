<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>문의 답변 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        .inquiry-wrap { max-width:750px; margin:40px auto; }
        .inquiry-wrap h2 { font-size:22px; font-weight:700; margin-bottom:24px; }
        .iq-box { background:#fff; border:1.5px solid #e8ecf5; border-radius:12px; padding:22px; margin-bottom:20px; }
        .iq-box .label { font-size:12px; color:#aaa; font-weight:600; margin-bottom:4px; }
        .iq-box .value { font-size:14px; color:#222; white-space:pre-wrap; margin-bottom:14px; }
        .iq-box .title-val { font-size:17px; font-weight:700; color:#222; margin-bottom:8px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:#555; margin-bottom:6px; }
        .form-group textarea {
            width:100%; padding:10px 12px; border:1.5px solid #e0e4ef; border-radius:8px;
            font-size:14px; font-family:inherit; height:160px; resize:vertical; box-sizing:border-box;
        }
        .form-group textarea:focus { border-color:#4f8ef7; outline:none; }
        .btn-row { display:flex; gap:10px; margin-top:16px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="inquiry-wrap">
        <h2>📨 문의 답변</h2>

        <div class="iq-box">
            <div class="label">작성자</div>
            <div class="value">${inquiry.loginId} · <fmt:formatDate value="${inquiry.createdAt}" pattern="yyyy-MM-dd HH:mm"/></div>
            <div class="title-val">${inquiry.title}</div>
            <div class="label">문의 내용</div>
            <div class="value">${inquiry.content}</div>
        </div>

        <c:choose>
            <c:when test="${not empty inquiry.answer}">
                <div class="iq-box" style="background:#f4f7fc;">
                    <div class="label">✅ 답변완료 · <fmt:formatDate value="${inquiry.answeredAt}" pattern="yyyy-MM-dd HH:mm"/></div>
                    <div class="value">${inquiry.answer}</div>
                </div>
                <a href="${pageContext.request.contextPath}/inquiry/admin/list" class="btn">목록으로</a>
            </c:when>
            <c:otherwise>
                <form action="${pageContext.request.contextPath}/inquiry/admin/answer" method="post">
                    <input type="hidden" name="inquiryId" value="${inquiry.inquiryId}">
                    <div class="form-group">
                        <label>답변 작성</label>
                        <textarea name="answer" placeholder="답변을 입력하세요" required></textarea>
                    </div>
                    <div class="btn-row">
                        <button type="submit" class="btn">답변 등록</button>
                        <a href="${pageContext.request.contextPath}/inquiry/admin/list" class="btn" style="background:#eef1f7;color:#555;">목록으로</a>
                    </div>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
