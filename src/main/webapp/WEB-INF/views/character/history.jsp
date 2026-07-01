<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${charName} 스펙 히스토리 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

    <div style="display:flex; align-items:center; gap:12px; margin-bottom:20px;">
        <div class="section-title" style="margin:0">${charName} 스펙 히스토리</div>
        <a href="javascript:history.back()" class="btn btn-gray" style="font-size:12px; padding:6px 14px;">← 돌아가기</a>
    </div>

    <table class="history-table">
        <thead>
            <tr>
                <th>저장일</th>
                <th>공격력</th>
                <th>보스 데미지 (%)</th>
                <th>방어율 무시 (%)</th>
                <th>최종 데미지 (%)</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="h" items="${historyList}">
                <tr>
                    <td>${h.saveDate}</td>
                    <td>${h.attackPower}</td>
                    <td>${h.bossDmg}</td>
                    <td>${h.ignDef}</td>
                    <td>${h.finalDmg}</td>
                </tr>
            </c:forEach>
            <c:if test="${empty historyList}">
                <tr><td colspan="5" style="padding:30px; color:#aaa;">저장된 스펙 히스토리가 없습니다.</td></tr>
            </c:if>
        </tbody>
    </table>

</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
