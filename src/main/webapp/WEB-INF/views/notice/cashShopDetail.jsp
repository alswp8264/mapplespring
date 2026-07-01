<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>캐시샵 상세 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        /* 넥슨 API HTML 콘텐츠 이미지 반응형 처리 */
        .notice-html-content img { max-width: 100%; height: auto; display: block; margin: 0 auto; }
        .notice-html-content { line-height: 1.7; color: #333; }
        .notice-html-content table { max-width: 100%; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

    <c:choose>
        <c:when test="${not empty notice}">
            <div class="post-wrap">

                <%-- 제목 / 메타 --%>
                <div class="post-header">
                    <div class="post-title"><c:out value="${notice.title}"/></div>
                    <div class="post-meta">
                        <c:if test="${not empty notice.date}">
                            <span>등록일 <c:out value="${notice.date}"/></span>
                        </c:if>
                        <c:if test="${not empty notice.date_sale_start}">
                            <span>
                                판매 기간 :
                                <c:out value="${notice.date_sale_start}"/>
                                <c:if test="${not empty notice.date_sale_end}">
                                    ~ <c:out value="${notice.date_sale_end}"/>
                                </c:if>
                            </span>
                        </c:if>
                    </div>
                </div>

                <%-- 본문 HTML (EL 우회: 스크립틀릿으로 직접 출력) --%>
                <div class="post-content notice-html-content">
                    <%
                        String contents = (String) request.getAttribute("noticeContents");
                        if (contents != null && !contents.isEmpty()) {
                            out.print(contents);
                        } else {
                    %>
                        <p style="text-align:center; color:#aaa; padding:40px 0;">
                            상세 내용이 없습니다.
                        </p>
                    <%
                        }
                    %>
                </div>

                <%-- 공식 링크 버튼 --%>
                <c:if test="${not empty notice.url}">
                    <div style="text-align:center; margin: 24px 0;">
                        <a href="${notice.url}" target="_blank" class="btn"
                           style="font-size:15px; padding:12px 32px;">
                            공식 캐시샵 페이지로 이동 →
                        </a>
                    </div>
                </c:if>

                <div class="post-footer">
                    <a href="${pageContext.request.contextPath}/notice/cashshop" class="btn btn-gray">목록으로</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="error-msg">캐시샵 정보를 불러올 수 없습니다.</div>
            <div style="margin-top:12px;">
                <a href="${pageContext.request.contextPath}/notice/cashshop" class="btn btn-gray">목록으로</a>
            </div>
        </c:otherwise>
    </c:choose>

</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
