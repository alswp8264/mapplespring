<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><c:out value="${board.title}"/> - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        .cat-badge { display:inline-block; padding:2px 9px; border-radius:10px; font-size:11px; font-weight:700;
            background:#eef4ff; color:#3b7be0; margin-right:6px; }
        .media-gallery { display:flex; flex-direction:column; gap:14px; padding:0 24px 8px; }
        .media-gallery img, .media-gallery video { max-width:100%; border-radius:10px; display:block; }
        .yt-embed { position:relative; padding-bottom:56.25%; height:0; border-radius:10px; overflow:hidden; }
        .yt-embed iframe { position:absolute; top:0; left:0; width:100%; height:100%; border:0; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

    <c:if test="${param.msg == 'reported'}">
        <div class="success-msg">신고가 접수되었습니다. 관리자 확인 후 처리됩니다.</div>
    </c:if>
    <c:if test="${param.msg == 'report_dup'}">
        <div class="error-msg">이미 신고한 게시글입니다.</div>
    </c:if>
    <c:if test="${param.msg == 'banned'}">
        <div class="error-msg">신고 처리로 1시간 동안 글/댓글 작성이 제한되었습니다.</div>
    </c:if>

    <div class="post-wrap">
        <div class="post-header">
            <div class="post-title">
                <c:if test="${not empty board.category}"><span class="cat-badge">${board.category}</span></c:if>
                <c:out value="${board.title}"/>
            </div>
            <div class="post-meta">
                <span><c:out value="${board.writerName}"/></span>
                <span>${board.regDate}</span>
                <span>조회 ${board.viewCnt}</span>
            </div>
        </div>
        <%-- 게시글 내용: c:out 으로 EL injection 방지, pre-wrap 으로 줄바꿈 유지 --%>
        <div class="post-content" style="white-space:pre-wrap;">
            <c:out value="${board.content}"/>
        </div>

        <%-- 첨부 이미지/동영상 --%>
        <c:if test="${not empty fileList}">
            <div class="media-gallery">
                <c:forEach var="f" items="${fileList}">
                    <c:choose>
                        <c:when test="${f.fileType == 'youtube'}">
                            <div class="yt-embed">
                                <iframe src="https://www.youtube.com/embed/${f.fileName}"
                                        title="YouTube" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                        allowfullscreen></iframe>
                            </div>
                        </c:when>
                        <c:when test="${f.fileType == 'video'}">
                            <video controls preload="metadata">
                                <source src="${pageContext.request.contextPath}/upload/board/${f.fileName}">
                            </video>
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/upload/board/${f.fileName}" alt="<c:out value='${f.origName}'/>">
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
            </div>
        </c:if>
        <div class="post-footer">
            <a href="${pageContext.request.contextPath}/board/list" class="btn btn-gray">목록</a>
            <c:if test="${not empty sessionScope.loginMember}">
                <c:if test="${sessionScope.loginMember.memberId == board.memberId}">
                    <a href="${pageContext.request.contextPath}/board/edit/${board.boardId}" class="btn btn-outline">수정</a>
                </c:if>
                <c:if test="${sessionScope.loginMember.memberId == board.memberId or sessionScope.loginMember.role == 'ADMIN'}">
                    <form action="${pageContext.request.contextPath}/board/delete/${board.boardId}" method="post"
                          onsubmit="return confirm('삭제하시겠습니까?')" style="display:inline">
                        <button type="submit" class="btn btn-danger">삭제</button>
                    </form>
                </c:if>
                <c:if test="${sessionScope.loginMember.memberId != board.memberId}">
                    <button type="button" class="btn btn-outline" onclick="reportPost()">🚩 신고</button>
                </c:if>
            </c:if>
        </div>
        <form id="report-form" action="${pageContext.request.contextPath}/board/report" method="post" style="display:none">
            <input type="hidden" name="boardId" value="${board.boardId}">
            <input type="hidden" name="reason" id="report-reason">
        </form>
    </div>

    <%-- 댓글 --%>
    <div class="comment-wrap">
        <div class="comment-title">
            댓글 <span style="color:#4f8ef7">${commentList.size()}</span>
        </div>

        <c:forEach var="c" items="${commentList}">
            <div class="comment-item">
                <div class="comment-top">
                    <span class="comment-writer"><c:out value="${c.writerName}"/></span>
                    <span class="comment-date">${c.regDate}</span>
                    <c:if test="${not empty sessionScope.loginMember}">
                        <c:if test="${sessionScope.loginMember.memberId == c.memberId or sessionScope.loginMember.role == 'ADMIN'}">
                            <form action="${pageContext.request.contextPath}/board/comment/delete"
                                  method="post" style="display:inline; margin-left:auto">
                                <input type="hidden" name="commentId" value="${c.commentId}">
                                <input type="hidden" name="boardId" value="${board.boardId}">
                                <button type="submit" class="btn-sm">삭제</button>
                            </form>
                        </c:if>
                    </c:if>
                </div>
                <div class="comment-text"><c:out value="${c.content}"/></div>
            </div>
        </c:forEach>

        <div class="comment-input-wrap">
            <c:choose>
                <c:when test="${not empty sessionScope.loginMember}">
                    <form action="${pageContext.request.contextPath}/board/comment/write" method="post">
                        <input type="hidden" name="boardId" value="${board.boardId}">
                        <textarea name="content" placeholder="댓글을 입력하세요" required></textarea>
                        <div style="margin-top:8px; text-align:right;">
                            <button type="submit" class="btn">댓글 등록</button>
                        </div>
                    </form>
                </c:when>
                <c:otherwise>
                    <p style="font-size:13px; color:#aaa; text-align:center; padding:16px 0;">
                        <a href="${pageContext.request.contextPath}/member/login" style="color:#4f8ef7">로그인</a>
                        후 댓글을 작성할 수 있습니다.
                    </p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<script>
function reportPost(){
    var r = prompt('신고 사유를 입력하세요. (선택)\n신고가 접수되면 관리자가 확인 후 처리합니다.');
    if (r === null) return;   // 취소
    document.getElementById('report-reason').value = r;
    document.getElementById('report-form').submit();
}
</script>
</body>
</html>
