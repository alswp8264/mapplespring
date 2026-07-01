<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>신고 관리 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

    <div class="section-title" style="margin-bottom:16px">🚩 관리자 — 신고 관리</div>
    <p style="font-size:13px; color:#888; margin-bottom:16px;">
        승인하면 해당 게시글이 삭제되고 작성자는 <strong>1시간 동안 글·댓글 작성이 제한</strong>됩니다.
    </p>

    <div style="background:#fff; border:1px solid #e8eaed; border-radius:16px; overflow:hidden;">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width:60px">번호</th>
                    <th>신고된 게시글</th>
                    <th style="width:100px">작성자</th>
                    <th style="width:100px">신고자</th>
                    <th>사유</th>
                    <th style="width:110px">신고일</th>
                    <th style="width:150px">처리</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="r" items="${reportList}">
                    <tr>
                        <td>${r.reportId}</td>
                        <td class="title" style="text-align:left;">
                            <a href="${pageContext.request.contextPath}/board/detail/${r.boardId}" target="_blank">
                                <c:out value="${r.boardTitle}"/>
                            </a>
                        </td>
                        <td><c:out value="${r.authorName}"/></td>
                        <td><c:out value="${r.reporterName}"/></td>
                        <td style="text-align:left; font-size:12px; color:#666;"><c:out value="${r.reason}"/></td>
                        <td><fmt:formatDate value="${r.regDate}" pattern="MM.dd HH:mm"/></td>
                        <td>
                            <div style="display:flex; gap:6px; justify-content:center;">
                                <form action="${pageContext.request.contextPath}/board/admin/report/approve" method="post"
                                      onsubmit="return confirm('게시글을 삭제하고 작성자를 1시간 제한할까요?')">
                                    <input type="hidden" name="reportId" value="${r.reportId}">
                                    <button type="submit" class="btn-sm" style="color:#e03e3e; border-color:#f5c6c6;">승인(삭제+밴)</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/board/admin/report/reject" method="post">
                                    <input type="hidden" name="reportId" value="${r.reportId}">
                                    <button type="submit" class="btn-sm">반려</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty reportList}">
                    <tr><td colspan="7" style="padding:30px; color:#aaa;">대기 중인 신고가 없습니다.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>

</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
