<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>룩북 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        /* ── 카드 그리드 ── */
        .lookbook-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 16px;
        }
        .lookbook-card {
            background: #fff;
            border: 1px solid #e8eaed;
            border-radius: 12px;
            overflow: hidden;
            transition: box-shadow .18s, transform .18s;
        }
        .lookbook-card:hover {
            box-shadow: 0 4px 18px rgba(0,0,0,.1);
            transform: translateY(-2px);
        }
        .lookbook-img {
            width: 100%; aspect-ratio: 3/4;
            background: #f4f5f7;
            display: flex; align-items: flex-end; justify-content: center;
            overflow: hidden;
        }
        .lookbook-img img {
            width: 100%; height: 100%;
            object-fit: contain; object-position: center bottom;
        }
        .lookbook-no-img {
            font-size: 36px; color: #ccc;
            display: flex; align-items: center; justify-content: center;
            width: 100%; height: 100%;
        }
        .lookbook-body { padding: 10px 12px 12px; }
        .lookbook-title {
            font-size: 13px; font-weight: 700; color: #1a1a2e;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
            margin-bottom: 4px;
        }
        .lookbook-char {
            font-size: 12px; color: #444;
            display: flex; justify-content: space-between; align-items: center;
        }
        .lookbook-char strong a { color: #1a73e8; text-decoration: none; }
        .lookbook-char strong a:hover { text-decoration: underline; }
        .lookbook-class { font-size: 11px; color: #888; margin: 3px 0 6px; }
        .lookbook-meta {
            display: flex; justify-content: space-between;
            align-items: center; font-size: 11px; color: #aaa;
        }

        /* ── 좋아요 버튼 ── */
        .like-btn {
            display: inline-flex; align-items: center; gap: 4px;
            border: 1px solid #e0e0e0; border-radius: 20px;
            background: #fff; cursor: pointer;
            padding: 3px 10px; font-size: 12px; color: #888;
            transition: all .15s;
        }
        .like-btn:hover { border-color: #e03e6e; color: #e03e6e; }
        .like-btn.liked {
            background: #fff0f5; border-color: #e03e6e;
            color: #e03e6e; font-weight: 700;
        }
        .like-btn .heart { font-size: 13px; }

        /* ── 카드 하단 액션 ── */
        .lookbook-footer {
            display: flex; align-items: center;
            justify-content: space-between; margin-top: 8px;
        }

        /* ── 내 룩북 구분선 ── */
        .my-section-label {
            font-size: 13px; font-weight: 700; color: #555;
            margin-bottom: 12px; display: flex; align-items: center; gap: 8px;
        }
        .my-section-label::after {
            content: ''; flex: 1; height: 1px; background: #eee;
        }

        /* ── 정렬 탭 ── */
        .sort-tabs { display: flex; gap: 8px; margin-bottom: 16px; }
        .sort-tab {
            padding: 5px 14px; border-radius: 20px; border: 1px solid #ddd;
            font-size: 13px; cursor: pointer; background: #fff; color: #666;
            transition: all .15s;
        }
        .sort-tab.active {
            background: #1a1a2e; color: #fff; border-color: #1a1a2e;
        }

        .empty-notice { text-align: center; padding: 80px 0; color: #888; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container">

    <%-- ══ 헤더 ══ --%>
    <div class="home-section-header" style="margin-bottom:20px;">
        <h1 class="home-section-title">커뮤니티 룩북</h1>
        <span style="font-size:12px; color:#aaa;">메이플러들이 공유한 코디를 구경해보세요</span>
    </div>

    <%-- ══ 내 룩북 (로그인 시) ══ --%>
    <c:if test="${not empty myList}">
        <div class="my-section-label">내가 등록한 룩</div>
        <div class="lookbook-grid" style="margin-bottom:32px;">
            <c:forEach var="lb" items="${myList}">
                <div class="lookbook-card my-card">
                    <div class="lookbook-img">
                        <c:choose>
                            <c:when test="${not empty lb.charImage}">
                                <img src="${lb.charImage}" alt="<c:out value='${lb.charName}'/>"
                                     onerror="this.style.display='none'">
                            </c:when>
                            <c:otherwise><div class="lookbook-no-img">?</div></c:otherwise>
                        </c:choose>
                    </div>
                    <div class="lookbook-body">
                        <div class="lookbook-title"><c:out value="${lb.title}"/></div>
                        <div class="lookbook-char">
                            <strong><c:out value="${lb.charName}"/></strong>
                            <span>Lv.${lb.charLevel}</span>
                        </div>
                        <div class="lookbook-class"><c:out value="${lb.charClass}"/> · <c:out value="${lb.charWorld}"/></div>
                        <div class="lookbook-footer">
                            <a href="${pageContext.request.contextPath}/character/search?charName=<c:out value='${lb.charName}'/>"
                               class="btn btn-outline" style="font-size:11px; padding:4px 10px;">캐릭터 보기</a>
                            <form action="${pageContext.request.contextPath}/lookbook/delete"
                                  method="post" style="display:inline"
                                  onsubmit="return confirm('삭제하시겠습니까?')">
                                <input type="hidden" name="lookbookId" value="${lb.lookbookId}">
                                <button type="submit" class="btn btn-danger"
                                        style="font-size:11px; padding:4px 10px;">삭제</button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
        <hr style="border:none; border-top:1px solid #eee; margin:0 0 28px;">
    </c:if>

    <%-- ══ 전체 룩북 (인기순) ══ --%>
    <div class="my-section-label">전체 룩북</div>

    <c:choose>
        <c:when test="${not empty lookbookList}">
            <div class="lookbook-grid" id="all-grid">
                <c:forEach var="lb" items="${lookbookList}">
                    <div class="lookbook-card" data-id="${lb.lookbookId}">
                        <a href="${pageContext.request.contextPath}/character/search?charName=<c:out value='${lb.charName}'/>"
                           class="lookbook-img-link">
                            <div class="lookbook-img">
                                <c:choose>
                                    <c:when test="${not empty lb.charImage}">
                                        <img src="${lb.charImage}" alt="<c:out value='${lb.charName}'/>">
                                    </c:when>
                                    <c:otherwise><div class="lookbook-no-img"><c:out value="${lb.charName}"/></div></c:otherwise>
                                </c:choose>
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
                            <div class="lookbook-class"><c:out value="${lb.charClass}"/> · <c:out value="${lb.charWorld}"/></div>
                            <div class="lookbook-footer">
                                <%-- 좋아요 버튼 --%>
                                <button class="like-btn ${lb.likedByMe == 1 ? 'liked' : ''}"
                                        data-id="${lb.lookbookId}"
                                        onclick="toggleLike(this, ${lb.lookbookId})">
                                    <span class="heart">${lb.likedByMe == 1 ? '♥' : '♡'}</span>
                                    <span class="like-count">${lb.likeCount}</span>
                                </button>
                                <div class="lookbook-meta">
                                    <span>by <c:out value="${lb.writerName}"/></span>
                                    <fmt:formatDate value="${lb.regDate}" pattern="MM.dd"/>
                                </div>
                            </div>
                            <c:if test="${sessionScope.loginMember.role == 'ADMIN'}">
                                <form action="${pageContext.request.contextPath}/lookbook/admin/delete" method="post"
                                      onsubmit="return confirm('[관리자] 이 룩북을 삭제할까요?')" style="margin-top:6px;">
                                    <input type="hidden" name="lookbookId" value="${lb.lookbookId}">
                                    <button type="submit" class="btn-sm" style="width:100%; color:#e03e3e; border-color:#f5c6c6;">관리자 삭제</button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-notice">
                <div style="font-size:36px; margin-bottom:16px;">👗</div>
                <p style="font-size:15px; font-weight:600; margin-bottom:8px;">아직 등록된 룩이 없습니다</p>
                <p style="font-size:13px;">캐릭터를 검색하고 "룩북에 등록" 버튼을 눌러 코디를 공유해보세요!</p>
                <a href="${pageContext.request.contextPath}/character/search"
                   class="btn" style="margin-top:20px; display:inline-block;">캐릭터 검색하러 가기</a>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
const CTX = '${pageContext.request.contextPath}';
const IS_LOGIN = ${not empty sessionScope.loginMember};

function toggleLike(btn, lookbookId) {
    if (!IS_LOGIN) {
        if (confirm('좋아요는 로그인이 필요합니다. 로그인하시겠습니까?')) {
            window.location.href = CTX + '/member/login';
        }
        return;
    }

    fetch(CTX + '/lookbook/like', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'lookbookId=' + lookbookId
    })
    .then(r => r.json())
    .then(data => {
        if (data.error) return;
        const heart     = btn.querySelector('.heart');
        const countEl   = btn.querySelector('.like-count');
        if (data.liked) {
            btn.classList.add('liked');
            heart.textContent = '♥';
        } else {
            btn.classList.remove('liked');
            heart.textContent = '♡';
        }
        countEl.textContent = data.likeCount;
    })
    .catch(() => {});
}
</script>
</body>
</html>
