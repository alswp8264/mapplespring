import base64
import io
import sys
import concurrent.futures
import numpy as np
from flask import Flask, request, jsonify
from PIL import Image, ImageEnhance
import face_recognition

app = Flask(__name__)

def log(msg):
    print(msg, flush=True)

@app.after_request
def add_cors(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    response.headers['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
    return response

def decode_image(base64_str):
    if ',' in base64_str:
        base64_str = base64_str.split(',')[1]
    img_bytes = base64.b64decode(base64_str)
    img = Image.open(io.BytesIO(img_bytes)).convert('RGB')
    img = ImageEnhance.Brightness(img).enhance(1.1)
    img = ImageEnhance.Contrast(img).enhance(1.1)
    return np.array(img)

def find_faces_fast(img_array):
    """로그인 verify용 - HOG(빠름) 우선"""
    locs = face_recognition.face_locations(img_array, number_of_times_to_upsample=1, model='hog')
    if not locs:
        locs = face_recognition.face_locations(img_array, number_of_times_to_upsample=2, model='hog')
    if not locs:
        locs = face_recognition.face_locations(img_array, model='cnn')
    return locs

def find_faces(img_array):
    """등록 encode용 - CNN 우선 (안경·측면에 강함)"""
    locs = face_recognition.face_locations(img_array, model='cnn')
    if not locs:
        # 업샘플 후 재시도
        from PIL import Image as PILImage
        h, w = img_array.shape[:2]
        pil = PILImage.fromarray(img_array).resize((w*2, h*2), PILImage.LANCZOS)
        up = np.array(pil)
        locs_up = face_recognition.face_locations(up, model='cnn')
        locs = [(t//2, r//2, b//2, l//2) for t, r, b, l in locs_up]
    return locs

def encode_one(img_b64, label):
    """이미지 하나를 인코딩 (병렬 처리용)"""
    try:
        img_array = decode_image(img_b64)
        locs = find_faces(img_array)
        if not locs:
            return None, f'{label} 얼굴 감지 실패'
        encs = face_recognition.face_encodings(img_array, locs)
        if not encs:
            return None, f'{label} 인코딩 실패'
        return encs[0].tolist(), None
    except Exception as e:
        return None, str(e)

@app.route('/face/encode-multi', methods=['POST', 'OPTIONS'])
def encode_multi():
    """3장 병렬 인코딩 (등록용)"""
    if request.method == 'OPTIONS':
        return jsonify({}), 200
    data = request.get_json()
    images = data.get('images', [])
    labels = ['정면', '왼쪽', '오른쪽']
    log(f'[encode-multi] {len(images)}장 병렬 처리 시작')
    try:
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as ex:
            futures = [ex.submit(encode_one, images[i], labels[i]) for i in range(len(images))]
            results = [f.result() for f in futures]

        encodings = []
        for enc, err in results:
            if err:
                log(f'[encode-multi] 실패: {err}')
                return jsonify({'success': False, 'message': err})
            encodings.append(enc)

        log(f'[encode-multi] 성공 ({len(encodings)}장)')
        return jsonify({'success': True, 'encodings': encodings})
    except Exception as e:
        log('[encode-multi] 오류: ' + str(e))
        return jsonify({'success': False, 'message': str(e)})

@app.route('/face/encode', methods=['POST', 'OPTIONS'])
def encode():
    if request.method == 'OPTIONS':
        return jsonify({}), 200
    data = request.get_json()
    log('[encode] 요청 수신')
    try:
        img_array = decode_image(data['image'])
        locations = find_faces(img_array)
        if not locations:
            log('[encode] 얼굴 없음')
            return jsonify({'success': False, 'message': '얼굴을 찾을 수 없습니다.'})
        encodings = face_recognition.face_encodings(img_array, locations)
        if not encodings:
            log('[encode] 인코딩 실패')
            return jsonify({'success': False, 'message': '얼굴 인코딩 실패'})
        log('[encode] 성공')
        return jsonify({'success': True, 'encoding': encodings[0].tolist()})
    except Exception as e:
        log('[encode] 오류: ' + str(e))
        return jsonify({'success': False, 'message': str(e)})

@app.route('/face/verify', methods=['POST', 'OPTIONS'])
def verify():
    if request.method == 'OPTIONS':
        return jsonify({}), 200
    data = request.get_json()
    log('[verify] 요청 수신')
    try:
        img_array = decode_image(data['image'])
        locations = find_faces_fast(img_array)
        if not locations:
            log('[verify] 얼굴 없음')
            return jsonify({'success': False, 'message': '얼굴을 찾을 수 없습니다.'})
        if len(locations) > 1:
            log('[verify] 얼굴 여러 개')
            return jsonify({'success': False, 'message': '얼굴이 여러 개 감지되었습니다.'})

        unknown_encoding = face_recognition.face_encodings(img_array, locations)[0]
        candidates = data.get('candidates', [])
        THRESHOLD = 0.38

        def candidate_encs(enc):
            if isinstance(enc, list) and len(enc) > 0 and isinstance(enc[0], list):
                return [np.array(e) for e in enc]
            return [np.array(enc)]

        best_id, best_dist = None, 1.0
        for c in candidates:
            for known in candidate_encs(c['encoding']):
                dist = float(face_recognition.face_distance([known], unknown_encoding)[0])
                if dist < best_dist:
                    best_dist, best_id = dist, c['memberId']

        if best_id is not None and best_dist <= THRESHOLD:
            log(f'[verify] 인식 성공 → memberId={best_id}, dist={round(best_dist,4)}')
            return jsonify({'success': True, 'memberId': best_id, 'distance': round(best_dist, 4)})
        log(f'[verify] 인식 실패, best_dist={round(best_dist,4)}')
        return jsonify({'success': False, 'message': '인식 실패', 'distance': round(best_dist, 4)})
    except Exception as e:
        log('[verify] 오류: ' + str(e))
        return jsonify({'success': False, 'message': str(e)})

@app.route('/face/landmarks', methods=['POST', 'OPTIONS'])
def landmarks():
    return jsonify({'success': False, 'message': 'deprecated'})

if __name__ == '__main__':
    print("Flask Face Server 시작")
    app.run(host='0.0.0.0', port=5001, debug=False, threaded=True)
