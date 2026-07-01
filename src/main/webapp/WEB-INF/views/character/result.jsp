<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>
        <c:choose>
            <c:when test="${not empty charName}"><c:out value="${charName}"/> - Mapple</c:when>
            <c:otherwise>캐릭터 검색 - Mapple</c:otherwise>
        </c:choose>
    </title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
    /* ═══════════ 검색 바 ═══════════ */
    .char-search-top {
        background: #12163a;
        padding: 16px 0;
    }
    /* 흰 알약형 박스·파란 버튼은 전역 .search-box 디자인을 그대로 사용.
       여기선 폭/정렬과 '잘 보이는 어두운 글씨'만 지정 (흰 배경 위 흰 글씨 → 안 보이던 버그 수정) */
    .char-search-top .search-box {
        max-width: 540px;
        margin: 0 auto;
    }
    .char-search-top .search-box input {
        color: #1e2330;
        font-size: 15px;
    }
    .char-search-top .search-box input::placeholder {
        color: #9aa3b2;
    }

    /* ═══════════ 히어로 배너 ═══════════ */
    .char-hero {
        background: linear-gradient(135deg, #12163a 0%, #0d2060 60%, #1a2a5e 100%);
        color: #fff;
        padding: 36px 0 0;
    }
    .char-hero-inner {
        max-width: 1080px;
        margin: 0 auto;
        padding: 0 28px;
        display: flex;
        gap: 32px;
        align-items: flex-start;
    }
    /* 아바타 */
    .char-hero-avatar {
        flex-shrink: 0;
        width: 132px;
        height: 150px;
        overflow: hidden;
        position: relative;
        border-radius: 14px;
        background: rgba(255,255,255,0.06);
    }
    /* 원본 300x300 중 캐릭터는 중앙 작은 영역만 차지 → 확대 후 캐릭터 영역만 보이게 crop */
    .char-hero-avatar img {
        position: absolute;
        width: 480px;
        height: 480px;
        max-width: none;
        left: -174px;
        top: -188px;
    }
    /* 정보 영역 */
    .char-hero-body {
        flex: 1;
        min-width: 0;
        padding-bottom: 24px;
    }
    .char-hero-name-row {
        display: flex;
        align-items: center;
        gap: 10px;
        flex-wrap: wrap;
        margin-bottom: 4px;
    }
    .char-hero-name {
        font-size: 30px;
        font-weight: 900;
        letter-spacing: -0.5px;
        color: #fff;
    }
    .char-hero-world-badge {
        background: rgba(79,142,247,0.22);
        border: 1px solid rgba(79,142,247,0.45);
        color: #7eb3ff;
        border-radius: 20px;
        padding: 4px 12px;
        font-size: 12px;
        font-weight: 700;
    }
    .char-hero-class-row {
        font-size: 15px;
        color: rgba(255,255,255,0.65);
        margin-bottom: 6px;
    }
    .char-hero-class-row strong { color: #fff; }
    .char-hero-guild {
        font-size: 12px;
        color: rgba(255,255,255,0.45);
        margin-bottom: 18px;
    }
    /* 유니온 / 인기도 */
    .char-hero-meta {
        display: flex;
        gap: 28px;
        flex-wrap: wrap;
        margin-bottom: 20px;
    }
    .char-hero-meta-item { text-align: left; }
    .char-hero-meta-label {
        font-size: 10px;
        color: rgba(255,255,255,0.45);
        letter-spacing: 0.6px;
        text-transform: uppercase;
        display: block;
        margin-bottom: 2px;
    }
    .char-hero-meta-val {
        font-size: 20px;
        font-weight: 800;
        color: #fff;
        display: block;
    }
    .char-hero-meta-sub {
        font-size: 11px;
        color: rgba(255,255,255,0.5);
        display: block;
        margin-top: 1px;
    }
    /* 액션 버튼 */
    .char-hero-actions {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }
    .hero-btn {
        padding: 8px 16px;
        border-radius: 10px;
        font-size: 12px;
        font-weight: 700;
        border: none;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: opacity 0.15s, transform 0.1s;
        white-space: nowrap;
    }
    .hero-btn:hover { opacity: 0.82; transform: translateY(-1px); }
    .hero-btn-primary { background: #4f8ef7; color: #fff; }
    .hero-btn-purple  { background: linear-gradient(135deg,#7c3aed,#a855f7); color: #fff; }
    .hero-btn-gray    { background: rgba(255,255,255,0.14); color: #e0e8ff; }

    /* ═══════════ 핵심 스탯 바 ═══════════ */
    .char-stat-bar {
        background: rgba(0,0,0,0.30);
        border-top: 1px solid rgba(255,255,255,0.08);
        padding: 0;
        margin-top: 4px;
    }
    .char-stat-bar-inner {
        max-width: 1080px;
        margin: 0 auto;
        padding: 0 28px;
        display: flex;
        flex-wrap: wrap;
    }
    .hero-stat-cell {
        flex: 1;
        min-width: 100px;
        padding: 14px 16px;
        border-right: 1px solid rgba(255,255,255,0.07);
        text-align: center;
    }
    .hero-stat-cell:last-child { border-right: none; }
    .hero-stat-lbl {
        font-size: 10px;
        color: rgba(255,255,255,0.42);
        display: block;
        margin-bottom: 4px;
        text-transform: uppercase;
        letter-spacing: 0.4px;
    }
    .hero-stat-num {
        font-size: 17px;
        font-weight: 800;
        display: block;
        color: #fff;
    }
    .hero-stat-num.boss   { color: #ff9f43; }
    .hero-stat-num.ignore { color: #54d86c; }
    .hero-stat-num.final  { color: #a78bfa; }
    .hero-stat-num.crit   { color: #67e8f9; }
    .hero-stat-num.cp     { color: #60a5fa; }

    /* ═══════════ 탭 ═══════════ */
    .char-tabs-bar {
        background: #fff;
        border-bottom: 2px solid #ebebf0;
        position: sticky;
        top: 0;
        z-index: 100;
        box-shadow: 0 2px 10px rgba(0,0,0,0.07);
    }
    .char-tabs-bar-inner {
        max-width: 1080px;
        margin: 0 auto;
        padding: 0 20px;
        display: flex;
        gap: 0;
    }
    .char-tab {
        padding: 16px 24px;
        background: none;
        border: none;
        border-bottom: 3px solid transparent;
        font-size: 14px;
        font-weight: 600;
        color: #aaa;
        cursor: pointer;
        margin-bottom: -2px;
        transition: color 0.15s;
        white-space: nowrap;
    }
    .char-tab:hover { color: #4f8ef7; }
    .char-tab.active { color: #4f8ef7; border-bottom-color: #4f8ef7; }

    /* ═══════════ 컨텐츠 영역 ═══════════ */
    .char-content {
        max-width: 1080px;
        margin: 0 auto;
        padding: 28px 28px;
    }
    .char-tab-content { display: none; }
    .char-tab-content.active { display: block; }

    /* ═══════════ 슬롯 레이아웃 (메아기 스타일) ═══════════ */
    .slot-3col {
        display: grid;
        grid-template-columns: 1fr 150px 1fr;
        gap: 10px;
        align-items: start;
    }
    .slot-col { display: flex; flex-direction: column; gap: 5px; }
    .slot-col-center {
        display: flex; flex-direction: column; align-items: center;
        padding-top: 10px; position: sticky; top: 70px;
    }
    .slot-col-center img {
        width: 150px; height: auto;
        filter: drop-shadow(0 4px 24px rgba(79,142,247,.5));
    }

    /* 개별 슬롯 카드 */
    .eq-slot {
        display: flex; align-items: center; gap: 8px;
        background: #fff; border: 1.5px solid #ebebf0;
        border-radius: 10px; padding: 7px 9px;
        position: relative; cursor: pointer;
        transition: box-shadow .15s, border-color .15s;
        min-height: 50px; overflow: visible;
    }
    .eq-slot:hover { box-shadow: 0 3px 14px rgba(0,0,0,.1); }
    .eq-slot.grade-legendary { border-color: rgba(22,163,74,.85); background:rgba(22,163,74,.04); }
    .eq-slot.grade-unique    { border-color: rgba(202,138,4,.85);  background:rgba(202,138,4,.04); }
    .eq-slot.grade-epic      { border-color: rgba(124,58,237,.85); background:rgba(124,58,237,.04); }
    .eq-slot.grade-rare      { border-color: rgba(37,99,235,.85);  background:rgba(37,99,235,.04); }
    .eq-slot.eq-empty {
        background: #f9f9fb; border-style: dashed;
        border-color: #e0e0e8; cursor: default; opacity: .55;
    }
    .eq-slot-icon-wrap {
        width: 38px; height: 38px; flex-shrink: 0;
        background: #f4f5f8; border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        position: relative;
    }
    .eq-slot-icon-wrap img { width: 30px; height: 30px; object-fit: contain; }
    .eq-slot-star {
        position: absolute; bottom: -4px; right: -5px;
        background: #ff9f43; color: #fff;
        font-size: 8px; font-weight: 900;
        border-radius: 5px; padding: 1px 3px; white-space: nowrap;
    }
    .eq-slot-text { flex: 1; min-width: 0; }
    .eq-slot-lbl  { font-size: 9px; color: #bbb; margin-bottom: 1px; letter-spacing: .3px; }
    .eq-slot-nm   {
        font-size: 11px; font-weight: 600; color: #1a1a2e;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .eq-slot-gbadge {
        display: inline-block; font-size: 9px; font-weight: 700;
        border-radius: 4px; padding: 1px 5px; margin-top: 2px;
    }
    .eq-slot-gbadge.grade-legendary { background:#dcfce7; color:#15803d; border:1px solid rgba(22,163,74,.3); }
    .eq-slot-gbadge.grade-unique    { background:#fef9c3; color:#a16207; border:1px solid rgba(202,138,4,.3); }
    .eq-slot-gbadge.grade-epic      { background:#f5f3ff; color:#6d28d9; border:1px solid rgba(124,58,237,.3); }
    .eq-slot-gbadge.grade-rare      { background:#eff6ff; color:#1e40af; border:1px solid rgba(37,99,235,.3); }

    /* 툴팁 */
    .eq-tt {
        display: none; position: absolute;
        left: calc(100% + 6px); top: 0;
        z-index: 300;
        background: #16182a; color: #dde2f0;
        border-radius: 12px; padding: 12px 14px;
        min-width: 210px; max-width: 270px;
        box-shadow: 0 8px 32px rgba(0,0,0,.4);
        pointer-events: none; white-space: normal;
        border: 1px solid rgba(255,255,255,.08);
    }
    .eq-slot:hover .eq-tt { display: block; }
    .eq-tt.tt-r { left: auto; right: calc(100% + 6px); }
    .eq-tt-nm   { font-size: 13px; font-weight: 800; margin-bottom: 3px; }
    .eq-tt-sf   { font-size: 11px; color: #ff9f43; margin-bottom: 2px; }
    .eq-tt-soul { font-size: 11px; color: #a78bfa; margin-bottom: 4px; }
    .eq-tt-sep  { height: 1px; background: rgba(255,255,255,.1); margin: 6px 0; }
    .eq-tt-glabel {
        font-size: 10px; font-weight: 800; letter-spacing: .4px;
        text-transform: uppercase; margin-bottom: 3px;
    }
    .eq-tt-glabel.grade-legendary { color: #4ade80; }
    .eq-tt-glabel.grade-unique    { color: #fbbf24; }
    .eq-tt-glabel.grade-epic      { color: #c084fc; }
    .eq-tt-glabel.grade-rare      { color: #93c5fd; }
    .eq-tt-nm.grade-legendary { color: #4ade80; }
    .eq-tt-nm.grade-unique    { color: #fbbf24; }
    .eq-tt-nm.grade-epic      { color: #c084fc; }
    .eq-tt-nm.grade-rare      { color: #93c5fd; }
    .eq-slot-nm.grade-legendary { color: #15803d; font-weight: 700; }
    .eq-slot-nm.grade-unique    { color: #a16207; font-weight: 700; }
    .eq-slot-nm.grade-epic      { color: #6d28d9; font-weight: 700; }
    .eq-slot-nm.grade-rare      { color: #1e40af; font-weight: 700; }
    .eq-tt-addlabel {
        font-size: 10px; font-weight: 800; letter-spacing: .4px;
        text-transform: uppercase; margin-bottom: 3px;
    }
    .eq-tt-addlabel.grade-legendary { color: #4ade80; }
    .eq-tt-addlabel.grade-unique    { color: #fbbf24; }
    .eq-tt-addlabel.grade-epic      { color: #c084fc; }
    .eq-tt-addlabel.grade-rare      { color: #93c5fd; }
    .eq-tt-opt  { font-size: 11px; color: #c8d0e0; line-height: 1.65; }
    .eq-tt-opt.add { color: #86efac; }
    .eq-tt-statlabel { font-size:10px; font-weight:700; color:rgba(255,255,255,.4); letter-spacing:.4px; margin:4px 0 3px; text-transform:uppercase; }
    .eq-tt-stat { display:flex; justify-content:space-between; gap:14px; font-size:11px; color:#b8c2d8; line-height:1.65; }
    .eq-tt-stat-v { color:#e0e8ff; font-weight:700; }
    .eq-tt-scroll { font-size:11px; color:#fcd34d; margin-bottom:1px; }
    .eq-tt-soul  { font-size:11px; color:#a78bfa; margin-bottom:2px; }

    @media (max-width: 768px) {
        .slot-3col { grid-template-columns: 1fr 110px 1fr; }
        .slot-col-center img { width: 110px; }
        .eq-tt { display: none !important; }
    }

    /* ═══════════ 코디 그리드 ═══════════ */
    .codi-preset-tabs {
        display: flex;
        gap: 6px;
        margin-bottom: 18px;
        flex-wrap: wrap;
    }
    .codi-preset-tab {
        padding: 7px 18px;
        border-radius: 20px;
        border: 1.5px solid #e5e7eb;
        background: #fff;
        font-size: 13px;
        font-weight: 600;
        color: #aaa;
        cursor: pointer;
        transition: all 0.15s;
    }
    .codi-preset-tab.active { background: #4f8ef7; color: #fff; border-color: #4f8ef7; }
    .codi-preset-content { display: none; }
    .codi-preset-content.active { display: block; }
    .codi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
        gap: 12px;
    }
    .codi-item {
        background: #fff;
        border: 1.5px solid #f0f0f5;
        border-radius: 14px;
        padding: 14px 10px;
        text-align: center;
        transition: box-shadow 0.12s;
    }
    .codi-item:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.09); }
    .codi-item img { width: 60px; height: 60px; object-fit: contain; margin-bottom: 8px; }
    .codi-part { font-size: 10px; color: #aaa; margin-bottom: 2px; }
    .codi-name { font-size: 11px; font-weight: 600; color: #333; word-break: break-all; line-height: 1.3; }

    /* ═══════════ 전체 스탯 ═══════════ */
    .stat-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 8px;
    }
    .stat-item {
        background: #fff;
        border: 1px solid #f0f0f5;
        border-radius: 10px;
        padding: 10px 16px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .stat-name { font-size: 12px; color: #666; }
    .stat-val  { font-size: 13px; font-weight: 700; color: #1a1a2e; }

    /* ═══════════ 유니온 탭 ═══════════ */
    .union-summary-bar {
        display: flex;
        gap: 0;
        background: linear-gradient(135deg, #0d2060, #1a3a8a);
        border-radius: 16px;
        overflow: hidden;
        margin-bottom: 24px;
        color: #fff;
    }
    .union-summary-item {
        flex: 1;
        padding: 18px 24px;
        border-right: 1px solid rgba(255,255,255,0.1);
        text-align: center;
    }
    .union-summary-item:last-child { border-right: none; }
    .union-summary-label { font-size: 10px; color: rgba(255,255,255,0.5); display: block; margin-bottom: 4px; letter-spacing: 0.5px; }
    .union-summary-val   { font-size: 22px; font-weight: 800; display: block; }
    .union-summary-val.grade { font-size: 14px; color: #ffd700; }
    .union-section-title {
        font-size: 14px;
        font-weight: 700;
        color: #333;
        margin-bottom: 12px;
        padding-bottom: 8px;
        border-bottom: 2px solid #f0f0f5;
    }
    .union-block-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 8px;
        margin-bottom: 8px;
    }
    .union-block-card {
        background: #fff;
        border: 1px solid #f0f0f5;
        border-radius: 12px;
        padding: 10px 14px;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .union-block-rank {
        width: 26px;
        height: 26px;
        border-radius: 50%;
        background: #eef2ff;
        color: #4f8ef7;
        font-size: 11px;
        font-weight: 800;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .union-block-class { font-size: 12px; font-weight: 700; color: #222; }
    .union-block-level { font-size: 11px; color: #888; }
    .union-stat-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 8px;
    }
    .union-stat-item {
        background: #fff;
        border: 1px solid #f0f0f5;
        border-radius: 10px;
        padding: 10px 14px;
        font-size: 12px;
        color: #444;
    }

    /* ═══════════ 본캐/부캐 카드 ═══════════ */
    #alts-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(196px, 1fr));
        gap: 10px;
    }
    .alt-card {
        background: #fff;
        border: 1.5px solid #ebebf0;
        border-radius: 14px;
        padding: 12px;
        display: flex;
        gap: 10px;
        align-items: center;
        cursor: pointer;
        text-decoration: none;
        color: inherit;
        transition: box-shadow 0.12s, transform 0.1s;
    }
    .alt-card:hover { box-shadow: 0 4px 18px rgba(0,0,0,0.09); transform: translateY(-2px); }
    .alt-card.main  { border-color: #4f8ef7; background: #f0f6ff; }
    .alt-card-img {
        width: 58px;
        height: 58px;
        object-fit: contain;
        flex-shrink: 0;
        border-radius: 10px;
        background: #f5f5fa;
    }
    .alt-card-img-ph {
        width: 58px; height: 58px;
        background: #f0f0f5; border-radius: 10px; flex-shrink: 0;
    }
    .alt-card-body { flex: 1; min-width: 0; overflow: hidden; }
    .alt-card-name {
        font-size: 13px; font-weight: 800;
        color: #1a1a2e;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        margin-bottom: 2px;
    }
    .alt-card-name .main-badge {
        background: #4f8ef7; color: #fff; font-size: 9px;
        font-weight: 700; border-radius: 5px; padding: 1px 5px;
        margin-right: 4px; vertical-align: middle;
    }
    .alt-card-class { font-size: 11px; color: #666; margin-bottom: 2px; }
    .alt-card-guild { font-size: 10px; color: #aaa; margin-bottom: 2px; }
    .alt-card-cp    { font-size: 11px; font-weight: 700; color: #4f8ef7; }
    .alts-load-msg  { text-align:center; padding:50px 0; color:#aaa; font-size:13px; }

    /* 빈 상태 */
    .empty-notice { text-align: center; padding: 60px 0; color: #bbb; font-size: 14px; }

    /* ═══════════ 섹션 공통 ═══════════ */
    .sec-title {
        font-size: 13px; font-weight: 800; color: #3a3d5c;
        margin: 20px 0 10px; padding-bottom: 7px;
        border-bottom: 2px solid #f0f0f6;
        display: flex; align-items: center; gap: 6px;
    }

    /* ═══════════ 코어 공통 카드 ═══════════ */
    .core-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(190px, 1fr));
        gap: 9px; margin-bottom: 22px;
    }
    .core-card {
        background: #fff; border: 1.5px solid #eaeaf2;
        border-radius: 14px; padding: 13px 14px;
        transition: box-shadow .12s;
    }
    .core-card:hover { box-shadow: 0 4px 14px rgba(0,0,0,.08); }
    .core-badge {
        display: inline-block; font-size: 9px; font-weight: 800;
        border-radius: 5px; padding: 2px 7px; margin-bottom: 6px;
        letter-spacing: .3px;
    }
    .type-skill   { background: #dbeafe; color: #1d4ed8; }
    .type-master  { background: #f3e8ff; color: #6d28d9; }
    .type-enhance { background: #fef3c7; color: #92400e; }
    .type-common  { background: #f3f4f6; color: #4b5563; }
    .core-name {
        font-size: 13px; font-weight: 700; color: #1a1a2e;
        margin-bottom: 8px; line-height: 1.35;
    }
    .core-lv-row {
        display: flex; align-items: center; gap: 6px;
        font-size: 12px; color: #888;
    }
    .core-lv-num { font-size: 15px; font-weight: 800; color: #333; line-height: 1; }
    .core-lv-bar {
        flex: 1; height: 4px; background: #ebebf5; border-radius: 10px; overflow: hidden;
    }
    .core-lv-fill {
        height: 100%; border-radius: 10px;
        background: linear-gradient(90deg, #4f8ef7, #7c3aed);
    }
    .linked-tags { display: flex; flex-wrap: wrap; gap: 3px; margin-top: 8px; }
    .linked-tag  {
        font-size: 10px; color: #2563eb; background: #eff6ff;
        border-radius: 4px; padding: 1px 6px; font-weight: 600;
    }

    /* ═══════════ 헥사 스탯 ═══════════ */
    .hexastat-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
        gap: 9px; margin-bottom: 22px;
    }
    .hexastat-card {
        background: linear-gradient(135deg,#f8f9ff,#fff);
        border: 1.5px solid #e8ebf8; border-radius: 14px;
        padding: 13px 15px;
    }
    .hexastat-slot {
        font-size: 9px; font-weight: 800; color: #7c3aed;
        letter-spacing: .6px; margin-bottom: 7px; text-transform: uppercase;
    }
    .hexastat-row {
        display: flex; justify-content: space-between;
        align-items: center; margin-bottom: 4px;
    }
    .hexastat-mname { font-size: 13px; font-weight: 700; color: #1a1a2e; }
    .hexastat-sname { font-size: 11px; color: #666; }
    .hexastat-mlv {
        font-size: 11px; font-weight: 700;
        background: #4f8ef7; color: #fff;
        border-radius: 5px; padding: 1px 7px;
    }
    .hexastat-slv {
        font-size: 11px; font-weight: 700;
        background: #e0edff; color: #1d4ed8;
        border-radius: 5px; padding: 1px 6px;
    }

    /* ═══════════ 유니온 아티팩트 ═══════════ */
    .artifact-ap {
        background: linear-gradient(135deg,#1a1f4e,#2d3a8c);
        color: #fff; border-radius: 14px; padding: 14px 20px;
        margin-bottom: 18px; display: inline-flex;
        align-items: center; gap: 14px;
    }
    .artifact-ap-lbl { font-size: 11px; color: rgba(255,255,255,.5); }
    .artifact-ap-val { font-size: 22px; font-weight: 800; }
    .crystal-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(190px, 1fr));
        gap: 9px; margin-bottom: 22px;
    }
    .crystal-card {
        background: #fff; border: 1.5px solid #eaeaf2;
        border-radius: 14px; padding: 13px 14px;
    }
    .crystal-name { font-size: 12px; font-weight: 700; color: #1a1a2e; margin-bottom: 5px; }
    .crystal-lv {
        display: inline-block; font-size: 10px; font-weight: 700;
        background: #4f8ef7; color: #fff;
        border-radius: 5px; padding: 1px 7px; margin-bottom: 8px;
    }
    .crystal-opt {
        font-size: 11px; color: #555; line-height: 1.9; padding-left: 2px;
    }
    .crystal-opt::before { content: '▸'; color: #4f8ef7; margin-right: 4px; font-size: 9px; }
    .effect-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
        gap: 7px; margin-bottom: 12px;
    }
    .effect-item {
        background: #fff; border: 1px solid #eaeaf2;
        border-radius: 10px; padding: 9px 14px;
        display: flex; justify-content: space-between; align-items: center;
    }
    .effect-name { font-size: 12px; color: #444; }
    .effect-lv {
        font-size: 11px; font-weight: 700;
        color: #6d28d9; background: #f3e8ff;
        border-radius: 5px; padding: 1px 7px;
    }

    /* 반응형 */
    @media (max-width: 720px) {
        .char-hero-inner { flex-direction: column; align-items: center; gap: 16px; }
        .char-hero-body  { text-align: center; }
        .char-hero-meta  { justify-content: center; }
        .char-hero-actions { justify-content: center; }
        .char-hero-name  { font-size: 22px; }
        .hero-stat-cell  { min-width: 80px; padding: 10px 8px; }
        .hero-stat-num   { font-size: 14px; }
        .char-tab        { padding: 12px 14px; font-size: 13px; }
        .char-content    { padding: 18px 16px; }
    }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- 검색 바 --%>
<div class="char-search-top">
    <form action="${pageContext.request.contextPath}/character/search" method="get"
          onsubmit="saveRecentSearch(this.charName.value)">
        <div class="search-box">
            <input type="text" name="charName" placeholder="캐릭터 닉네임 입력"
                   value="<c:out value='${charName}'/>">
            <button type="submit">검색</button>
        </div>
    </form>
    <div id="recentWrap" style="max-width:540px;margin:8px auto 0;display:none;">
        <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
            <span style="font-size:11px;color:#9ba3b4;white-space:nowrap;">최근 검색</span>
            <div id="recentChips" style="display:flex;gap:5px;flex-wrap:wrap;"></div>
            <button onclick="clearRecent()" style="background:none;border:none;font-size:11px;color:#9ba3b4;cursor:pointer;margin-left:auto;">전체 삭제</button>
        </div>
    </div>
</div>
<script>
(function(){
    var ctx = '${pageContext.request.contextPath}';
    function saveRecentSearch(name){
        if(!name||!name.trim())return;
        var list=JSON.parse(localStorage.getItem('mapple_recent')||'[]');
        list=[name.trim(),...list.filter(function(n){return n!==name.trim();})].slice(0,8);
        localStorage.setItem('mapple_recent',JSON.stringify(list));
    }
    window.saveRecentSearch=saveRecentSearch;
    window.clearRecent=function(){
        localStorage.removeItem('mapple_recent');
        document.getElementById('recentWrap').style.display='none';
    };
    var current='${charName}';
    if(current) saveRecentSearch(current);
    var list=JSON.parse(localStorage.getItem('mapple_recent')||'[]');
    if(list.length>0){
        var wrap=document.getElementById('recentWrap');
        var chips=document.getElementById('recentChips');
        wrap.style.display='block';
        list.forEach(function(name){
            var btn=document.createElement('a');
            btn.href=ctx+'/character/search?charName='+encodeURIComponent(name);
            btn.textContent=name;
            btn.style.cssText='background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.15);color:#c9d1d9;border-radius:20px;padding:3px 10px;font-size:11px;text-decoration:none;white-space:nowrap;transition:background .1s;';
            btn.onmouseover=function(){this.style.background='rgba(79,142,247,0.2)';};
            btn.onmouseout=function(){this.style.background='rgba(255,255,255,0.08)';};
            chips.appendChild(btn);
        });
    }
})();
</script>

<%-- 빈 상태 --%>
<c:if test="${empty charName}">
    <div style="text-align:center; padding:100px 0; color:#aaa;">
        <div style="font-size:44px; margin-bottom:18px;">🔍</div>
        <p style="font-size:17px; font-weight:700; margin-bottom:8px; color:#555;">캐릭터 닉네임을 검색해보세요</p>
        <p style="font-size:13px;">메이플스토리 캐릭터의 장비, 스탯, 유니온 정보를 확인할 수 있습니다</p>
    </div>
</c:if>

<%-- 오류 --%>
<c:if test="${not empty errorMsg}">
    <div class="error-msg" style="max-width:600px; margin:60px auto;">
        <c:out value="${errorMsg}"/>
    </div>
</c:if>

<%-- ════════════════ 메인 캐릭터 페이지 ════════════════ --%>
<c:if test="${not empty basic}">

<%-- ── 히어로 배너 ── --%>
<div class="char-hero">
    <div class="char-hero-inner">

        <%-- 아바타 --%>
        <div class="char-hero-avatar">
            <img src="${basic.character_image}" alt="${charName}"
                 onerror="this.style.display='none'">
        </div>

        <%-- 기본 정보 --%>
        <div class="char-hero-body">
            <div class="char-hero-name-row">
                <span class="char-hero-name"><c:out value="${charName}"/></span>
                <span class="char-hero-world-badge"><c:out value="${basic.world_name}"/></span>
            </div>
            <div class="char-hero-class-row">
                Lv.<strong>${basic.character_level}</strong>
                &nbsp;·&nbsp;<c:out value="${basic.character_class}"/>
            </div>
            <c:if test="${not empty basic.character_guild_name}">
                <div class="char-hero-guild">&lt;<c:out value="${basic.character_guild_name}"/>&gt; 길드</div>
            </c:if>

            <%-- 유니온 / 인기도 / 등급 --%>
            <div class="char-hero-meta">
                <c:if test="${not empty unionLevel}">
                    <div class="char-hero-meta-item">
                        <span class="char-hero-meta-label">유니온</span>
                        <span class="char-hero-meta-val">${unionLevel}</span>
                    </div>
                </c:if>
                <c:if test="${not empty popularity}">
                    <div class="char-hero-meta-item">
                        <span class="char-hero-meta-label">인기도</span>
                        <span class="char-hero-meta-val">${popularity}</span>
                    </div>
                </c:if>
                <c:if test="${not empty unionGrade}">
                    <div class="char-hero-meta-item">
                        <span class="char-hero-meta-label">유니온 등급</span>
                        <span class="char-hero-meta-val" style="font-size:13px; color:#ffd700;"><c:out value="${unionGrade}"/></span>
                    </div>
                </c:if>
            </div>

            <%-- 액션 버튼 --%>
            <div class="char-hero-actions">
                <c:choose>
                    <c:when test="${not empty sessionScope.loginMember}">
                        <c:choose>
                            <c:when test="${isFavorite}">
                                <form action="${pageContext.request.contextPath}/character/favorite/delete"
                                      method="post" style="display:inline">
                                    <input type="hidden" name="favId" value="${favId}">
                                    <input type="hidden" name="charName" value="<c:out value='${charName}'/>">
                                    <button type="submit" class="hero-btn" style="background:rgba(250,204,21,.18);color:#fde047;border:1px solid rgba(250,204,21,.3);">★ 즐겨찾기됨</button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/character/favorite/add"
                                      method="post" style="display:inline">
                                    <input type="hidden" name="charName" value="<c:out value='${charName}'/>">
                                    <button type="submit" class="hero-btn hero-btn-gray">☆ 즐겨찾기</button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                        <button onclick="openLookbookModal()" class="hero-btn hero-btn-purple">👗 룩북 등록</button>
                        <button onclick="saveSpec()" class="hero-btn hero-btn-gray">📊 스펙 저장</button>
                        <a href="${pageContext.request.contextPath}/character/history?charName=<c:out value='${charName}'/>"
                           class="hero-btn hero-btn-gray">📈 스펙 히스토리</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/member/login"
                           class="hero-btn hero-btn-primary">로그인 후 즐겨찾기/저장 가능</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <%-- 핵심 스탯 바 --%>
    <c:if test="${not empty statMap}">
    <div class="char-stat-bar">
        <div class="char-stat-bar-inner">
            <c:if test="${not empty combatPowerText}">
            <div class="hero-stat-cell">
                <span class="hero-stat-lbl">전투력</span>
                <span class="hero-stat-num cp">${combatPowerText}</span>
            </div>
            </c:if>
            <c:if test="${not empty statMap['보스 몬스터 데미지']}">
            <div class="hero-stat-cell">
                <span class="hero-stat-lbl">보스 데미지</span>
                <span class="hero-stat-num boss">${statMap['보스 몬스터 데미지']}%</span>
            </div>
            </c:if>
            <c:if test="${not empty statMap['방어율 무시']}">
            <div class="hero-stat-cell">
                <span class="hero-stat-lbl">방어율 무시</span>
                <span class="hero-stat-num ignore">${statMap['방어율 무시']}%</span>
            </div>
            </c:if>
            <c:if test="${not empty statMap['최종 데미지']}">
            <div class="hero-stat-cell">
                <span class="hero-stat-lbl">최종 데미지</span>
                <span class="hero-stat-num final">${statMap['최종 데미지']}%</span>
            </div>
            </c:if>
            <c:if test="${not empty statMap['크리티컬 확률']}">
            <div class="hero-stat-cell">
                <span class="hero-stat-lbl">크리티컬 확률</span>
                <span class="hero-stat-num crit">${statMap['크리티컬 확률']}%</span>
            </div>
            </c:if>
            <c:if test="${not empty statMap['크리티컬 데미지']}">
            <div class="hero-stat-cell">
                <span class="hero-stat-lbl">크리티컬 데미지</span>
                <span class="hero-stat-num crit">${statMap['크리티컬 데미지']}%</span>
            </div>
            </c:if>
            <c:if test="${not empty statMap['공격력']}">
            <div class="hero-stat-cell">
                <span class="hero-stat-lbl">공격력</span>
                <span class="hero-stat-num">${statMap['공격력']}</span>
            </div>
            </c:if>
        </div>
    </div>
    </c:if>
</div><%-- /char-hero --%>

<%-- ── 탭 바 ── --%>
<div class="char-tabs-bar">
    <div class="char-tabs-bar-inner">
        <button class="char-tab active" onclick="showTab('equip',this)">⚔ 장비</button>
        <button class="char-tab"        onclick="showTab('codi',this)">👗 캐시/코디</button>
        <button class="char-tab"        onclick="showTab('stat',this)">📊 전체 스탯</button>
        <button class="char-tab"        onclick="showTab('union',this)">🔗 유니온</button>
        <button class="char-tab"        onclick="showTab('artifact',this)">🏺 아티팩트</button>
    </div>
</div>

<%-- ── 탭 컨텐츠 ── --%>
<div style="background:#f6f7fb; min-height:400px;">
<div class="char-content">

    <%-- 탭 1: 장비 (메아기 스타일 슬롯 레이아웃) --%>
    <div id="tab-equip" class="char-tab-content active">
        <c:choose>
            <c:when test="${not empty equipMapJson}">
                <div class="slot-3col">
                    <div class="slot-col" id="slot-left"></div>
                    <div class="slot-col-center"></div>
                    <div class="slot-col" id="slot-right"></div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-notice">장비 정보를 불러올 수 없습니다.</div>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- 탭 2: 캐시/코디 --%>
    <div id="tab-codi" class="char-tab-content">
        <div class="codi-preset-tabs">
            <button class="codi-preset-tab active" onclick="showCodi('base',this)">착용 중</button>
            <button class="codi-preset-tab" onclick="showCodi('preset1',this)">코디 1</button>
            <button class="codi-preset-tab" onclick="showCodi('preset2',this)">코디 2</button>
            <button class="codi-preset-tab" onclick="showCodi('preset3',this)">코디 3</button>
        </div>
        <%-- 착용 중 --%>
        <div id="codi-base" class="codi-preset-content active">
            <c:choose>
                <c:when test="${not empty codiBase}">
                    <div class="codi-grid">
                        <c:forEach var="item" items="${codiBase}">
                            <div class="codi-item">
                                <img src="${item.cash_item_icon}" alt="" onerror="this.style.display='none'">
                                <div class="codi-part"><c:out value="${item.cash_item_equipment_part}"/></div>
                                <div class="codi-name"><c:out value="${item.cash_item_name}"/></div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise><div class="empty-notice">착용 중인 캐시 아이템이 없습니다.</div></c:otherwise>
            </c:choose>
        </div>
        <%-- 코디 프리셋 1 --%>
        <div id="codi-preset1" class="codi-preset-content">
            <c:choose>
                <c:when test="${not empty codiPreset1}">
                    <div class="codi-grid">
                        <c:forEach var="item" items="${codiPreset1}">
                            <div class="codi-item">
                                <img src="${item.cash_item_icon}" alt="" onerror="this.style.display='none'">
                                <div class="codi-part"><c:out value="${item.cash_item_equipment_part}"/></div>
                                <div class="codi-name"><c:out value="${item.cash_item_name}"/></div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise><div class="empty-notice">코디 1 정보가 없습니다.</div></c:otherwise>
            </c:choose>
        </div>
        <%-- 코디 프리셋 2 --%>
        <div id="codi-preset2" class="codi-preset-content">
            <c:choose>
                <c:when test="${not empty codiPreset2}">
                    <div class="codi-grid">
                        <c:forEach var="item" items="${codiPreset2}">
                            <div class="codi-item">
                                <img src="${item.cash_item_icon}" alt="" onerror="this.style.display='none'">
                                <div class="codi-part"><c:out value="${item.cash_item_equipment_part}"/></div>
                                <div class="codi-name"><c:out value="${item.cash_item_name}"/></div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise><div class="empty-notice">코디 2 정보가 없습니다.</div></c:otherwise>
            </c:choose>
        </div>
        <%-- 코디 프리셋 3 --%>
        <div id="codi-preset3" class="codi-preset-content">
            <c:choose>
                <c:when test="${not empty codiPreset3}">
                    <div class="codi-grid">
                        <c:forEach var="item" items="${codiPreset3}">
                            <div class="codi-item">
                                <img src="${item.cash_item_icon}" alt="" onerror="this.style.display='none'">
                                <div class="codi-part"><c:out value="${item.cash_item_equipment_part}"/></div>
                                <div class="codi-name"><c:out value="${item.cash_item_name}"/></div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise><div class="empty-notice">코디 3 정보가 없습니다.</div></c:otherwise>
            </c:choose>
        </div>
        <c:if test="${not empty sessionScope.loginMember}">
            <div style="margin-top:16px; text-align:right;">
                <button onclick="openLookbookModal()" class="btn" style="font-size:12px; padding:7px 16px;">📸 룩북에 등록</button>
            </div>
        </c:if>
    </div>

    <%-- 탭 3: 전체 스탯 --%>
    <div id="tab-stat" class="char-tab-content">
        <c:choose>
            <c:when test="${not empty statList}">
                <div class="stat-grid">
                    <c:forEach var="s" items="${statList}">
                        <c:if test="${not empty s.stat_value and s.stat_value != '0' and s.stat_value != '0.00'}">
                            <div class="stat-item">
                                <span class="stat-name"><c:out value="${s.stat_name}"/></span>
                                <span class="stat-val"><c:out value="${s.stat_value}"/></span>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise><div class="empty-notice">스탯 정보가 없습니다.</div></c:otherwise>
        </c:choose>
    </div>

    <%-- 탭 4: 유니온 --%>
    <div id="tab-union" class="char-tab-content">
        <c:if test="${not empty unionLevel}">
        <div class="union-summary-bar">
            <div class="union-summary-item">
                <span class="union-summary-label">유니온 레벨</span>
                <span class="union-summary-val">${unionLevel}</span>
            </div>
            <c:if test="${not empty unionGrade}">
            <div class="union-summary-item">
                <span class="union-summary-label">등급</span>
                <span class="union-summary-val grade"><c:out value="${unionGrade}"/></span>
            </div>
            </c:if>
            <c:if test="${not empty unionBlockCount}">
            <div class="union-summary-item">
                <span class="union-summary-label">편성 캐릭터</span>
                <span class="union-summary-val">${unionBlockCount}개</span>
            </div>
            </c:if>
        </div>
        </c:if>
        <c:choose>
            <c:when test="${not empty unionBlocks}">
                <div class="union-section-title">⚔ 편성 캐릭터</div>
                <div class="union-block-grid">
                    <c:forEach var="b" items="${unionBlocks}" varStatus="vs">
                        <div class="union-block-card">
                            <span class="union-block-rank">${vs.index + 1}</span>
                            <div class="union-block-info">
                                <div class="union-block-class"><c:out value="${b.blockClass}"/></div>
                                <div class="union-block-level">Lv.<strong><c:out value="${b.blockLevel}"/></strong></div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                <c:if test="${not empty raiderStats}">
                    <div class="union-section-title" style="margin-top:24px;">📊 공격대 효과</div>
                    <div class="union-stat-grid">
                        <c:forEach var="s" items="${raiderStats}">
                            <div class="union-stat-item"><c:out value="${s}"/></div>
                        </c:forEach>
                    </div>
                </c:if>
                <c:if test="${not empty occupiedStats}">
                    <div class="union-section-title" style="margin-top:24px;">🏰 점령 효과</div>
                    <div class="union-stat-grid">
                        <c:forEach var="s" items="${occupiedStats}">
                            <div class="union-stat-item"><c:out value="${s}"/></div>
                        </c:forEach>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${empty unionLevel}">
                    <div class="empty-notice">유니온 정보를 불러올 수 없습니다.</div>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- 탭: 유니온 아티팩트 --%>
    <div id="tab-artifact" class="char-tab-content">
        <c:choose>
            <c:when test="${not empty crystalList or not empty artifactEffectList}">

                <div class="artifact-ap">
                    <div>
                        <div class="artifact-ap-lbl">남은 아티팩트 AP</div>
                        <div class="artifact-ap-val">${artifactAp}</div>
                    </div>
                </div>

                <c:if test="${not empty crystalList}">
                <div class="sec-title">&#128142; 아티팩트 크리스탈</div>
                <div class="crystal-grid">
                    <c:forEach var="cr" items="${crystalList}">
                        <div class="crystal-card">
                            <div class="crystal-name"><c:out value="${cr.name}"/></div>
                            <span class="crystal-lv">Lv.${cr.level}</span>
                            <div>
                                <c:if test="${not empty cr.opt1}"><div class="crystal-opt"><c:out value="${cr.opt1}"/></div></c:if>
                                <c:if test="${not empty cr.opt2}"><div class="crystal-opt"><c:out value="${cr.opt2}"/></div></c:if>
                                <c:if test="${not empty cr.opt3}"><div class="crystal-opt"><c:out value="${cr.opt3}"/></div></c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                </c:if>

                <c:if test="${not empty artifactEffectList}">
                    <div class="sec-title">&#9889; 아티팩트 효과</div>
                    <div class="effect-grid">
                        <c:forEach var="ef" items="${artifactEffectList}">
                            <div class="effect-item">
                                <span class="effect-name"><c:out value="${ef.name}"/></span>
                                <span class="effect-lv">Lv.${ef.level}</span>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

            </c:when>
            <c:otherwise>
                <div class="empty-notice">유니온 아티팩트 정보를 불러올 수 없습니다.</div>
            </c:otherwise>
        </c:choose>
    </div>


</div>
</div><%-- /bg --%>

<%-- 룩북 등록 모달 --%>
<div id="lookbookModal" class="modal-overlay" style="display:none;">
    <div class="modal-box">
        <div class="modal-title">📸 룩북 등록</div>
        <p style="font-size:13px; color:#666; margin-bottom:16px;">
            <strong><c:out value="${charName}"/></strong>의 코디를 룩북에 공유합니다.
        </p>
        <form action="${pageContext.request.contextPath}/lookbook/register" method="post">
            <input type="hidden" name="charName"  value="<c:out value='${charName}'/>">
            <input type="hidden" name="charImage" value="${basic.character_image}">
            <input type="hidden" name="charClass" value="<c:out value='${basic.character_class}'/>">
            <input type="hidden" name="charWorld" value="<c:out value='${basic.world_name}'/>">
            <input type="hidden" name="charLevel" value="${basic.character_level}">
            <div class="form-group">
                <label>제목 (선택)</label>
                <input type="text" name="title" placeholder="예: 여름 코디 / 칼리 기본룩" maxlength="100">
            </div>
            <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:12px;">
                <button type="button" onclick="closeLookbookModal()" class="btn btn-gray">취소</button>
                <button type="submit" class="btn">등록</button>
            </div>
        </form>
    </div>
</div>

</c:if><%-- /not empty basic --%>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<script>
/* ═══════════ 장비 슬롯 렌더링 (메아기 스타일) ═══════════ */
const EQUIP_MAP = ${not empty equipMapJson ? equipMapJson : '{}'};

const LEFT_SLOTS  = ['모자','얼굴장식','눈장식','귀고리','상의','한벌옷','하의','신발','장갑','망토'];
const RIGHT_SLOTS = ['무기','보조무기','어깨장식','엠블렘','뱃지','훈장','벨트',
                     '반지1','반지2','반지3','반지4',
                     '펜던트','펜던트2','포켓 아이템','기계 심장','예비 특수 반지'];

function eHtml(s) {
    return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function renderSlot(slotName, isRight) {
    // 한벌옷이 상의를 점유하면 하의는 숨김
    if (slotName === '하의') {
        const top = EQUIP_MAP['상의'];
        if (top && top.item_equipment_part === '한벌옷') return '';
    }
    // 상의가 없고 한벌옷도 없으면 한벌옷 슬롯 표시 안함
    if (slotName === '한벌옷' && !EQUIP_MAP['한벌옷']) return '';
    // 상의가 있으면 한벌옷 슬롯 표시 안함
    if (slotName === '한벌옷' && EQUIP_MAP['상의']) return '';

    const item = EQUIP_MAP[slotName];
    if (!item) {
        return `<div class="eq-slot eq-empty">
            <div class="eq-slot-icon-wrap"></div>
            <div class="eq-slot-text">
                <div class="eq-slot-lbl">\${eHtml(slotName)}</div>
                <div class="eq-slot-nm" style="color:#ccc;font-weight:400">비어있음</div>
            </div>
        </div>`;
    }

    const gc  = item.gradeClass  || '';
    const agc = item.addGradeClass || '';
    const sf  = item.starforce && item.starforce !== '0' ? item.starforce : '';
    const opts1 = [item.potential_option_1, item.potential_option_2, item.potential_option_3].filter(Boolean);
    const opts2 = [item.additional_potential_option_1, item.additional_potential_option_2, item.additional_potential_option_3].filter(Boolean);
    const ttCls = isRight ? 'eq-tt tt-r' : 'eq-tt';

    /* 합산 스탯 */
    const totalOpt = item.item_total_option || {};
    const STAT_KEYS = [
        ['str','STR'],['dex','DEX'],['int','INT'],['luk','LUK'],
        ['max_hp','HP'],['max_mp','MP'],
        ['attack_power','공격력'],['magic_power','마력'],
        ['armor','방어력'],
        ['boss_damage','보스뎀','%'],['ignore_monster_armor','방무','%'],
        ['damage','데미지','%'],['all_stat','올스탯','%']
    ];
    const statLines = STAT_KEYS
        .filter(([k]) => totalOpt[k] && String(totalOpt[k]) !== '0' && String(totalOpt[k]) !== '0.00')
        .map(([k,lb,sx]) => `<div class="eq-tt-stat"><span class="eq-tt-stat-k">\${eHtml(lb)}</span><span class="eq-tt-stat-v">+\${eHtml(String(totalOpt[k]))}\${sx||''}</span></div>`);
    const scrollCnt = item.scroll_upgrade && item.scroll_upgrade !== '0' ? item.scroll_upgrade : '';

    return `<div class="eq-slot \${gc}">
        <div class="eq-slot-icon-wrap">
            <img src="\${eHtml(item.item_icon||'')}" onerror="this.parentNode.innerHTML='<span style=font-size:18px>?</span>'">
            \${sf ? `<span class="eq-slot-star">&#9733;\${sf}</span>` : ''}
        </div>
        <div class="eq-slot-text">
            <div class="eq-slot-lbl">\${eHtml(slotName)}</div>
            <div class="eq-slot-nm \${gc}">\${eHtml(item.item_name||'')}</div>
            \${item.potential_option_grade
                ? `<span class="eq-slot-gbadge \${gc}">\${eHtml(item.potential_option_grade)}</span>`
                : ''}
        </div>
        <div class="\${ttCls}">
            <div class="eq-tt-nm \${gc}">\${eHtml(item.item_name||'')}</div>
            \${sf ? `<div class="eq-tt-sf">&#9733;\${sf} 스타포스\${scrollCnt ? ' &nbsp;/&nbsp; 강화 +'+eHtml(scrollCnt) : ''}</div>`
                  : scrollCnt ? `<div class="eq-tt-scroll">강화 +\${eHtml(scrollCnt)}</div>` : ''}
            \${item.soul_name ? `<div class="eq-tt-soul">&#128302; \${eHtml(item.soul_name)}\${item.soul_option ? ' &middot; '+eHtml(item.soul_option) : ''}</div>` : ''}
            \${statLines.length ? `
                <div class="eq-tt-sep"></div>
                <div class="eq-tt-statlabel">합산 스탯</div>
                \${statLines.join('')}
            ` : ''}
            \${opts1.length ? `
                <div class="eq-tt-sep"></div>
                <div class="eq-tt-glabel \${gc}">\${eHtml(item.potential_option_grade||'')} 잠재능력</div>
                \${opts1.map(o=>`<div class="eq-tt-opt">\${eHtml(o)}</div>`).join('')}
            ` : ''}
            \${opts2.length ? `
                <div class="eq-tt-sep"></div>
                <div class="eq-tt-addlabel \${agc}">\${eHtml(item.additional_potential_option_grade||'')} 에디셔널</div>
                \${opts2.map(o=>`<div class="eq-tt-opt add">\${eHtml(o)}</div>`).join('')}
            ` : ''}
        </div>
    </div>`;
}

(function renderEquipSlots() {
    const left  = document.getElementById('slot-left');
    const right = document.getElementById('slot-right');
    if (!left || !right) return;
    left.innerHTML  = LEFT_SLOTS.map(s => renderSlot(s, false)).join('');
    right.innerHTML = RIGHT_SLOTS.map(s => renderSlot(s, true)).join('');
})();

/* ═══════════ 탭 전환 ═══════════ */
function showTab(name, btn) {
    document.querySelectorAll('.char-tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.char-tab').forEach(el => el.classList.remove('active'));
    document.getElementById('tab-' + name).classList.add('active');
    btn.classList.add('active');
}
function showCodi(name, btn) {
    document.querySelectorAll('.codi-preset-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.codi-preset-tab').forEach(el => el.classList.remove('active'));
    document.getElementById('codi-' + name).classList.add('active');
    btn.classList.add('active');
}
function openLookbookModal()  { document.getElementById('lookbookModal').style.display = 'flex'; }
function closeLookbookModal() { document.getElementById('lookbookModal').style.display = 'none'; }
document.getElementById('lookbookModal') &&
    document.getElementById('lookbookModal').addEventListener('click', function(e) {
        if (e.target === this) closeLookbookModal();
    });
/* ── 본캐/부캐 로드 ── */
let altsLoaded = false;
function loadAlts() {
    if (altsLoaded) return;
    altsLoaded = true;
    const loading = document.getElementById('alts-loading');
    const grid    = document.getElementById('alts-grid');
    const errBox  = document.getElementById('alts-error');
    loading.innerHTML = '<div style="font-size:28px;margin-bottom:10px;">⏳</div>캐릭터 목록 불러오는 중...';
    const charName = '<c:out value="${charName}"/>';
    fetch('${pageContext.request.contextPath}/api/maple/alts?charName=' + encodeURIComponent(charName))
        .then(r => r.ok ? r.json() : Promise.reject(r.status))
        .then(chars => {
            loading.style.display = 'none';
            if (!Array.isArray(chars) || chars.length === 0) {
                errBox.textContent = '연결된 부캐 정보가 없습니다. (최초 조회 시 Nexon API에서 수집합니다)';
                errBox.style.display = 'block';
                return;
            }
            /* 본캐 우선, 이후 레벨 내림차순 */
            chars.sort((a, b) => {
                if (a.isMain && !b.isMain) return -1;
                if (!a.isMain && b.isMain) return 1;
                return (b.charLevel || 0) - (a.charLevel || 0);
            });
            var ctx = '${pageContext.request.contextPath}';
            grid.innerHTML = chars.map(function(c) {
                var cpStr  = c.combatPower > 0 ? fmtCP(c.combatPower) : '';
                var isMain = c.isMain || false;
                var href   = ctx + '/character/search?charName=' + encodeURIComponent(c.charName || '');
                var imgHtml = c.imageUrl
                    ? '<img class="alt-card-img" src="' + esc(c.imageUrl) + '" alt="" onerror="this.className=\'alt-card-img-ph\'">'
                    : '<div class="alt-card-img-ph"></div>';
                var badgeHtml  = isMain ? '<span class="main-badge">본캐</span>' : '';
                var guildHtml  = c.guildName ? '<div class="alt-card-guild">&lt;' + esc(c.guildName) + '&gt;</div>' : '';
                var cpHtml     = cpStr ? '<div class="alt-card-cp">전투력 ' + cpStr + '</div>' : '';
                return '<a class="alt-card' + (isMain ? ' main' : '') + '" href="' + href + '">'
                     + imgHtml
                     + '<div class="alt-card-body">'
                     + '<div class="alt-card-name">' + badgeHtml + esc(c.charName || '') + '</div>'
                     + '<div class="alt-card-class">Lv.' + (c.charLevel || '?') + ' ' + esc(c.charClass || '') + '</div>'
                     + guildHtml
                     + cpHtml
                     + '</div></a>';
            }).join('');
            grid.style.display = 'grid';
        })
        .catch(status => {
            loading.style.display = 'none';
            if (status === 404) {
                errBox.textContent = '캐릭터를 찾을 수 없거나 아직 캐시 데이터가 없습니다.';
            } else if (status === 429) {
                errBox.textContent = '갱신 대기 중입니다. 잠시 후 다시 시도해주세요.';
            } else {
                errBox.textContent = '부캐 정보를 불러오는 중 오류가 발생했습니다.';
            }
            errBox.style.display = 'block';
        });
}
function fmtCP(n) {
    if (n >= 100000000) return (n / 10000 | 0).toLocaleString() + '만';
    if (n >= 10000)      return (n / 10000).toFixed(1) + '만';
    return n.toLocaleString();
}
function esc(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function saveSpec() {
    fetch('${pageContext.request.contextPath}/character/history/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'charName=' + encodeURIComponent('<c:out value="${charName}"/>')
    }).then(r => r.text()).then(t => alert(t === 'ok' ? '스펙이 저장되었습니다.' : '저장에 실패했습니다.'))
      .catch(() => alert('오류가 발생했습니다.'));
}
</script>
</body>
</html>
