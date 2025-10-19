# Image Util 설정 가이드

이 문서는 Image Util 프로젝트를 로컬 환경에서 실행하기 위한 상세한 설정 가이드입니다.

## 📋 사전 요구사항

- Node.js 18.0 이상
- Python 3.10 이상
- Supabase 계정 (무료)
- Git

---

## 1️⃣ Supabase 프로젝트 설정

### 1.1 프로젝트 생성

1. [Supabase](https://supabase.com)에 접속하여 로그인
2. "New Project" 클릭
3. Organization 선택 (없으면 생성)
4. 프로젝트 정보 입력:
   - **Name**: `image-util` (원하는 이름)
   - **Database Password**: 강력한 비밀번호 설정 (저장 필수!)
   - **Region**: `Northeast Asia (Seoul)`
   - **Pricing Plan**: `Free`
5. "Create new project" 클릭

### 1.2 API Keys 확인

프로젝트 생성 후:
1. 왼쪽 메뉴에서 `Settings` → `API` 클릭
2. 다음 정보를 복사해둡니다:
   - **Project URL**: `https://xxx.supabase.co`
   - **anon public** key

### 1.3 Storage Bucket 생성

1. 왼쪽 메뉴에서 `Storage` 클릭
2. "New bucket" 클릭
3. Bucket 생성:
   - **Name**: `images`
   - **Public bucket**: ✅ 체크
4. "Create bucket" 클릭

### 1.4 인증 설정

1. 왼쪽 메뉴에서 `Authentication` → `Providers` 클릭
2. Email 인증이 활성화되어 있는지 확인
3. (선택사항) 이메일 인증 없이 테스트하려면:
   - `Settings` → `Auth` → `Email auth` 섹션
   - `Enable email confirmations` 체크 해제

---

## 2️⃣ 프론트엔드 설정 (Next.js)

### 2.1 의존성 설치

```bash
cd frontend
npm install
```

### 2.2 환경변수 설정

프론트엔드 루트에 `.env.local` 파일 생성:

```bash
# frontend/.env.local
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_AI_SERVER_URL=http://localhost:8000
```

**중요**: Supabase에서 복사한 실제 값으로 대체하세요!

### 2.3 개발 서버 실행

```bash
npm run dev
```

브라우저에서 http://localhost:3000 접속

---

## 3️⃣ 백엔드 설정 (FastAPI)

### 3.1 Python 가상환경 생성

```bash
cd backend

# macOS/Linux
python3 -m venv venv
source venv/bin/activate

# Windows
python -m venv venv
venv\Scripts\activate
```

### 3.2 의존성 설치

```bash
pip install -r requirements.txt
```

**참고**: 첫 실행 시 rembg가 AI 모델을 다운로드합니다 (~200MB). 
인터넷 연결이 필요하며 몇 분 소요될 수 있습니다.

### 3.3 서버 실행

```bash
python main.py
```

또는

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

API 문서 확인: http://localhost:8000/docs

---

## 4️⃣ 전체 시스템 실행

### 터미널 1 - 백엔드 서버

```bash
cd backend
source venv/bin/activate  # Windows: venv\Scripts\activate
python main.py
```

### 터미널 2 - 프론트엔드 서버

```bash
cd frontend
npm run dev
```

---

## 5️⃣ 기능 테스트

### 회원가입 테스트

1. http://localhost:3000 접속
2. "회원가입" 클릭
3. 이메일과 비밀번호 입력
4. 이메일 인증 (설정한 경우)
5. 로그인

### 배경 제거 테스트

1. 대시보드 접속
2. 이미지 드래그 앤 드롭 또는 클릭하여 업로드
3. AI 처리 대기 (5-10초)
4. 결과 확인 및 다운로드

---

## 6️⃣ 문제 해결

### 프론트엔드 오류

#### "Supabase client initialization error"
- `.env.local` 파일이 올바르게 생성되었는지 확인
- Supabase URL과 Key가 정확한지 확인
- 개발 서버 재시작

#### "Failed to fetch"
- 백엔드 서버가 실행 중인지 확인 (http://localhost:8000)
- CORS 오류인 경우 backend/main.py의 CORS 설정 확인

### 백엔드 오류

#### "Module not found: rembg"
```bash
pip install -r requirements.txt
```

#### "CUDA not available" (정상)
- CPU 모드로 동작합니다 (속도는 느리지만 정상 작동)
- GPU가 필요한 경우 PyTorch CUDA 버전 설치 필요

#### 포트 충돌
```bash
# 다른 포트로 실행
uvicorn main:app --port 8001
# 프론트엔드 환경변수도 변경 필요
```

### Supabase 오류

#### "Invalid API key"
- Supabase 대시보드에서 API Keys 재확인
- `.env.local` 파일의 키 값 재확인

#### "Row Level Security policy"
- 현재는 RLS가 설정되지 않았으므로 이 오류는 발생하지 않아야 함
- 향후 RLS 설정 시 정책 추가 필요

---

## 7️⃣ 프로덕션 배포

### Netlify (프론트엔드)

1. GitHub에 코드 푸시
2. [Netlify](https://netlify.com) 로그인
3. "Import from Git" 클릭
4. 리포지토리 선택
5. Build 설정:
   - **Base directory**: `frontend`
   - **Build command**: `npm run build`
   - **Publish directory**: `frontend/.next`
6. 환경변수 설정 (Settings → Environment variables)
7. 배포 시작

### Railway/Render (백엔드)

#### Railway
1. [Railway](https://railway.app) 로그인
2. "New Project" → "Deploy from GitHub repo"
3. 리포지토리 선택
4. Root directory: `backend` 설정
5. Start command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
6. 배포 완료 후 URL 복사

#### Render
1. [Render](https://render.com) 로그인
2. "New" → "Web Service"
3. 리포지토리 연결
4. 설정:
   - **Root Directory**: `backend`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. 배포

---

## 8️⃣ 다음 단계

- [ ] 데이터베이스 테이블 생성 (processing_history, usage_stats)
- [ ] 사용량 제한 기능 구현
- [ ] 이미지 업스케일링 기능 추가
- [ ] 결제 시스템 연동 (Stripe)
- [ ] 성능 최적화
- [ ] 에러 모니터링 (Sentry)

---

## 📚 참고 자료

- [Supabase 문서](https://supabase.com/docs)
- [Next.js 문서](https://nextjs.org/docs)
- [FastAPI 문서](https://fastapi.tiangolo.com/)
- [rembg 문서](https://github.com/danielgatis/rembg)

---

**문제가 발생하면 GitHub Issues에 등록해주세요!**

