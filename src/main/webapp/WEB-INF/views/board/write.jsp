<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>글쓰기 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        .cat-chips { display:flex; gap:8px; flex-wrap:wrap; }
        .cat-chip {
            padding:7px 18px; border-radius:20px; border:1px solid var(--c-border, #e5e9f1);
            background:#f4f7fc; font-size:13px; font-weight:600; color:#586079; cursor:pointer;
            font-family:inherit; transition:all .15s;
        }
        .cat-chip.active { background:#4f8ef7; border-color:#4f8ef7; color:#fff; }
        .file-hint { font-size:12px; color:#98a1b5; margin-top:6px; }
        #file-preview { display:flex; flex-wrap:wrap; gap:8px; margin-top:10px; }
        #file-preview .pv { width:90px; height:90px; border-radius:8px; overflow:hidden; border:1px solid #e5e9f1; background:#f4f7fc; display:flex; align-items:center; justify-content:center; }
        #file-preview img, #file-preview video { width:100%; height:100%; object-fit:cover; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div style="max-width:760px; margin:0 auto; background:#fff; border:1px solid #e8eaed; border-radius:16px; padding:32px;">
        <div class="section-title" style="margin-bottom:20px">새 게시글</div>
        <form action="${pageContext.request.contextPath}/board/write" method="post" enctype="multipart/form-data">

            <div class="form-group">
                <label>카테고리</label>
                <input type="hidden" name="category" id="category-input" value="공략">
                <div class="cat-chips" id="cat-chips">
                    <c:forEach var="cat" items="${categories}">
                        <span class="cat-chip ${cat == '공략' ? 'active' : ''}" data-cat="${cat}">${cat}</span>
                    </c:forEach>
                </div>
            </div>

            <div class="form-group">
                <label>제목</label>
                <input type="text" name="title" placeholder="제목을 입력하세요" required>
            </div>
            <div class="form-group">
                <label>내용</label>
                <textarea name="content" rows="12" placeholder="내용을 입력하세요" required></textarea>
            </div>

            <div class="form-group">
                <label>사진 · 동영상 첨부 (자랑하기 📸)</label>
                <input type="file" name="files" id="files" multiple accept="image/*,video/*">
                <div class="file-hint">이미지/동영상 여러 개 선택 가능 · 파일당 최대 50MB · <strong>동영상 최대 3분</strong></div>
                <div id="file-preview"></div>
            </div>

            <div class="form-group">
                <label>유튜브 링크 (선택)</label>
                <textarea name="youtubeUrls" rows="2" placeholder="유튜브 주소를 붙여넣으세요. 여러 개면 줄바꿈으로 구분 (예: https://youtu.be/xxxxxxxxxxx)"></textarea>
                <div class="file-hint">붙여넣은 유튜브 영상이 게시글에 재생창으로 표시됩니다.</div>
            </div>

            <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:8px;">
                <a href="${pageContext.request.contextPath}/board/list" class="btn btn-gray">취소</a>
                <button type="submit" class="btn">등록</button>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<script>
// 카테고리 토글
document.querySelectorAll('#cat-chips .cat-chip').forEach(function(chip){
    chip.addEventListener('click', function(){
        document.querySelectorAll('#cat-chips .cat-chip').forEach(c=>c.classList.remove('active'));
        chip.classList.add('active');
        document.getElementById('category-input').value = chip.dataset.cat;
    });
});
// 첨부 미리보기 + 동영상 3분 제한
const MAX_VIDEO_SEC = 180;
function renderPreview(files){
    const box = document.getElementById('file-preview');
    box.innerHTML = '';
    files.forEach(function(f){
        const url = URL.createObjectURL(f);
        const d = document.createElement('div'); d.className = 'pv';
        if (f.type.startsWith('video')) d.innerHTML = '<video src="'+url+'" muted></video>';
        else d.innerHTML = '<img src="'+url+'">';
        box.appendChild(d);
    });
}
document.getElementById('files').addEventListener('change', function(e){
    const input = e.target;
    const files = Array.from(input.files);
    const videos = files.filter(f => f.type.startsWith('video'));
    if (videos.length === 0) { renderPreview(files); return; }
    let pending = videos.length, tooLong = false;
    videos.forEach(function(f){
        const v = document.createElement('video');
        v.preload = 'metadata';
        v.onloadedmetadata = function(){
            URL.revokeObjectURL(v.src);
            if (v.duration > MAX_VIDEO_SEC + 0.5) tooLong = true;
            if (--pending === 0) done();
        };
        v.onerror = function(){ if (--pending === 0) done(); };
        v.src = URL.createObjectURL(f);
    });
    function done(){
        if (tooLong){
            alert('동영상은 최대 3분(180초)까지 업로드할 수 있습니다.\n더 짧은 영상을 선택해 주세요.');
            input.value = '';
            document.getElementById('file-preview').innerHTML = '';
        } else {
            renderPreview(Array.from(input.files));
        }
    }
});
</script>
</body>
</html>
