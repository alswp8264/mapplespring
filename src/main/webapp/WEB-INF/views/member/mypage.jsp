<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <%-- face-api.js (브라우저 내 얼굴 방향 감지 - WASM 불필요) --%>
    <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js" crossorigin="anonymous"></script>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">

    <div class="section-title" style="margin-bottom:20px">마이페이지</div>
    <c:if test="${not empty msg}"><div class="error-msg"><c:out value="${msg}"/></div></c:if>
    <c:if test="${not empty successMsg}"><div class="success-msg"><c:out value="${successMsg}"/></div></c:if>

    <div class="mypage-wrap">

        <%-- 내 정보 --%>
        <div class="info-box">
            <h3>내 정보</h3>
            <form action="${pageContext.request.contextPath}/member/update" method="post">
                <div class="form-group">
                    <label>아이디</label>
                    <input type="text" value="<c:out value='${member.loginId}'/>" disabled
                           style="background:#f8f9fb; color:#aaa;">
                </div>
                <div class="form-group">
                    <label>이름</label>
                    <input type="text" name="name" value="<c:out value='${member.name}'/>" required>
                </div>
                <div class="form-group">
                    <label>이메일</label>
                    <input type="email" name="email" value="<c:out value='${member.email}'/>" required>
                </div>
                <button type="submit" class="btn">정보 수정</button>
            </form>
        </div>

        <%-- 즐겨찾기 캐릭터 --%>
        <div class="info-box">
            <h3>⭐ 즐겨찾기 캐릭터</h3>
            <c:choose>
                <c:when test="${not empty favList}">
                    <div style="display:flex;flex-direction:column;gap:8px;margin-top:12px;">
                        <c:forEach var="f" items="${favList}">
                        <div style="display:flex;align-items:center;gap:10px;padding:10px 12px;background:var(--c-bg-inner);border:1px solid var(--c-border);border-radius:10px;">
                            <span style="font-size:18px;">⭐</span>
                            <a href="${pageContext.request.contextPath}/character/search?charName=<c:out value='${f.charName}'/>"
                               style="flex:1;font-weight:600;font-size:14px;color:var(--c-text);">
                                <c:out value="${f.charName}"/>
                            </a>
                            <form action="${pageContext.request.contextPath}/character/favorite/delete"
                                  method="post" style="display:inline;margin:0;">
                                <input type="hidden" name="favId" value="${f.favId}">
                                <button type="submit"
                                        style="background:none;border:1px solid var(--c-border);border-radius:6px;padding:3px 10px;font-size:12px;color:var(--c-text-2);cursor:pointer;">
                                    삭제
                                </button>
                            </form>
                        </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <p style="font-size:13px;color:#aaa;margin-top:10px;">즐겨찾기한 캐릭터가 없습니다. 캐릭터 검색 후 즐겨찾기 추가해보세요!</p>
                    <a href="${pageContext.request.contextPath}/character/search" class="btn" style="display:inline-block;margin-top:10px;font-size:13px;">캐릭터 검색하기</a>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- 비밀번호 변경 --%>
        <div class="info-box">
            <h3>비밀번호 변경</h3>
            <form action="${pageContext.request.contextPath}/member/updatePw" method="post">
                <div class="form-group">
                    <label>현재 비밀번호</label>
                    <input type="password" name="currentPw" placeholder="현재 비밀번호" required>
                </div>
                <div class="form-group">
                    <label>새 비밀번호</label>
                    <input type="password" name="newPw" placeholder="새 비밀번호" required>
                </div>
                <button type="submit" class="btn">변경</button>
            </form>
        </div>

        <%-- 얼굴 인식 등록 --%>
        <div class="info-box">
            <h3>얼굴 인식 등록</h3>
            <style>
                .face-canvas-wrap {
                    position: relative; border-radius: 10px;
                    overflow: hidden; border: 2px solid #e0e0e0; background: #000;
                }
                #face-reg-canvas { width: 100%; display: block; }
                .face-overlay-msg {
                    position: absolute; bottom: 10px; left: 50%; transform: translateX(-50%);
                    background: rgba(0,0,0,0.55); color: #fff;
                    padding: 5px 14px; border-radius: 20px;
                    font-size: 13px; font-weight: 600; white-space: nowrap; pointer-events: none;
                }
            </style>
            <c:choose>
                <c:when test="${not empty member.faceEncoding}">
                    <div id="face-reg-badge" style="display:inline-flex; align-items:center; gap:6px;
                         background:#e8f5e9; color:#2e7d32; border-radius:8px; padding:8px 14px;
                         font-size:13px; font-weight:600; margin-bottom:14px;">
                        ✅ 얼굴이 등록되어 있습니다.
                    </div>
                    <p id="face-rereg-msg" style="font-size:12px; color:#aaa; margin-bottom:10px;">재등록하려면 아래 버튼을 누르세요.</p>
                    <button id="btn-face-delete" onclick="doFaceDelete()"
                            style="background:#e53935; color:#fff; border:none; padding:6px 14px;
                                   border-radius:6px; font-size:12px; cursor:pointer; margin-bottom:10px;">
                        🗑 얼굴 삭제
                    </button>
                </c:when>
                <c:otherwise>
                    <div id="face-reg-badge" style="display:inline-flex; align-items:center; gap:6px;
                         background:#fff3e0; color:#e65100; border-radius:8px; padding:8px 14px;
                         font-size:13px; font-weight:600; margin-bottom:14px;">
                        ⚠️ 얼굴이 등록되지 않았습니다.
                    </div>
                    <p style="font-size:12px; color:#888; margin-bottom:14px;">
                        얼굴을 등록하면 다음 로그인부터 얼굴 인식으로 로그인할 수 있습니다.
                    </p>
                </c:otherwise>
            </c:choose>
            <div id="face-reg-area" style="display:none; margin-bottom:12px;">
                <div class="face-canvas-wrap">
                    <canvas id="face-reg-canvas"></canvas>
                </div>
                <video id="face-reg-video" autoplay playsinline
                       style="display:none; width:1px; height:1px;"></video>
                <div id="face-reg-status" style="font-size:14px; font-weight:600; color:#333; margin-top:10px; text-align:center;"></div>

                <%-- 3단계 진행 게이지 --%>
                <div style="margin-top:12px;">
                    <div style="display:flex; justify-content:space-between; font-size:11px; margin-bottom:5px;">
                        <span id="step-lbl-1" style="color:#98a1b5;">① 정면</span>
                        <span id="step-lbl-2" style="color:#98a1b5;">② 왼쪽</span>
                        <span id="step-lbl-3" style="color:#98a1b5;">③ 오른쪽</span>
                    </div>
                    <div style="height:12px; background:#eef1f7; border-radius:8px; overflow:hidden;">
                        <div id="face-gauge" style="height:100%; width:0%;
                             background:linear-gradient(90deg,#5b9bff,#4f8ef7); border-radius:8px; transition:width .35s ease;"></div>
                    </div>
                </div>

                <div style="text-align:center; margin-top:14px; display:flex; gap:8px; justify-content:center;">
                    <button id="btn-reg-submit" onclick="doRegisterMulti()" disabled
                            style="background:#c7d0e0; color:#fff; border:none; padding:9px 24px;
                                   border-radius:8px; font-size:14px; cursor:not-allowed; font-family:inherit;">
                        얼굴 등록하기
                    </button>
                    <button id="btn-reg-reset" onclick="resetCapture()" type="button"
                            style="display:none; background:#f4f7fc; color:#586079; border:1px solid #e5e9f1;
                                   padding:9px 16px; border-radius:8px; font-size:13px; cursor:pointer; font-family:inherit;">
                        🔄 다시 촬영
                    </button>
                </div>
            </div>
            <button id="btn-face-toggle" class="btn" onclick="toggleFaceReg()">📷 카메라 열기</button>
        </div>

        <%-- 회원 탈퇴 --%>
        <div class="info-box">
            <h3>회원 탈퇴</h3>
            <p style="font-size:13px; color:#888; margin-bottom:14px;">
                탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.
            </p>
            <form action="${pageContext.request.contextPath}/member/delete" method="post"
                  onsubmit="return confirm('정말 탈퇴하시겠습니까? 모든 데이터가 삭제됩니다.')">
                <div class="form-group">
                    <label>비밀번호 확인</label>
                    <input type="password" name="password" placeholder="현재 비밀번호 입력" required>
                </div>
                <button type="submit" class="btn btn-danger">탈퇴</button>
            </form>
        </div>

    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
const CTX = '${pageContext.request.contextPath}';

let faceStream = null;
let rafIdReg   = null;

// ── face-api.js (브라우저 내 얼굴 방향 감지) ─────────────────
const FRONT_T = 0.20;
const SIDE_T  = 0.35;
let mpNoseRel    = null;
let mpReady      = false;
let mpFrameCount = 0;

const MODEL_URL = CTX + '/resources/face-api-weights';
Promise.all([
    faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
    faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL)
]).then(() => {
    mpReady = true;
    console.log('[face-api] 모델 로드 완료');
}).catch(e => {
    console.error('[face-api] 모델 로드 실패:', e);
});

function getNoseRelReg() { return mpNoseRel; }

function setRegStatus(msg) { document.getElementById('face-reg-status').textContent = msg; }

function toggleFaceReg() {
    const area = document.getElementById('face-reg-area');
    if (!faceStream) {
        area.style.display = 'block';
        document.getElementById('btn-face-toggle').textContent = '📷 카메라 닫기';
        startFaceReg();
    } else {
        area.style.display = 'none';
        document.getElementById('btn-face-toggle').textContent = '📷 카메라 열기';
        stopFaceReg();
    }
}

function startFaceReg() {
    navigator.mediaDevices.getUserMedia({ video: { width:640, height:480 } })
    .then(s => {
        faceStream = s;
        const v = document.getElementById('face-reg-video');
        v.srcObject = s;
        v.onloadedmetadata = () => {
            const canvas = document.getElementById('face-reg-canvas');
            canvas.width  = v.videoWidth  || 640;
            canvas.height = v.videoHeight || 480;
            renderLoop();
            startMpLoop();    // MediaPipe 프레임 처리 시작
            startCapture();   // 3단계 촬영 시작
        };
    })
    .catch(() => setRegStatus('카메라 접근 권한이 필요합니다.'));
}

// face-api.js로 캔버스에서 얼굴 방향 감지
let mpLoopId = null;
async function startMpLoop() {
    const canvas = document.getElementById('face-reg-canvas');
    async function loop() {
        if (!faceStream) return;
        if (mpReady && canvas.width > 10) {
            try {
                const result = await faceapi
                    .detectSingleFace(canvas, new faceapi.TinyFaceDetectorOptions({ inputSize: 224, scoreThreshold: 0.3 }))
                    .withFaceLandmarks();
                if (result) {
                    mpFrameCount++;
                    const lm  = result.landmarks;
                    const nose = lm.getNose()[3];          // 코끝 (landmark 30)
                    const le   = lm.getLeftEye();
                    const re   = lm.getRightEye();
                    const leX  = le.reduce((s,p) => s + p.x, 0) / le.length;
                    const reX  = re.reduce((s,p) => s + p.x, 0) / re.length;
                    const eyeMidX = (leX + reX) / 2;
                    const eyeDist = Math.abs(reX - leX) || 0.001;
                    mpNoseRel = (nose.x - eyeMidX) / eyeDist;
                } else {
                    mpNoseRel = null;
                }
            } catch(e) { }
        }
        mpLoopId = requestAnimationFrame(loop);
    }
    loop();
}

// ── 3단계 촬영 상태 ──────────────────────────────────────────
let captureStep = 0;
let capturedImages = [];
let captureTimer = null;
let polling = false;
const STEP_MSG = ['① 정면을 바라봐 주세요', '② 고개를 왼쪽으로 돌려주세요', '③ 고개를 오른쪽으로 돌려주세요'];

function captureFull() {
    // 320×240으로 축소 전송 → CNN 처리 속도 대폭 향상
    const v = document.getElementById('face-reg-video');
    const tmp = document.createElement('canvas');
    tmp.width = 320; tmp.height = 240;
    tmp.getContext('2d').drawImage(v, 0, 0, 320, 240);
    return tmp.toDataURL('image/jpeg', 0.85);
}

function setGauge(pct){ document.getElementById('face-gauge').style.width = pct + '%'; }
function setSubmitEnabled(on){
    const b = document.getElementById('btn-reg-submit');
    b.disabled = !on;
    b.style.background = on ? '#4f8ef7' : '#c7d0e0';
    b.style.cursor = on ? 'pointer' : 'not-allowed';
}
function markStep(n, done){
    const el = document.getElementById('step-lbl-'+n);
    el.style.color = done ? '#2e7d32' : '#98a1b5';
    el.style.fontWeight = done ? '700' : '400';
}

function startCapture() {
    captureStep = 0; capturedImages = []; polling = false;
    setGauge(0);
    [1,2,3].forEach(n => markStep(n, false));
    document.getElementById('btn-reg-reset').style.display = 'none';
    setSubmitEnabled(false);
    setRegStatus(STEP_MSG[0]);
    if (captureTimer) clearInterval(captureTimer);
    captureTimer = setInterval(pollCapture, 500);
}
function resetCapture(){ startCapture(); }

function pollCapture() {
    if (!faceStream || captureStep >= 3) return;
    const rel = getNoseRelReg();
    if (rel === null) {
        let dbg = !mpReady ? 'MP모델로딩중...' : '얼굴감지중(프레임:' + mpFrameCount + ')';
        setRegStatus(STEP_MSG[captureStep] + '  (' + dbg + ')');
        return;
    }

    let ok = false;
    if      (captureStep === 0) ok = Math.abs(rel) < FRONT_T;
    else if (captureStep === 1) ok = rel < -SIDE_T;
    else if (captureStep === 2) ok = rel >  SIDE_T;

    setRegStatus(STEP_MSG[captureStep] + '  (rel=' + rel.toFixed(2) + ')');
    if (!ok) return;

    capturedImages[captureStep] = captureFull();
    captureStep++;
    setGauge(Math.round(captureStep / 3 * 100));
    markStep(captureStep, true);
    if (captureStep < 3) {
        setRegStatus('✅ ' + captureStep + '/3 완료 — ' + STEP_MSG[captureStep]);
    } else {
        clearInterval(captureTimer);
        setRegStatus('✅ 3단계 촬영 완료! [얼굴 등록하기]를 눌러주세요');
        setSubmitEnabled(true);
        document.getElementById('btn-reg-reset').style.display = 'inline-block';
    }
}

function renderLoop() {
    if (!faceStream) return;
    const v      = document.getElementById('face-reg-video');
    const canvas = document.getElementById('face-reg-canvas');
    const ctx    = canvas.getContext('2d');
    ctx.save(); ctx.scale(-1, 1);
    ctx.drawImage(v, -canvas.width, 0, canvas.width, canvas.height);
    ctx.restore();
    rafIdReg = requestAnimationFrame(renderLoop);
}

function stopFaceReg() {
    if (captureTimer) { clearInterval(captureTimer); captureTimer = null; }
    if (mpLoopId)   { cancelAnimationFrame(mpLoopId); mpLoopId = null; }
    if (rafIdReg)   { cancelAnimationFrame(rafIdReg); rafIdReg = null; }
    if (faceStream) { faceStream.getTracks().forEach(t => t.stop()); faceStream = null; }
    mpNoseRel = null;
}

async function doFaceDelete() {
    if (!confirm('등록된 얼굴 정보를 삭제하시겠습니까?')) return;
    const res  = await fetch(CTX + '/member/face-delete', { method: 'POST' });
    const data = await res.json();
    if (data.success) {
        const badge = document.getElementById('face-reg-badge');
        badge.style.background = '#fff3e0'; badge.style.color = '#e65100';
        badge.textContent = '⚠️ 얼굴이 등록되지 않았습니다.';
        document.getElementById('face-rereg-msg').style.display = 'none';
        document.getElementById('btn-face-delete').style.display = 'none';
        alert('얼굴 등록이 삭제되었습니다.');
    } else {
        alert(data.message || '삭제 실패');
    }
}

async function doRegisterMulti() {
    if (capturedImages.length < 3 || !capturedImages[2]) return;
    if (captureTimer) clearInterval(captureTimer);
    setSubmitEnabled(false);
    setRegStatus('얼굴 등록 중... (정면·좌·우 3장 분석)');
    try {
        const data = await fetch(CTX + '/member/face-register-multi', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ images: capturedImages })
        }).then(r => r.json());

        if (data.success) {
            stopFaceReg();
            setRegStatus('✅ ' + data.message);
            document.getElementById('face-reg-area').style.display = 'none';
            document.getElementById('btn-face-toggle').textContent = '📷 카메라 열기';
            const badge = document.getElementById('face-reg-badge');
            if (badge) {
                badge.style.background = '#e8f5e9'; badge.style.color = '#2e7d32';
                badge.textContent = '✅ 얼굴이 등록되어 있습니다.';
            }
            alert('얼굴 등록이 완료되었습니다.');
        } else {
            setRegStatus('❌ ' + (data.message || '등록 실패. 다시 촬영해 주세요.'));
            resetCapture();   // 처음부터 다시 촬영
        }
    } catch(e) {
        setRegStatus('오류: ' + e.message);
        resetCapture();
    }
}
</script>
</body>
</html>
