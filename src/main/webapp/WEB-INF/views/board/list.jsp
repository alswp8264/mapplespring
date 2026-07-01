<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시판 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        .cat-badge { display:inline-block; padding:2px 9px; border-radius:10px; font-size:11px; font-weight:700;
            background:#eef4ff; color:#3b7be0; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

    <c:if test="${param.msg == 'banned'}">
        <div class="error-msg">신고 처리로 인해 1시간 동안 글/댓글 작성이 제한되었습니다.</div>
    </c:if>

    <%-- 카테고리 토글 필터 --%>
    <div class="rank-controls" style="margin-bottom:16px;">
        <div class="rank-type-tabs">
            <a href="${pageContext.request.contextPath}/board/list"
               class="rank-type-tab ${empty selectedCategory ? 'active' : ''}">전체</a>
            <c:forEach var="cat" items="${categories}">
                <a href="${pageContext.request.contextPath}/board/list?category=${cat}"
                   class="rank-type-tab ${selectedCategory == cat ? 'active' : ''}">${cat}</a>
            </c:forEach>
        </div>
    </div>

    <div class="board-wrap">
        <div class="board-header">
            <span class="section-title" style="margin:0">
                게시판<c:if test="${not empty selectedCategory}"> · ${selectedCategory}</c:if>
            </span>
            <c:if test="${not empty sessionScope.loginMember}">
                <a href="${pageContext.request.contextPath}/board/write" class="btn">글쓰기</a>
            </c:if>
        </div>
        <table class="board-table">
            <thead>
                <tr>
                    <th style="width:60px">번호</th>
                    <th style="width:80px">분류</th>
                    <th>제목</th>
                    <th style="width:100px">작성자</th>
                    <th style="width:110px">작성일</th>
                    <th style="width:60px">조회</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="b" items="${boardList}">
                    <tr>
                        <td>${b.boardId}</td>
                        <td><c:if test="${not empty b.category}"><span class="cat-badge">${b.category}</span></c:if></td>
                        <td class="title">
                            <a href="${pageContext.request.contextPath}/board/detail/${b.boardId}">
                                <c:out value="${b.title}"/>
                            </a>
                        </td>
                        <td><c:out value="${b.writerName}"/></td>
                        <td><fmt:formatDate value="${b.regDate}" pattern="yyyy.MM.dd"/></td>
                        <td>${b.viewCnt}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty boardList}">
                    <tr><td colspan="6" style="padding:30px; color:#aaa;">게시글이 없습니다.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <div class="pagination">
        <c:forEach begin="1" end="${totalPage}" var="i">
            <a href="${pageContext.request.contextPath}/board/list?page=${i}<c:if test='${not empty selectedCategory}'>&category=${selectedCategory}</c:if>"
               class="${i == currentPage ? 'active' : ''}">${i}</a>
        </c:forEach>
    </div>

</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
