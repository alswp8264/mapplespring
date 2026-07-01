<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><c:out value="${ann.title}"/> - 공지사항</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="post-wrap">
        <div class="post-header">
            <div class="post-title"><c:out value="${ann.title}"/></div>
            <div class="post-meta">
                <span>작성자 <c:out value="${ann.writerName}"/></span>
                <span><fmt:formatDate value="${ann.regDate}" pattern="yyyy.MM.dd HH:mm"/></span>
                <span>조회 ${ann.viewCnt}</span>
            </div>
        </div>
        <div class="post-content"><c:out value="${ann.content}"/></div>
        <div class="post-footer">
            <a href="${pageContext.request.contextPath}/announcement" class="btn btn-gray">목록</a>
            <c:if test="${sessionScope.loginMember.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/announcement/edit/${ann.announcementId}" class="btn btn-outline">수정</a>
                <form action="${pageContext.request.contextPath}/announcement/delete/${ann.announcementId}" method="post"
                      style="display:inline;" onsubmit="return confirm('이 공지를 삭제할까요?')">
                    <button type="submit" class="btn btn-danger">삭제</button>
                </form>
            </c:if>
        </div>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
