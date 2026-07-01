<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mapple - 메이플스토리 정보 플랫폼</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        :root {
            --bg:      #0d1117;
            --bg2:     #161b22;
            --bg3:     #21262d;
            --border:  #30363d;
            --text:    #e6edf3;
            --text2:   #7d8590;
            --blue:    #58a6ff;
            --green:   #3fb950;
            --purple:  #a371f7;
            --orange:  #f0883e;
            --gold:    #e3b341;
            --red:     #f85149;
        }
        *, *::before, *::after { box-sizing: border-box; }
        body { background: var(--bg); color: var(--text); font-family: 'Segoe UI', -apple-system, 'Apple SD Gothic Neo', sans-serif; margin: 0; }
        a { text-decoration: none; color: inherit; }

        /* ══ 히어로 ══ */
        .hero {
            background: linear-gradient(180deg, #0d1117 0%, #161b22 100%);
            border-bottom: 1px solid var(--border);
            padding: 40px 0 32px;
            position: relative; overflow: hidden;
        }
        .hero::after {
            content: ''; position: absolute; inset: 0; pointer-events: none;
            background: radial-gradient(ellipse 55% 70% at 80% 50%, rgba(88,166,255,.07), transparent),
                        radial-gradient(ellipse 40% 60% at 20% 80%, rgba(163,113,247,.05), transparent);
        }
        .hero-inner {
            max-width: 1200px; margin: 0 auto; padding: 0 24px;
            display: flex; align-items: center; gap: 48px;
        }
        .hero-left { flex: 1; }
        .hero-eyebrow {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: 11px; font-weight: 700; letter-spacing: .08em;
            color: var(--blue); background: rgba(88,166,255,.1);
            border: 1px solid rgba(88,166,255,.2);
            padding: 3px 10px; border-radius: 20px; margin-bottom: 14px;
        }
        .hero-title {
            font-size: 36px; font-weight: 800; color: #fff;
            margin: 0 0 8px; line-height: 1.2;
        }
        .hero-title .leaf { color: var(--blue); }
        .hero-sub { font-size: 13px; color: var(--text2); margin: 0 0 20px; }
        .hero-search {
            display: flex; gap: 0; max-width: 460px;
            background: var(--bg3); border: 1px solid var(--border);
            border-radius: 10px; overflow: hidden;
            transition: border-color .2s;
        }
        .hero-search:focus-within { border-color: var(--blue); }
        .hero-search input {
            flex: 1; padding: 12px 16px;
            background: transparent; border: none;
            color: var(--text); font-size: 14px; outline: none;
        }
        .hero-search input::placeholder { color: var(--text2); }
        .hero-search button {
            padding: 12px 22px; background: var(--blue); border: none;
            color: #0d1117; font-weight: 700; font-size: 14px;
            cursor: pointer; transition: opacity .15s;
            font-family: inherit;
        }
        .hero-search button:hover { opacity: .85; }
        .hero-stats {
            display: flex; gap: 20px; margin-top: 18px;
        }
        .hero-stat { font-size: 12px; color: var(--text2); }
        .hero-stat strong { color: var(--text); font-weight: 700; }

        /* ══ 공통 레이아웃 ══ */
        .wrap { max-width: 1200px; margin: 0 auto; padding: 20px 24px 60px; display: flex; flex-direction: column; gap: 18px; }

        /* ══ 섹션 카드 ══ */
        .card { background: var(--bg2); border: 1px solid var(--border); border-radius: 12px; overflow: hidden; }
        .card-head {
            display: flex; align-items: center; justify-content: space-between;
            padding: 13px 18px 11px; border-bottom: 1px solid var(--border);
        }
        .card-title { font-size: 13px; font-weight: 700; display: flex; align-items: center; gap: 7px; }
        .ct-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--blue); flex-shrink: 0; }
        .ct-dot.g { background: var(--green); }
        .ct-dot.p { background: var(--purple); }
        .ct-dot.o { background: var(--orange); }
        .ct-dot.r { background: var(--red); }
        .card-more { font-size: 11px; color: var(--text2); transition: color .15s; }
        .card-more:hover { color: var(--blue); }

        /* ══ 탭 ══ */
        .tab-bar { display: flex; gap: 2px; padding: 10px 14px 0; border-bottom: 1px solid var(--border); }
        .tab {
            padding: 7px 14px; font-size: 12px; font-weight: 600;
            border: none; background: transparent; color: var(--text2);
            cursor: pointer; border-bottom: 2px solid transparent;
            margin-bottom: -1px; font-family: inherit; transition: color .15s, border-color .15s;
        }
        .tab.active { color: var(--blue); border-bottom-color: var(--blue); }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        /* ══ 이벤트 슬라이더 ══ */
        .ev-carousel { position: relative; overflow: hidden; }
        .ev-track-wrap { overflow: hidden; }
        .ev-track {
            display: flex; gap: 10px; padding: 14px 16px;
            transition: transform .45s cubic-bezier(.4,0,.2,1);
            will-change: transform;
        }
        .ev-card {
            flex-shrink: 0;
            width: calc((100% - 32px - 20px) / 3);
            background: var(--bg3); border: 1px solid var(--border);
            border-radius: 10px; overflow: hidden; transition: border-color .15s, transform .15s;
        }
        .ev-card:hover { border-color: var(--blue); transform: translateY(-2px); }
        .ev-thumb {
            width: 100%; height: 100px; overflow: hidden;
            background: linear-gradient(135deg, #1c2128, #2d333b);
            display: flex; align-items: center; justify-content: center; font-size: 28px;
        }
        .ev-thumb img { width: 100%; height: 100%; object-fit: cover; }
        .ev-body { padding: 9px 11px; }
        .ev-ttl { font-size: 11px; font-weight: 600; color: var(--text); line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .ev-date { font-size: 10px; color: var(--text2); margin-top: 4px; }
        /* 이전/다음 화살표 */
        .ev-arrow {
            position: absolute; top: 50%; transform: translateY(-50%);
            width: 28px; height: 28px; border-radius: 50%;
            background: rgba(30,36,50,.85); border: 1px solid var(--border);
            color: var(--text); font-size: 14px; font-weight: 700;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            z-index: 2; transition: background .15s, opacity .15s;
            opacity: 0; pointer-events: none;
        }
        .ev-carousel:hover .ev-arrow { opacity: 1; pointer-events: auto; }
        .ev-arrow:hover { background: rgba(88,166,255,.2); border-color: var(--blue); color: var(--blue); }
        .ev-arrow.prev { left: 6px; }
        .ev-arrow.next { right: 6px; }
        /* 도트 인디케이터 */
        .ev-dots { display: flex; justify-content: center; gap: 5px; padding: 0 0 10px; }
        .ev-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--border); cursor: pointer; transition: background .2s, width .2s; }
        .ev-dot.active { background: var(--blue); width: 18px; border-radius: 3px; }

        /* ══ 이벤트 + 패치 2열 ══ */
        .ev-patch-row { display: grid; grid-template-columns: minmax(0,1fr) 300px; gap: 18px; align-items: start; }
        .ev-patch-row > .card { min-width: 0; }

        /* ══ 패치노트 리스트 ══ */
        .patch-list { padding: 6px 0; }
        .patch-item {
            display: flex; align-items: flex-start; gap: 10px;
            padding: 11px 16px; border-bottom: 1px solid var(--border);
            transition: background .1s;
        }
        .patch-item:last-child { border-bottom: none; }
        .patch-item:hover { background: var(--bg3); }
        .patch-icon { font-size: 16px; flex-shrink: 0; margin-top: 1px; }
        .patch-ttl { font-size: 12px; font-weight: 600; color: var(--text); line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .patch-date { font-size: 10px; color: var(--text2); margin-top: 3px; }

        /* ══ 월드 배지 ══ */
        .world-badge {
            display: inline-block; font-size: 9px; font-weight: 700;
            padding: 2px 6px; border-radius: 4px; white-space: nowrap;
            background: var(--bg3); color: var(--text2);
        }

        /* ══ 2열 랭킹 ══ */
        .rank-3col { display: grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap: 18px; align-items: start; }

        .rk-list { padding: 2px 0; }
        .rk-row {
            display: flex; align-items: center; gap: 8px;
            padding: 4px 13px; cursor: pointer;
            border-bottom: 1px solid var(--border);
            transition: background .12s;
        }
        .rk-row:last-child { border-bottom: none; }
        .rk-row:hover { background: var(--bg3); }

        /* 순위 / 메달 */
        .rk-num {
            flex-shrink: 0; width: 20px; text-align: center;
            font-size: 12px; font-weight: 800; color: #4a5163;
            font-variant-numeric: tabular-nums;
        }
        .rk-num.medal {
            height: 20px; line-height: 20px; border-radius: 50%;
            color: #0d1117; font-size: 11px;
        }
        .rk-num.r1 { background: linear-gradient(135deg,#ffdf6b,#e3b341); box-shadow: 0 0 7px rgba(227,179,65,.4); }
        .rk-num.r2 { background: linear-gradient(135deg,#dbe1ea,#a8b2c0); }
        .rk-num.r3 { background: linear-gradient(135deg,#e6a066,#cd7c3a); }

        /* 아바타 */
        .rk-ava {
            flex-shrink: 0; width: 26px; height: 26px; border-radius: 6px;
            overflow: hidden; background: linear-gradient(135deg,#1c2128,#2d333b);
            border: 1px solid var(--border);
            display: flex; align-items: flex-end; justify-content: center;
        }
        .rk-ava img { width: 30px; height: auto; margin-bottom: -2px; }
        .rk-ava.union { align-items: center; font-size: 12px;
            background: linear-gradient(135deg, rgba(163,113,247,.28), rgba(88,166,255,.16)); }

        /* 이름 / 정보 */
        .rk-main { flex: 1; min-width: 0; display: flex; align-items: center; gap: 7px; }
        .rk-name {
            font-size: 12px; font-weight: 700; color: var(--text);
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex-shrink: 0; max-width: 90px;
        }
        .rk-sub { font-size: 10px; color: var(--text2); display: flex; align-items: center; gap: 5px; white-space: nowrap; overflow: hidden; }

        /* 스탯 */
        .rk-stat { flex-shrink: 0; text-align: right; }
        .rk-stat b { font-size: 12px; font-weight: 800; color: var(--blue); font-variant-numeric: tabular-nums; }
        .rk-stat.g b { color: var(--green); }
        .rk-stat small { font-size: 9px; color: var(--text2); font-weight: 600; margin-left: 3px; }

        /* ══ 커뮤니티 ══ */
        .board-tbl { width: 100%; border-collapse: collapse; }
        .board-tbl tr { border-bottom: 1px solid var(--border); transition: background .1s; }
        .board-tbl tr:last-child { border-bottom: none; }
        .board-tbl tr:hover td { background: var(--bg3); }
        .board-tbl td { padding: 10px 16px; font-size: 12px; color: var(--text2); }
        .bt-title a { display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: var(--text); font-weight: 500; }
        .bt-title a:hover { color: var(--blue); }
        .bt-writer { width: 64px; white-space: nowrap; }
        .bt-date { width: 42px; font-size: 11px; text-align: right; white-space: nowrap; }

        /* ══ 빈 상태 ══ */
        .empty-msg { padding: 28px; text-align: center; color: var(--text2); font-size: 13px; }

        @media (max-width: 960px) {
            .ev-patch-row { grid-template-columns: 1fr; }
            .rank-3col { grid-template-columns: 1fr; }
        }
        @media (max-width: 600px) {
            .hero-title { font-size: 26px; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- ══ 히어로 ══ --%>
<div class="hero">
    <div class="hero-inner">
        <div class="hero-left">
            <div class="hero-eyebrow">🍁 MAPLE STORY</div>
            <h1 class="hero-title"><span class="leaf">Mapple</span> — 메이플스토리 정보</h1>
            <p class="hero-sub">캐릭터 검색 · 랭킹 · 이벤트 · 커뮤니티</p>
            <div class="hero-search">
                <input type="text" id="heroInput" placeholder="캐릭터 이름으로 검색..."
                       onkeydown="if(event.key==='Enter')goSearch()">
                <button onclick="goSearch()">검색</button>
            </div>

            <%-- 최근 검색 칩 --%>
            <div id="recentSearchWrap" style="margin-top:10px;display:none;">
                <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                    <span style="font-size:11px;color:var(--text2);white-space:nowrap;">최근 검색</span>
                    <div id="recentSearchChips" style="display:flex;gap:5px;flex-wrap:wrap;flex:1;"></div>
                    <button id="clearRecentBtn" style="background:none;border:none;font-size:11px;color:var(--text2);cursor:pointer;padding:0;">삭제</button>
                </div>
            </div>

            <%-- 즐겨찾기 칩 (로그인 시) --%>
            <c:if test="${not empty sessionScope.loginMember}">
            <div id="favWrap" style="margin-top:8px;display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                <span style="font-size:11px;color:var(--text2);white-space:nowrap;">⭐ 즐겨찾기</span>
                <c:choose>
                    <c:when test="${not empty favList}">
                        <c:forEach var="f" items="${favList}">
                        <a href="${pageContext.request.contextPath}/character/search?charName=<c:out value='${f.charName}'/>"
                           style="background:rgba(250,204,21,.12);border:1px solid rgba(250,204,21,.25);color:#fde047;border-radius:20px;padding:3px 11px;font-size:11px;text-decoration:none;white-space:nowrap;transition:background .1s;"
                           onmouseover="this.style.background='rgba(250,204,21,.22)'" onmouseout="this.style.background='rgba(250,204,21,.12)'">
                            <c:out value="${f.charName}"/>
                        </a>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <span style="font-size:11px;color:var(--text2);">즐겨찾기한 캐릭터가 없습니다</span>
                    </c:otherwise>
                </c:choose>
            </div>
            </c:if>

            <div class="hero-stats">
                <div class="hero-stat">종합 랭킹 <strong>#1</strong>
                    <c:if test="${not empty rankList}"><strong><c:out value="${rankList[0].character_name}"/></strong></c:if>
                </div>
                <div class="hero-stat">유니온 <strong>#1</strong>
                    <c:if test="${not empty unionList}"><strong><c:out value="${unionList[0].character_name}"/></strong></c:if>
                </div>
            </div>
        </div>

    </div>
</div>

<div class="wrap">

    <%-- ══ 이벤트/캐시샵 + 패치노트 ══ --%>
    <div class="ev-patch-row">

        <%-- 이벤트 + 캐시샵 탭 슬라이더 --%>
        <div class="card">
            <div class="tab-bar">
                <button class="tab active" onclick="switchTab(this,'evP')">🎉 이벤트</button>
                <button class="tab"        onclick="switchTab(this,'csP')">🛍️ 캐시샵</button>
                <a href="${pageContext.request.contextPath}/notice/event"
                   style="margin-left:auto;font-size:11px;color:var(--text2);padding:7px 10px;align-self:center;">전체 →</a>
            </div>
            <div id="evP" class="tab-panel active">
                <c:choose>
                    <c:when test="${not empty eventList}">
                        <div class="ev-carousel" id="evCarousel">
                            <button class="ev-arrow prev" onclick="evSlide('evCarousel',-1)">&#8249;</button>
                            <div class="ev-track-wrap">
                                <div class="ev-track" id="evTrack">
                                    <c:forEach var="ev" items="${eventList}">
                                    <a href="${pageContext.request.contextPath}/notice/event/detail?noticeId=${ev.notice_id}" class="ev-card">
                                        <div class="ev-thumb">
                                            <c:choose>
                                                <c:when test="${not empty ev.thumbnail}"><img src="${ev.thumbnail}" alt="" onerror="this.parentNode.innerHTML='🎉'"></c:when>
                                                <c:otherwise>🎉</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="ev-body">
                                            <div class="ev-ttl"><c:out value="${ev.title}"/></div>
                                            <div class="ev-date"><c:out value="${ev.date_short}"/></div>
                                        </div>
                                    </a>
                                    </c:forEach>
                                </div>
                            </div>
                            <button class="ev-arrow next" onclick="evSlide('evCarousel',1)">&#8250;</button>
                            <div class="ev-dots" id="evDots"></div>
                        </div>
                    </c:when>
                    <c:otherwise><div class="empty-msg">이벤트 정보가 없습니다.</div></c:otherwise>
                </c:choose>
            </div>
            <div id="csP" class="tab-panel">
                <c:choose>
                    <c:when test="${not empty cashList}">
                        <div class="ev-carousel" id="csCarousel">
                            <button class="ev-arrow prev" onclick="evSlide('csCarousel',-1)">&#8249;</button>
                            <div class="ev-track-wrap">
                                <div class="ev-track" id="csTrack">
                                    <c:forEach var="cs" items="${cashList}">
                                    <a href="${pageContext.request.contextPath}/notice/cashshop/detail?noticeId=${cs.notice_id}" class="ev-card">
                                        <div class="ev-thumb">
                                            <c:choose>
                                                <c:when test="${not empty cs.thumbnail}"><img src="${cs.thumbnail}" alt="" onerror="this.parentNode.innerHTML='🛍️'"></c:when>
                                                <c:otherwise>🛍️</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="ev-body">
                                            <div class="ev-ttl"><c:out value="${cs.title}"/></div>
                                            <div class="ev-date"><c:out value="${cs.date_short}"/></div>
                                        </div>
                                    </a>
                                    </c:forEach>
                                </div>
                            </div>
                            <button class="ev-arrow next" onclick="evSlide('csCarousel',1)">&#8250;</button>
                            <div class="ev-dots" id="csDots"></div>
                        </div>
                    </c:when>
                    <c:otherwise><div class="empty-msg">캐시샵 정보가 없습니다.</div></c:otherwise>
                </c:choose>
                </div>
            </div>

        <%-- 패치노트 최신 5개 --%>
        <div class="card">
            <div class="card-head">
                <span class="card-title"><span class="ct-dot p"></span>패치노트</span>
                <a href="${pageContext.request.contextPath}/notice/update" class="card-more">전체 →</a>
            </div>
            <div class="patch-list">
                <c:choose>
                    <c:when test="${not empty updateList}">
                        <c:forEach var="u" items="${updateList}">
                        <a href="${pageContext.request.contextPath}/notice/update/detail?noticeId=${u.notice_id}" class="patch-item">
                            <div class="patch-icon">📝</div>
                            <div>
                                <div class="patch-ttl"><c:out value="${u.title}"/></div>
                                <div class="patch-date"><c:out value="${u.date}"/></div>
                            </div>
                        </a>
                        </c:forEach>
                    </c:when>
                    <c:otherwise><div class="empty-msg">패치노트가 없습니다.</div></c:otherwise>
                </c:choose>
            </div>
        </div>

    </div>

    <%-- ══ 랭킹 ══ --%>
    <div class="rank-3col">

        <%-- 종합 랭킹 --%>
        <div class="card">
            <div class="card-head">
                <span class="card-title"><span class="ct-dot"></span>🏆 종합 랭킹</span>
                <a href="${pageContext.request.contextPath}/ranking" class="card-more">전체 →</a>
            </div>
            <div class="rk-list">
                <c:choose>
                    <c:when test="${not empty rankList}">
                        <c:forEach var="r" items="${rankList}" varStatus="s" end="9">
                        <div class="rk-row" onclick="location.href='${pageContext.request.contextPath}/character/search?charName=${r.character_name}'">
                            <div class="rk-num ${s.index<3?'medal':''} ${s.index==0?'r1':s.index==1?'r2':s.index==2?'r3':''}"><c:out value="${r.ranking}"/></div>
                            <div class="rk-ava">
                                <c:if test="${not empty r.character_image}"><img src="${r.character_image}" alt="" onerror="this.style.display='none'"></c:if>
                            </div>
                            <div class="rk-main">
                                <div class="rk-name"><c:out value="${r.character_name}"/></div>
                                <div class="rk-sub">
                                    <span class="world-badge" data-world="${r.world_name}"><c:out value="${r.world_name}"/></span>
                                    <c:out value="${r.class_name}"/>
                                </div>
                            </div>
                            <div class="rk-stat">
                                <b>Lv.<c:out value="${r.character_level}"/></b>
                            </div>
                        </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise><div class="empty-msg">데이터 없음</div></c:otherwise>
                </c:choose>
            </div>
        </div>

        <%-- 유니온 랭킹 --%>
        <div class="card">
            <div class="card-head">
                <span class="card-title"><span class="ct-dot" style="background:var(--purple)"></span>⚡ 유니온 랭킹</span>
                <a href="${pageContext.request.contextPath}/ranking" class="card-more">전체 →</a>
            </div>
            <div class="rk-list">
                <c:choose>
                    <c:when test="${not empty unionList}">
                        <c:forEach var="u" items="${unionList}" varStatus="s">
                        <div class="rk-row" onclick="location.href='${pageContext.request.contextPath}/character/search?charName=${u.character_name}'">
                            <div class="rk-num ${s.index<3?'medal':''} ${s.index==0?'r1':s.index==1?'r2':s.index==2?'r3':''}"><c:out value="${u.ranking}"/></div>
                            <div class="rk-ava union">⚡</div>
                            <div class="rk-main">
                                <div class="rk-name"><c:out value="${u.character_name}"/></div>
                                <div class="rk-sub">
                                    <span class="world-badge" data-world="${u.world_name}"><c:out value="${u.world_name}"/></span>
                                </div>
                            </div>
                            <div class="rk-stat g">
                                <c:if test="${not empty u.union_level}"><b><c:out value="${u.union_level}"/></b><small>유니온 레벨</small></c:if>
                            </div>
                        </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise><div class="empty-msg">데이터 없음</div></c:otherwise>
                </c:choose>
            </div>
        </div>

    </div>

    <%-- ══ 커뮤니티 ══ --%>
    <div class="card">
        <div class="card-head">
            <span class="card-title"><span class="ct-dot g"></span>커뮤니티</span>
            <div style="display:flex;gap:10px;align-items:center;">
                <c:if test="${not empty sessionScope.loginMember}">
                    <a href="${pageContext.request.contextPath}/board/write"
                       style="font-size:11px;padding:4px 10px;background:var(--bg3);border:1px solid var(--border);border-radius:6px;color:var(--text);">글쓰기</a>
                </c:if>
                <a href="${pageContext.request.contextPath}/board/list" class="card-more">전체 →</a>
            </div>
        </div>
        <table class="board-tbl">
            <c:choose>
                <c:when test="${not empty recentBoards}">
                    <c:forEach var="b" items="${recentBoards}">
                    <tr>
                        <td class="bt-title">
                            <a href="${pageContext.request.contextPath}/board/detail/${b.boardId}"><c:out value="${b.title}"/></a>
                        </td>
                        <td class="bt-writer"><c:out value="${b.writerName}"/></td>
                        <td class="bt-date"><fmt:formatDate value="${b.regDate}" pattern="MM.dd"/></td>
                    </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr><td colspan="3" class="empty-msg">아직 게시글이 없습니다.</td></tr>
                </c:otherwise>
            </c:choose>
        </table>
    </div>

</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
/* 탭 전환 */
function switchTab(btn, targetId) {
    var bar = btn.closest('.tab-bar');
    bar.querySelectorAll('.tab').forEach(function(t){ t.classList.remove('active'); });
    btn.classList.add('active');
    var card = btn.closest('.card');
    card.querySelectorAll('.tab-panel').forEach(function(p){ p.classList.remove('active'); });
    document.getElementById(targetId).classList.add('active');
}

/* ══ 이벤트/캐시샵 캐러셀 ══ */
var carousels = {};

function initCarousel(id, dotsId) {
    var carousel = document.getElementById(id);
    if (!carousel) return;
    var track = carousel.querySelector('.ev-track');
    var cards = track.querySelectorAll('.ev-card');
    var total = cards.length;
    if (total === 0) return;
    var perPage = 3;
    var pages = Math.ceil(total / perPage);
    var cur = 0;

    // 도트 생성
    var dotsEl = document.getElementById(dotsId);
    for (var i = 0; i < pages; i++) {
        var dot = document.createElement('span');
        dot.className = 'ev-dot' + (i === 0 ? ' active' : '');
        dot.dataset.idx = i;
        (function(idx){ dot.onclick = function(){ goto(idx); }; })(i);
        dotsEl.appendChild(dot);
    }

    function goto(idx) {
        cur = (idx + pages) % pages;
        var cardW = cards[0].offsetWidth + 10; // gap=10
        track.style.transform = 'translateX(-' + (cur * perPage * cardW) + 'px)';
        dotsEl.querySelectorAll('.ev-dot').forEach(function(d, i){ d.classList.toggle('active', i === cur); });
    }

    carousels[id] = { goto: goto, next: function(){ goto(cur+1); }, prev: function(){ goto(cur-1); } };

    // 자동 슬라이드 (4초)
    var timer = setInterval(function(){ carousels[id].next(); }, 4000);
    carousel.addEventListener('mouseenter', function(){ clearInterval(timer); });
    carousel.addEventListener('mouseleave', function(){ timer = setInterval(function(){ carousels[id].next(); }, 4000); });
}

function evSlide(id, dir) {
    if (carousels[id]) {
        if (dir > 0) carousels[id].next(); else carousels[id].prev();
    }
}

window.addEventListener('load', function(){
    initCarousel('evCarousel', 'evDots');
    initCarousel('csCarousel', 'csDots');
});

/* 캐릭터 검색 + 최근 검색 저장 */
function goSearch() {
    var q = document.getElementById('heroInput').value.trim();
    if (!q) return;
    var list = JSON.parse(localStorage.getItem('mapple_recent') || '[]');
    list = [q, ...list.filter(function(n){ return n !== q; })].slice(0, 8);
    localStorage.setItem('mapple_recent', JSON.stringify(list));
    location.href = '${pageContext.request.contextPath}/character/search?charName=' + encodeURIComponent(q);
}

/* 최근 검색 칩 렌더링 */
(function(){
    var list = JSON.parse(localStorage.getItem('mapple_recent') || '[]');
    if (list.length === 0) return;
    var wrap = document.getElementById('recentSearchWrap');
    var chips = document.getElementById('recentSearchChips');
    wrap.style.display = 'block';
    var ctx = '${pageContext.request.contextPath}';
    list.forEach(function(name){
        var a = document.createElement('a');
        a.href = ctx + '/character/search?charName=' + encodeURIComponent(name);
        a.textContent = name;
        a.style.cssText = 'background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.15);color:#c9d1d9;border-radius:20px;padding:3px 11px;font-size:11px;text-decoration:none;white-space:nowrap;transition:background .12s;';
        a.onmouseover = function(){ this.style.background='rgba(88,166,255,0.18)'; this.style.color='#58a6ff'; };
        a.onmouseout  = function(){ this.style.background='rgba(255,255,255,0.08)'; this.style.color='#c9d1d9'; };
        chips.appendChild(a);
    });
    document.getElementById('clearRecentBtn').onclick = function(){
        localStorage.removeItem('mapple_recent');
        wrap.style.display = 'none';
    };
})();

/* 월드 배지 색상 */
var WORLD_CLR = {
    '스카니아':'#c62828','베라':'#1565c0','루나':'#6a1b9a',
    '제니스':'#e65100','크로아':'#1b5e20','유니온':'#00695c',
    '이노시스':'#37474f','레드':'#b71c1c','일리아':'#006064',
    '아케인':'#4a148c','노바':'#bf360c','리부트':'#2e7d32','리부트2':'#33691e'
};
document.querySelectorAll('[data-world]').forEach(function(el){
    var w = el.dataset.world;
    var c = WORLD_CLR[w];
    if (c) { el.style.background = c + '33'; el.style.color = c; el.style.border = '1px solid ' + c + '66'; }
});
</script>
</body>
</html>
