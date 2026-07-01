<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시글 수정 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        .cat-chips { display:flex; gap:8px; flex-wrap:wrap; }
        .cat-chip { padding:7px 18px; border-radius:20px; border:1px solid #e5e9f1; background:#f4f7fc;
            font-size:13px; font-weight:600; color:#586079; cursor:pointer; font-family:inherit; transition:all .15s; }
        .cat-chip.active { background:#4f8ef7; border-color:#4f8ef7; color:#fff; }
        .exist-media { display:flex; flex-wrap:wrap; gap:8px; margin-top:8px; }
        .exist-media .pv { width:90px; height:90px; border-radius:8px; overflow:hidden; border:1px solid #e5e9f1; }
        .exist-media img, .exist-media video { width:100%; height:100%; object-fit:cover; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div style="max-width:760px; margin:0 auto; background:#fff; border:1px solid #e8eaed; border-radius:16px; padding:32px;">
        <div class="section-title" style="margin-bottom:20px">게시글 수정</div>
        <form action="${pageContext.request.contextPath}/board/edit" method="post" enctype="multipart/form-data">
            <input type="hidden" name="boardId" value="${board.boardId}">

            <div class="form-group">
                <label>카테고리</label>
                <input type="hidden" name="category" id="category-input" value="${board.category}">
                <div class="cat-chips" id="cat-chips">
                    <c:forEach var="cat" items="${categories}">
                        <span class="cat-chip ${cat == board.category ? 'active' : ''}" data-cat="${cat}">${cat}</span>
                    </c:forEach>
                </div>
            </div>

            <div class="form-group">
                <label>제목</label>
                <input type="text" name="title" value="<c:out value='${board.title}'/>" required>
            </div>
            <div class="form-group">
                <label>내용</label>
                <textarea name="content" rows="12" required><c:out value="${board.content}"/></textarea>
            </div>

            <c:if test="${not empty fileList}">
                <div class="form-group">
                    <label>기존 첨부</label>
                    <div class="exist-media">
                        <c:forEach var="f" items="${fileList}">
                            <div class="pv">
                                <c:choose>
                                    <c:when test="${f.fileType == 'youtube'}">
                                        <img src="https://img.youtube.com/vi/${f.fileName}/mqdefault.jpg">
                                    </c:when>
                                    <c:when test="${f.fileType == 'video'}">
                                        <video src="${pageContext.request.contextPath}/upload/board/${f.fileName}" muted></video>
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/upload/board/${f.fileName}">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <div class="form-group">
                <label>사진 · 동영상 추가</label>
                <input type="file" name="files" id="files" multiple accept="image/*,video/*">
                <div style="font-size:12px; color:#98a1b5; margin-top:6px;">선택한 파일이 기존 첨부에 추가됩니다. · <strong>동영상 최대 3분</strong></div>
            </div>

            <div class="form-group">
                <label>유튜브 링크 추가 (선택)</label>
                <textarea name="youtubeUrls" rows="2" placeholder="유튜브 주소를 붙여넣으세요. 여러 개면 줄바꿈으로 구분"></textarea>
            </div>

            <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:8px;">
                <a href="${pageContext.request.contextPath}/board/detail/${board.boardId}" class="btn btn-gray">취소</a>
                <button type="submit" class="btn">수정 완료</button>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<script>
document.querySelectorAll('#cat-chips .cat-chip').forEach(function(chip){
    chip.addEventListener('click', function(){
        document.querySelectorAll('#cat-chips .cat-chip').forEach(c=>c.classList.remove('active'));
        chip.classList.add('active');
        document.getElementById('category-input').value = chip.dataset.cat;
    });
});
// 동영상 3분 제한
const MAX_VIDEO_SEC = 180;
document.getElementById('files').addEventListener('change', function(e){
    const input = e.target;
    const videos = Array.from(input.files).filter(f => f.type.startsWith('video'));
    if (videos.length === 0) return;
    let pending = videos.length, tooLong = false;
    videos.forEach(function(f){
        const v = document.createElement('video');
        v.preload = 'metadata';
        v.onloadedmetadata = function(){ URL.revokeObjectURL(v.src); if (v.duration > MAX_VIDEO_SEC + 0.5) tooLong = true; if (--pending === 0) done(); };
        v.onerror = function(){ if (--pending === 0) done(); };
        v.src = URL.createObjectURL(f);
    });
    function done(){
        if (tooLong){
            alert('동영상은 최대 3분(180초)까지 업로드할 수 있습니다.\n더 짧은 영상을 선택해 주세요.');
            input.value = '';
        }
    }
});
</script>
</body>
</html>
