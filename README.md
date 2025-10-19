# Image Util - AI 이미지 처리 서비스

> AI 기반 이미지 배경 제거 및 업스케일링 웹 서비스

## 📌 프로젝트 소개

Image Util은 AI 기술을 활용하여 이미지 배경을 자동으로 제거하고, 저해상도 이미지를 고해상도로 업스케일링하는 웹 서비스입니다. 복잡한 이미지 편집 도구 없이도 누구나 쉽게 전문가 수준의 이미지 처리를 할 수 있습니다.

## ✨ 주요 기능

### 1. 🎨 이미지 배경 제거
- AI가 자동으로 피사체를 감지하고 배경을 제거
- 투명 배경(PNG) 생성
- 3-5초 내 빠른 처리
- 헤어, 털 등 복잡한 경계선도 정확하게 처리

### 2. 📈 이미지 업스케일링
- 저해상도 이미지를 2배/4배 확대
- AI 기술로 디테일과 선명도 보존
- 최대 8000x8000 픽셀 지원
- 얼굴, 텍스트 등 섬세한 부분도 품질 유지

## 🎯 타겟 사용자

- 🛒 **이커머스 셀러**: 제품 사진 배경 제거
- 🎨 **디자이너**: 빠른 이미지 편집 작업
- 📱 **크리에이터**: 썸네일 및 콘텐츠 제작
- 📢 **마케터**: 광고 소재 이미지 처리
- 👨‍💼 **일반 사용자**: 프로필 사진, 프레젠테이션 자료 제작

## 🛠️ 기술 스택

### Frontend
- **Framework**: Next.js 14+ (React 18+)
- **Language**: TypeScript
- **UI**: shadcn/ui + Tailwind CSS
- **State**: Zustand
- **Auth**: Supabase Auth

### Backend (Supabase - BaaS)
- **Authentication**: Supabase Auth
- **Database**: PostgreSQL (Supabase)
- **Storage**: Supabase Storage
- **Real-time**: Supabase Realtime

### AI Processing Server
- **Framework**: FastAPI (Python 3.10+)
- **AI/ML**: PyTorch, ONNX Runtime
- **Image**: OpenCV, PIL/Pillow
- **Deployment**: Railway / Render

### AI Models
- **배경 제거**: U²-Net, MODNet, SAM
- **업스케일링**: Real-ESRGAN, SwinIR, GFPGAN

### Infrastructure
- **Frontend Hosting**: Netlify (자동 배포, CDN)
- **Backend Services**: Supabase (BaaS)
- **AI Server**: Railway / Render
- **Monitoring**: Sentry, Netlify Analytics

## 📂 프로젝트 구조

```
image_util/
├── frontend/          # Next.js 프론트엔드
│   ├── app/          # App Router
│   ├── components/   # React 컴포넌트
│   ├── lib/          # 유틸리티 함수
│   └── public/       # 정적 파일
│
├── backend/          # FastAPI 백엔드
│   ├── api/          # API 엔드포인트
│   ├── models/       # AI 모델
│   ├── services/     # 비즈니스 로직
│   └── utils/        # 헬퍼 함수
│
├── docs/             # 문서
│   └── PRD.md        # 제품 요구사항 문서
│
└── README.md         # 프로젝트 소개
```

## 🚀 빠른 시작

### 사전 요구사항
- Node.js 18+
- Python 3.10+ (AI 서버용)
- Supabase 계정 (무료)
- Netlify 계정 (무료)

### 1. Supabase 프로젝트 설정
```bash
# 1. https://supabase.com 에서 새 프로젝트 생성
# 2. API Keys 복사 (Project Settings > API)
# 3. Database URL 확인
```

### 2. Frontend 설치 및 실행
```bash
cd frontend
npm install

# 환경변수 설정
cp .env.example .env.local
# .env.local에 Supabase 키 입력:
# NEXT_PUBLIC_SUPABASE_URL=your-project-url
# NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

npm run dev
```

### 3. AI 서버 설치 및 실행 (선택사항)
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### 4. Netlify 배포
```bash
# GitHub 리포지토리 연결 후
# Netlify 대시보드에서 환경변수 설정
# 자동 배포 활성화
```

## 📋 개발 로드맵

- [x] PRD 문서 작성
- [x] Next.js 프론트엔드 초기화
- [x] Supabase 클라이언트 설정
- [x] Tailwind CSS 및 shadcn/ui 설정
- [x] Supabase Auth 인증 시스템 구현
- [x] 기본 UI 레이아웃 및 페이지 구조 생성
- [x] 이미지 업로드 컴포넌트 구현
- [x] FastAPI 배경 제거 서버 구현
- [x] **Supabase 데이터베이스 테이블 생성** ✨
- [x] **사용량 제한 시스템 구현** ✨
- [x] **실시간 통계 대시보드** ✨
- [ ] Storage 버킷 생성 (수동)
- [ ] 테스트 및 배포
- [ ] 베타 출시 및 피드백 수집
- [ ] 정식 출시

자세한 로드맵은 [PRD.md](./PRD.md) 문서를 참고하세요.

## 💰 비즈니스 모델

### 무료 플랜
- 배경 제거: 5개/일
- 업스케일링: 3개/일
- 최대 파일 크기: 5MB

### 프로 플랜 ($9.99/월)
- 배경 제거: 무제한
- 업스케일링: 무제한
- 최대 파일 크기: 20MB
- 일괄 처리: 10장
- 워터마크 없음

## 📄 문서

- [📋 PRD (제품 요구사항 문서)](./PRD.md)
- [🎨 UI/UX 디자인](./docs/design.md) (예정)
- [🔧 API 문서](./docs/api.md) (예정)
- [📚 개발 가이드](./docs/development.md) (예정)

## 🤝 기여하기

이 프로젝트는 현재 초기 개발 단계입니다. 기여를 원하시면 다음 단계를 따라주세요:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 라이선스

TBD

## 📞 문의

프로젝트 관련 문의사항이 있으시면 이슈를 등록해주세요.

---

**Made with ❤️ for better image processing**

