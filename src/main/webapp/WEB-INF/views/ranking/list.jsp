<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>랭킹 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

<div class="home-section-header" style="margin-bottom:20px;">
    <h1 class="home-section-title">랭킹</h1>
</div>

<%-- ══ 탭 + 필터 ══ --%>
<%-- type 은 hidden input 하나로만 관리 — 탭 버튼은 type="button" + JS 로 처리 --%>
<form method="get" action="${pageContext.request.contextPath}/ranking" id="rankForm">
<input type="hidden" name="type"  id="rankType"  value="${not empty type ? type : 'overall'}">
<input type="hidden" name="page"  id="rankPage"  value="1">
<div class="rank-controls">
    <%-- 탭 유형 --%>
    <div class="rank-type-tabs">
        <button type="button" onclick="switchType('overall')"
                class="rank-type-tab ${type == 'overall' or empty type ? 'active' : ''}">종합</button>
        <button type="button" onclick="switchType('union')"
                class="rank-type-tab ${type == 'union' ? 'active' : ''}">유니온</button>
    </div>

    <%-- 필터 --%>
    <div class="rank-filter-row">
        <select name="world" onchange="document.getElementById('rankForm').submit()" class="rank-select">
            <option value="">전체 월드</option>
            <option value="스카니아"  ${world == '스카니아'  ? 'selected' : ''}>스카니아</option>
            <option value="베라"      ${world == '베라'      ? 'selected' : ''}>베라</option>
            <option value="루나"      ${world == '루나'      ? 'selected' : ''}>루나</option>
            <option value="제니스"    ${world == '제니스'    ? 'selected' : ''}>제니스</option>
            <option value="크로아"    ${world == '크로아'    ? 'selected' : ''}>크로아</option>
            <option value="유니온"    ${world == '유니온'    ? 'selected' : ''}>유니온</option>
            <option value="엘리시움"  ${world == '엘리시움'  ? 'selected' : ''}>엘리시움</option>
            <option value="이노시스"  ${world == '이노시스'  ? 'selected' : ''}>이노시스</option>
            <option value="레드"      ${world == '레드'      ? 'selected' : ''}>레드</option>
            <option value="오로라"    ${world == '오로라'    ? 'selected' : ''}>오로라</option>
            <option value="아케인"    ${world == '아케인'    ? 'selected' : ''}>아케인</option>
            <option value="노바"      ${world == '노바'      ? 'selected' : ''}>노바</option>
            <option value="리부트"    ${world == '리부트'    ? 'selected' : ''}>리부트</option>
            <option value="리부트2"   ${world == '리부트2'   ? 'selected' : ''}>리부트2</option>
        </select>
        <c:if test="${type == 'overall' or empty type}">
        <input type="text" name="className" value="${className}"
               placeholder="직업 입력 (예: 나이트로드, 비숍, 아델)" class="rank-class-input">
        </c:if>
        <button type="submit" class="btn" style="padding:8px 18px; font-size:13px;">검색</button>
    </div>
</div>
</form>
<script>
function switchType(t) {
    document.getElementById('rankType').value = t;
    document.getElementById('rankPage').value = '1';
    document.getElementById('rankForm').submit();
}
</script>

<%-- ══ 안내/오류 --%>
<c:if test="${not empty filterNote}">
    <div style="padding:8px 16px; background:#f0f6ff; border-left:3px solid #4f8ef7;
                border-radius:6px; margin-bottom:12px; font-size:13px; color:#2563eb;">
        ${filterNote}
    </div>
</c:if>
<c:if test="${not empty errorMsg}">
    <div class="error-msg">${errorMsg}</div>
</c:if>

<%-- ══ 랭킹 + 직업분포 2단 --%>
<c:if test="${not empty rankList}">
<div class="rank-layout">

    <%-- 랭킹 테이블 --%>
    <div class="rank-table-wrap">
        <table class="rank-table">
            <thead>
                <tr>
                    <th style="width:52px">순위</th>
                    <th style="width:52px"></th>
                    <th>닉네임</th>
                    <th style="width:100px">직업</th>
                    <th style="width:80px">월드</th>
                    <c:choose>
                        <c:when test="${type == 'union'}">
                            <th style="width:90px">유니온 레벨</th>
                        </c:when>
                        <c:otherwise>
                            <th style="width:70px">레벨</th>
                        </c:otherwise>
                    </c:choose>
                </tr>
            </thead>
            <tbody>
            <c:forEach var="r" items="${rankList}" varStatus="s">
                <tr class="${s.index < 3 ? 'rank-top' : ''}">
                    <td class="rank-num">
                        <c:choose>
                            <c:when test="${r.ranking == 1}">&#129351;</c:when>
                            <c:when test="${r.ranking == 2}">&#129352;</c:when>
                            <c:when test="${r.ranking == 3}">&#129353;</c:when>
                            <c:otherwise>${r.ranking}</c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:if test="${not empty r.character_image}">
                            <img src="${r.character_image}" class="rank-char-img"
                                 onerror="this.style.display='none'" alt="">
                        </c:if>
                    </td>
                    <td class="rank-name">
                        <a href="${pageContext.request.contextPath}/character/search?charName=${r.character_name}">
                            <c:out value="${r.character_name}"/>
                        </a>
                        <c:if test="${not empty r.character_guildname}">
                            <span class="rank-guild">&lt;<c:out value="${r.character_guildname}"/>&gt;</span>
                        </c:if>
                    </td>
                    <td style="font-size:11px; color:#666;">
                        <c:choose>
                            <c:when test="${not empty r.sub_class_name}"><c:out value="${r.sub_class_name}"/></c:when>
                            <c:when test="${not empty r.class_name}"><c:out value="${r.class_name}"/></c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </td>
                    <td><c:out value="${r.world_name}"/></td>
                    <c:choose>
                        <c:when test="${type == 'union'}">
                            <td class="rank-score">${r.union_level}</td>
                        </c:when>
                        <c:otherwise>
                            <td class="rank-score">Lv.${r.character_level}</td>
                        </c:otherwise>
                    </c:choose>
                </tr>
            </c:forEach>
            </tbody>
        </table>

        <%-- 페이지 이동 (번호 페이지네이션) --%>
        <c:set var="qs" value="type=${type}&world=${world}&className=${className}"/>
        <c:set var="startPage" value="${page - 4 < 1 ? 1 : page - 4}"/>
        <c:set var="endPage"   value="${hasNext ? page + 5 : page}"/>
        <div class="pagination" style="margin-top:16px; flex-wrap:wrap;">
            <c:if test="${page > 1}">
                <a href="${pageContext.request.contextPath}/ranking?${qs}&page=1">&laquo;</a>
                <a href="${pageContext.request.contextPath}/ranking?${qs}&page=${page-1}" style="width:auto; padding:0 12px;">&lsaquo; 이전</a>
            </c:if>
            <c:forEach begin="${startPage}" end="${endPage}" var="p">
                <c:choose>
                    <c:when test="${p == page}">
                        <a class="active">${p}</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/ranking?${qs}&page=${p}">${p}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${hasNext}">
                <a href="${pageContext.request.contextPath}/ranking?${qs}&page=${page+1}" style="width:auto; padding:0 12px;">다음 &rsaquo;</a>
            </c:if>
        </div>
    </div>

    <%-- 직업 분포 (이번 페이지 기준) --%>
    <c:if test="${not empty classDist}">
    <div class="rank-dist-wrap">
        <div class="char-stat-card-title" style="font-size:14px; font-weight:700; margin-bottom:14px; padding-bottom:10px; border-bottom:1px solid #f0f0f0;">
            직업 분포 (이 페이지)
        </div>
        <c:set var="maxCnt" value="${classDist[0].value}"/>
        <c:forEach var="entry" items="${classDist}">
            <div class="dist-row">
                <span class="dist-class"><c:out value="${entry.key}"/></span>
                <div class="dist-bar-wrap">
                    <div class="dist-bar"
                         style="width:${entry.value * 100 / maxCnt}%"></div>
                </div>
                <span class="dist-cnt">${entry.value}명</span>
            </div>
        </c:forEach>
    </div>
    </c:if>

</div><%-- /rank-layout --%>
</c:if>

<c:if test="${empty rankList and empty errorMsg and not empty type}">
    <div class="empty-notice" style="padding:60px 0;">랭킹 데이터를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.</div>
</c:if>

</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
