# Image Util Backend

FastAPI 기반의 AI 이미지 처리 서버

## 기술 스택

- **Framework**: FastAPI
- **Language**: Python 3.10+
- **AI/ML**: PyTorch, rembg
- **Image Processing**: Pillow, OpenCV

## 설치

### 가상환경 생성

```bash
python3 -m venv venv

# macOS/Linux
source venv/bin/activate

# Windows
venv\Scripts\activate
```

### 의존성 설치

```bash
pip install -r requirements.txt
```

**참고**: 첫 실행 시 rembg가 AI 모델 (~200MB)을 자동으로 다운로드합니다.

## 실행

### 개발 모드

```bash
python main.py
```

또는

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 프로덕션 모드

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## API 문서

서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API 엔드포인트

### `GET /`
서버 상태 및 API 정보

### `GET /health`
헬스 체크

### `POST /api/remove-background`
이미지 배경 제거

**Request:**
- Content-Type: `multipart/form-data`
- Body: `file` (이미지 파일)

**Response:**
- Content-Type: `image/png`
- 배경이 제거된 PNG 이미지

**제한사항:**
- 최대 파일 크기: 10MB
- 지원 형식: JPG, PNG, WebP

### `POST /api/upscale` (추후 구현)
이미지 업스케일링

## 배경 제거 성능

- **CPU 모드**: 이미지당 3-5초
- **GPU 모드**: 이미지당 1-2초 (CUDA 필요)

## 배포

### Docker (추천)

```dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Railway

```bash
# railway.toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "uvicorn main:app --host 0.0.0.0 --port $PORT"
```

### Render

**Build Command:**
```bash
pip install -r requirements.txt
```

**Start Command:**
```bash
uvicorn main:app --host 0.0.0.0 --port $PORT
```

## GPU 지원

GPU를 사용하려면 PyTorch CUDA 버전을 설치하세요:

```bash
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
```

## 문제 해결

### rembg 모델 다운로드 실패

```bash
# 수동 모델 다운로드
python -c "from rembg import remove, new_session; session = new_session('u2net')"
```

### 메모리 부족

- 이미지 크기 제한 줄이기
- 프로세스 워커 수 줄이기
- 서버 메모리 증설

## 더 자세한 정보

전체 프로젝트 설정은 [SETUP.md](../SETUP.md)를 참고하세요.

