<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인 - Mapple</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js" crossorigin="anonymous"></script>
    <style>
        .divider { display:flex; align-items:center; margin:20px 0; color:#aaa; font-size:13px; }
        .divider::before, .divider::after { content:''; flex:1; height:1px; background:#e0e0e0; }
        .divider::before { margin-right:10px; }
        .divider::after  { margin-left:10px; }

        .btn-face {
            width:100%; padding:11px; border:none; border-radius:8px; cursor:pointer;
            background:#1a73e8; color:#fff; font-size:15px; font-weight:600;
            display:flex; align-items:center; justify-content:center; gap:8px;
        }
        .btn-face:hover { background:#1558b0; }

        /* ── 소셜 로그인 버튼 ── */
        .btn-social {
            display:flex; align-items:center; justify-content:center; gap:10px;
            width:100%; padding:11px 0; border-radius:8px;
            font-size:15px; font-weight:700; text-decoration:none;
            margin-bottom:10px; transition: opacity .15s, box-shadow .15s;
            box-shadow: 0 1px 4px rgba(0,0,0,.12);
        }
        .btn-social:hover { opacity:.88; box-shadow: 0 3px 10px rgba(0,0,0,.18); }
        .btn-google {
            background:#fff; color:#3c4043;
            border:1.5px solid #dadce0;
        }
        .btn-kakao {
            background:#FEE500; color:#3C1E1E;
            border:none;
        }

        /* 캔버스 래퍼 */
        #face-area { display:none; margin-top:16px; }
        .face-canvas-wrap {
            position: relative;
            border-radius: 10px;
            overflow: hidden;
            border: 2px solid #e0e0e0;
            background: #000;
        }
        #face-canvas { width: 100%; display: block; }
        #face-status {
            font-size: 13px; color: #555; margin-top: 8px;
            min-height: 20px; text-align: center;
        }
        /* 게이지 */
        .face-gauge-wrap { margin-top: 12px; }
        .face-gauge-labels {
            display: flex; justify-content: space-between;
            font-size: 11px; margin-bottom: 5px;
        }
        .face-gauge-track {
            height: 12px; background: #eef1f7;
            border-radius: 8px; overflow: hidden;
        }
        #face-gauge {
            height: 100%; width: 0%;
            background: linear-gradient(90deg, #5b9bff, #4f8ef7);
            border-radius: 8px; transition: width .35s ease;
        }
        #face-success-box {
            display: none;
            margin-top: 14px;
            background: linear-gradient(135deg, #e8f5e9, #f1f8e9);
            border: 1.5px solid #a5d6a7;
            border-radius: 12px;
            padding: 18px 16px;
            text-align: center;
        }
        #face-success-box .success-icon { font-size: 40px; margin-bottom: 6px; }
        #face-success-box .success-title {
            font-size: 17px; font-weight: 800; color: #2e7d32; margin-bottom: 4px;
        }
        #face-success-box .success-sub {
            font-size: 13px; color: #555; margin-bottom: 12px;
        }
        #face-countdown {
            display: inline-flex; align-items: center; justify-content: center;
            width: 48px; height: 48px; border-radius: 50%;
            border: 3px solid #4caf50;
            font-size: 22px; font-weight: 900; color: #2e7d32;
            animation: countdown-pulse 1s ease-in-out infinite;
        }
        @keyframes countdown-pulse {
            0%,100% { transform: scale(1); opacity: 1; }
            50%      { transform: scale(1.15); opacity: 0.7; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div class="container">
    <div class="form-wrap">
        <h2>로그인</h2>
        <c:if test="${not empty msg}">
            <div class="error-msg">${msg}</div>
        </c:if>
        <c:if test="${param.msg == 'pw_reset'}">
            <div class="success-msg">비밀번호가 변경되었습니다. 새 비밀번호로 로그인해 주세요.</div>
        </c:if>

        <%-- 기존 로그인 폼 --%>
        <form action="${pageContext.request.contextPath}/member/login" method="post">
            <div class="form-group">
                <label>아이디</label>
                <input type="text" name="loginId" placeholder="아이디 입력" required>
            </div>
            <div class="form-group">
                <label>비밀번호</label>
                <input type="password" name="password" placeholder="비밀번호 입력" required>
            </div>
            <button type="submit" class="btn" style="width:100%; margin-top:4px;">로그인</button>
        </form>

        <div class="divider">또는</div>

        <%-- 얼굴 인식 로그인 --%>
        <div>
            <button class="btn-face" onclick="toggleFace()">
                <span>📷</span> 얼굴 인식으로 로그인
            </button>
            <p style="font-size:11px; color:#aaa; margin:6px 0 0; text-align:center;">
                ※ 로그인 후
                <a href="${pageContext.request.contextPath}/member/mypage" style="color:#4f8ef7;">마이페이지</a>
                에서 얼굴을 먼저 등록해야 합니다.
            </p>

            <div id="face-area">
                <div class="face-canvas-wrap">
                    <canvas id="face-canvas"></canvas>
                </div>
                <div id="face-status"></div>

                <%-- 3단계 게이지 --%>
                <div class="face-gauge-wrap">
                    <div class="face-gauge-labels">
                        <span id="step-lbl-1" style="color:#98a1b5;">① 정면</span>
                        <span id="step-lbl-2" style="color:#98a1b5;">② 왼쪽</span>
                        <span id="step-lbl-3" style="color:#98a1b5;">③ 오른쪽</span>
                    </div>
                    <div class="face-gauge-track">
                        <div id="face-gauge"></div>
                    </div>
                </div>

                <div style="text-align:center; margin-top:10px;">
                    <button id="btn-retry"
                            style="display:none; background:#4f8ef7; color:#fff; border:none;
                                   padding:8px 22px; border-radius:8px; font-size:14px; cursor:pointer;"
                            onclick="startCapture()">
                        🔄 다시 촬영
                    </button>
                </div>

                <%-- 인식 성공 박스 --%>
                <div id="face-success-box">
                    <div class="success-icon">✅</div>
                    <div class="success-title">얼굴 인식 완료!</div>
                    <div class="success-sub">잠시 후 자동으로 로그인됩니다.</div>
                    <div id="face-countdown">3</div>
                </div>

                <%-- hidden video (카메라 소스) --%>
                <video id="face-video" autoplay playsinline
                       style="display:none; width:1px; height:1px;"></video>
            </div>
        </div>

        <div class="divider">소셜 로그인</div>

        <%-- Google 로그인 --%>
        <a href="${pageContext.request.contextPath}/member/oauth/google" class="btn-social btn-google">
            <svg width="18" height="18" viewBox="0 0 48 48">
                <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.18 1.48-4.97 2.31-8.16 2.31-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
            </svg>
            Google로 로그인
        </a>

        <%-- Kakao 로그인 --%>
        <a href="${pageContext.request.contextPath}/member/oauth/kakao" class="btn-social btn-kakao">
            <svg width="18" height="18" viewBox="0 0 24 24">
                <path fill="#3C1E1E" d="M12 3C6.48 3 2 6.72 2 11.3c0 2.91 1.82 5.47 4.57 6.97l-1.17 4.32 5.03-3.32c.51.07 1.03.11 1.57.11 5.52 0 10-3.72 10-8.3C22 6.72 17.52 3 12 3z"/>
            </svg>
            카카오로 로그인
        </a>

        <p style="text-align:center; margin-top:16px; font-size:13px; color:#888;">
            <a href="${pageContext.request.contextPath}/member/findId" style="color:#888;">아이디 찾기</a> ·
            <a href="${pageContext.request.contextPath}/member/findPw" style="color:#888;">비밀번호 찾기</a>
        </p>
        <p style="text-align:center; margin-top:6px; font-size:13px; color:#888;">
            계정이 없으신가요?
            <a href="${pageContext.request.contextPath}/member/join" style="color:#4f8ef7; font-weight:600;">회원가입</a>
        </p>
    </div>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
const CTX = '${pageContext.request.contextPath}';
let stream = null, rafId = null, captureTimer = null, mpLoopId = null;
const FRONT_T = 0.20, SIDE_T = 0.35;
const STEP_MSG = ['① 정면을 바라봐 주세요', '② 고개를 왼쪽으로 돌려주세요', '③ 고개를 오른쪽으로 돌려주세요'];
let captureStep = 0, capturedImages = [], mpNoseRel = null;
let mpReady = false, mpFrameCount = 0;

// ── face-api.js 모델 로드 (로컬) ─────────────────────────────
const MODEL_URL = CTX + '/resources/face-api-weights';
Promise.all([
    faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
    faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL)
]).then(() => { mpReady = true; }).catch(e => console.error('[face-api]', e));

function setStatus(msg) { document.getElementById('face-status').textContent = msg; }
function setGauge(pct)  { document.getElementById('face-gauge').style.width = pct + '%'; }
function markStep(n, done) {
    const el = document.getElementById('step-lbl-' + n);
    el.style.color = done ? '#2e7d32' : '#98a1b5';
    el.style.fontWeight = done ? '700' : '400';
}

function toggleFace() {
    const area = document.getElementById('face-area');
    if (!stream) { area.style.display = 'block'; startCamera(); }
    else         { area.style.display = 'none';  stopAll(); }
}

function startCamera() {
    navigator.mediaDevices.getUserMedia({ video: { width:640, height:480 } })
    .then(s => {
        stream = s;
        const v = document.getElementById('face-video');
        v.srcObject = s;
        v.onloadedmetadata = () => {
            const canvas = document.getElementById('face-canvas');
            canvas.width  = v.videoWidth  || 640;
            canvas.height = v.videoHeight || 480;
            renderLoop();
            startMpLoop();
            startCapture();
        };
    })
    .catch(() => setStatus('카메라 접근 권한이 필요합니다.'));
}

async function startMpLoop() {
    const canvas = document.getElementById('face-canvas');
    async function loop() {
        if (!stream) return;
        if (mpReady && canvas.width > 10) {
            try {
                const result = await faceapi
                    .detectSingleFace(canvas, new faceapi.TinyFaceDetectorOptions({ inputSize: 224, scoreThreshold: 0.3 }))
                    .withFaceLandmarks();
                if (result) {
                    mpFrameCount++;
                    const lm = result.landmarks;
                    const nose = lm.getNose()[3];
                    const le = lm.getLeftEye(),  re = lm.getRightEye();
                    const leX = le.reduce((s,p) => s+p.x, 0) / le.length;
                    const reX = re.reduce((s,p) => s+p.x, 0) / re.length;
                    const eyeDist = Math.abs(reX - leX) || 0.001;
                    mpNoseRel = (nose.x - (leX + reX) / 2) / eyeDist;
                } else { mpNoseRel = null; }
            } catch(e) {}
        }
        mpLoopId = requestAnimationFrame(loop);
    }
    loop();
}

function startCapture() {
    captureStep = 0; capturedImages = []; mpNoseRel = null;
    setGauge(0);
    [1,2,3].forEach(n => markStep(n, false));
    document.getElementById('btn-retry').style.display = 'none';
    setStatus(STEP_MSG[0]);
    if (captureTimer) clearInterval(captureTimer);
    captureTimer = setInterval(pollCapture, 400);
}

function captureFull() {
    return document.getElementById('face-canvas').toDataURL('image/jpeg', 0.85);
}

function pollCapture() {
    if (!stream || captureStep >= 3) return;
    const rel = mpNoseRel;
    if (rel === null) {
        let dbg = !mpReady ? 'MP모델로딩중...' : '얼굴감지중(프레임:' + mpFrameCount + ')';
        setStatus(STEP_MSG[captureStep] + '  (' + dbg + ')');
        return;
    }

    let ok = false;
    if      (captureStep === 0) ok = Math.abs(rel) < FRONT_T;
    else if (captureStep === 1) ok = rel < -SIDE_T;
    else if (captureStep === 2) ok = rel >  SIDE_T;

    setStatus(STEP_MSG[captureStep] + '  (rel=' + rel.toFixed(2) + ')');
    if (!ok) return;

    capturedImages[captureStep] = captureFull();
    captureStep++;
    setGauge(Math.round(captureStep / 3 * 100));
    markStep(captureStep, true);
    if (captureStep < 3) {
        setStatus('✅ ' + captureStep + '/3 완료 — ' + STEP_MSG[captureStep]);
    } else {
        clearInterval(captureTimer);
        setStatus('✅ 3단계 완료! 얼굴 인식 중...');
        setTimeout(doVerify, 600);
    }
}

function renderLoop() {
    if (!stream) return;
    const v = document.getElementById('face-video');
    const canvas = document.getElementById('face-canvas');
    const ctx = canvas.getContext('2d');
    ctx.save(); ctx.scale(-1,1);
    ctx.drawImage(v, -canvas.width, 0, canvas.width, canvas.height);
    ctx.restore();
    rafId = requestAnimationFrame(renderLoop);
}

function stopAll() {
    if (captureTimer) { clearInterval(captureTimer); captureTimer = null; }
    if (mpLoopId)  { cancelAnimationFrame(mpLoopId); mpLoopId = null; }
    if (rafId)     { cancelAnimationFrame(rafId); rafId = null; }
    if (stream)    { stream.getTracks().forEach(t => t.stop()); stream = null; }
    mpNoseRel = null;
}

async function doVerify() {
    // 3장 중 정면(0번) 이미지로 인식
    const imageData = capturedImages[0] || captureFull();
    stopAll();

    try {
        const data = await fetch(CTX + '/member/face-login', {
            method:'POST', headers:{'Content-Type':'application/json'},
            body: JSON.stringify({ image: imageData })
        }).then(r => r.json());

        if (data.success) {
            showSuccessCountdown();
        } else {
            setStatus('❌ ' + (data.message || '인식 실패. 다시 시도해 주세요.'));
            document.getElementById('btn-retry').style.display = 'inline-block';
            startCamera();
        }
    } catch(e) {
        setStatus('오류: ' + e.message);
        document.getElementById('btn-retry').style.display = 'inline-block';
        startCamera();
    }
}

// ── 인식 성공 → 3초 카운트다운 후 로그인 ─────────────────────
function showSuccessCountdown() {
    document.querySelector('.face-canvas-wrap').style.display = 'none';
    document.querySelector('.face-gauge-wrap').style.display  = 'none';
    document.getElementById('face-status').style.display      = 'none';
    document.getElementById('btn-retry').style.display        = 'none';
    document.getElementById('face-success-box').style.display = 'block';

    let count = 3;
    const el = document.getElementById('face-countdown');
    el.textContent = count;
    const timer = setInterval(() => {
        count--;
        el.textContent = count;
        if (count <= 0) { clearInterval(timer); window.location.href = CTX + '/'; }
    }, 1000);
}
</script>
</body>
</html>
