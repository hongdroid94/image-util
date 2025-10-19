# PRD (Product Requirements Document)
## 이미지 배경 제거 및 업스케일링 서비스

---

## 📋 문서 정보

| 항목 | 내용 |
|------|------|
| **프로젝트명** | Image Util - AI 이미지 처리 서비스 |
| **버전** | 1.1 |
| **최종 수정일** | 2025년 10월 18일 |
| **문서 유형** | Product Requirements Document |
| **목표 출시일** | TBD |

---

## 1. 제품 개요 (Product Overview)

### 1.1 목적
AI 기반의 이미지 배경 제거 및 업스케일링 기능을 제공하는 웹 서비스를 개발하여, 개인 및 소규모 비즈니스 사용자가 전문적인 이미지 편집을 쉽고 빠르게 수행할 수 있도록 지원합니다.

### 1.2 비전
**"누구나 클릭 한 번으로 전문가 수준의 이미지 처리를 경험할 수 있는 서비스"**

### 1.3 핵심 가치 제안
- ⚡ **간편함**: 복잡한 도구 없이 드래그 앤 드롭으로 즉시 처리
- 🎯 **정확성**: AI 기반 고품질 배경 제거
- 📈 **품질 향상**: 이미지 해상도를 손실 없이 확대
- 💰 **경제성**: 저렴한 비용으로 전문 도구 대체

---

## 2. 문제 정의 및 해결 방안

### 2.1 현재 문제점
- **복잡성**: Photoshop 등 전문 도구는 학습 곡선이 높음
- **비용**: 고가의 소프트웨어 라이센스 비용 부담
- **시간**: 수동 배경 제거에 많은 시간 소요
- **품질**: 저해상도 이미지 확대 시 품질 저하

### 2.2 우리의 솔루션
- AI 자동화로 전문 지식 없이도 고품질 결과물 생성
- 웹 기반 서비스로 별도 설치 불필요
- 직관적인 UI로 몇 초 내에 작업 완료
- 최신 AI 모델로 디테일 보존하며 이미지 확대

---

## 3. 타겟 사용자 (Target Users)

### 3.1 주요 사용자 페르소나

#### 페르소나 1: 온라인 셀러 (이커머스)
- **이름**: 김상품 (29세)
- **직업**: 스마트스토어 운영자
- **니즈**: 제품 사진의 배경을 깔끔하게 제거하여 전문적인 상품 페이지 제작
- **페인포인트**: 사진 편집에 시간 투자 어려움, 전문 디자이너 고용 비용 부담

#### 페르소나 2: 프리랜서 디자이너
- **이름**: 박디자인 (32세)
- **직업**: 프리랜서 그래픽 디자이너
- **니즈**: 클라이언트 작업을 위한 빠른 배경 제거 및 이미지 품질 개선
- **페인포인트**: 반복 작업에 소요되는 시간, 저해상도 소스 이미지 처리

#### 페르소나 3: 소셜 미디어 크리에이터
- **이름**: 최인플루 (26세)
- **직업**: 유튜버/인스타그래머
- **니즈**: 썸네일, 포스트용 고품질 이미지 제작
- **페인포인트**: 모바일에서 촬영한 저화질 이미지, 복잡한 편집 도구

### 3.2 부차적 사용자
- 마케팅 팀원
- 블로거/콘텐츠 작가
- 학생/교육자
- 소규모 스타트업

---

## 4. 핵심 기능 및 요구사항

### 4.1 필수 기능 (MVP - Must Have)

#### 기능 0: 사용자 인증 (Supabase Auth)

**기능 설명**  
Supabase Auth를 활용한 사용자 회원가입, 로그인, 세션 관리 기능을 제공합니다.

**세부 요구사항**
- **회원가입**: 이메일/비밀번호 기반 회원가입
- **로그인**: 이메일/비밀번호 로그인
- **소셜 로그인**: Google, GitHub (선택적, Phase 2)
- **비밀번호 재설정**: 이메일 기반 비밀번호 찾기
- **세션 관리**: JWT 기반 자동 세션 관리
- **프로필 관리**: 사용자 정보 수정

**사용자 플로우**
```
1. 회원가입: 이메일 입력 → 비밀번호 설정 → 이메일 인증
2. 로그인: 이메일/비밀번호 입력 → 자동 로그인 유지
3. 로그아웃: 세션 종료
```

**기술적 요구사항**
- Supabase Auth API 사용
- Next.js Middleware로 보호된 라우트 구현
- Client-side와 Server-side 인증 처리
- Cookie 기반 세션 저장

**검증 기준**
- [ ] 회원가입 후 이메일 인증 완료
- [ ] 로그인 상태 유지 (새로고침 시에도)
- [ ] 비인증 사용자 접근 제한
- [ ] 안전한 비밀번호 정책 적용

---

#### 기능 1: 이미지 배경 제거

**기능 설명**  
AI 기술을 사용하여 이미지에서 배경을 자동으로 감지하고 제거합니다.

**세부 요구사항**
- **입력 형식**: JPG, PNG, WebP (최대 10MB)
- **출력 형식**: PNG (투명 배경)
- **처리 시간**: 평균 3-5초 이내
- **정확도**: 사람, 제품, 동물 등 주요 피사체 95% 이상 정확도
- **프리뷰**: 처리 전/후 비교 뷰 제공
- **다운로드**: 원본 해상도 유지하여 다운로드

**사용자 플로우**
```
1. 이미지 업로드 (드래그앤드롭 또는 파일 선택)
2. AI 자동 처리 (로딩 인디케이터 표시)
3. 결과 프리뷰 (Before/After 비교)
4. 다운로드 (PNG 형식)
```

**기술적 요구사항**
- U²-Net, MODNet, 또는 Segment Anything Model (SAM) 사용
- GPU 가속 지원 (CUDA/MPS)
- 배치 처리를 위한 큐 시스템

**검증 기준**
- [ ] 다양한 배경에서 95% 이상 정확도
- [ ] 5초 이내 처리 완료
- [ ] 헤어/털 등 디테일한 영역 처리
- [ ] 투명 배경이 정확한 PNG 생성

---

#### 기능 2: 이미지 업스케일링

**기능 설명**  
AI 기술을 사용하여 저해상도 이미지를 고해상도로 확대하면서 디테일을 보존하고 선명도를 향상시킵니다.

**세부 요구사항**
- **입력 형식**: JPG, PNG, WebP (최대 10MB)
- **출력 형식**: JPG, PNG (사용자 선택)
- **업스케일 배율**: 2x, 4x 선택 가능
- **최대 출력 해상도**: 8000 x 8000 픽셀
- **처리 시간**: 
  - 2x: 5-10초
  - 4x: 10-20초
- **품질**: PSNR 30dB 이상, SSIM 0.9 이상

**사용자 플로우**
```
1. 이미지 업로드
2. 업스케일 배율 선택 (2x/4x)
3. AI 처리 (진행률 표시)
4. 결과 프리뷰 (확대/축소 가능)
5. 다운로드 (형식 선택)
```

**기술적 요구사항**
- Real-ESRGAN, GFPGAN, 또는 SwinIR 모델 사용
- 타일 기반 처리로 대용량 이미지 지원
- 메모리 관리 최적화

**검증 기준**
- [ ] 2x 업스케일 10초 이내 완료
- [ ] 4x 업스케일 20초 이내 완료
- [ ] 텍스트, 얼굴, 디테일 선명도 유지
- [ ] 아티팩트 최소화

---

### 4.2 추가 기능 (Nice to Have)

#### 1순위
- **일괄 처리**: 여러 이미지 동시 업로드 및 처리 (최대 10장)
- **결과 조정**: 배경 제거 후 엣지 다듬기 슬라이더
- **배경 색상 변경**: 투명 대신 단색 배경 선택 (흰색, 검정, 커스텀)

#### 2순위
- **히스토리**: 최근 처리한 이미지 목록 (로그인 시)
- **API 제공**: 개발자를 위한 RESTful API
- **모바일 최적화**: 반응형 디자인

#### 3순위
- **AI 배경 생성**: 자동 배경 합성
- **이미지 노이즈 제거**: 디노이징 기능
- **포맷 변환**: 다양한 이미지 포맷 간 변환

---

## 5. 기술 스택 및 아키텍처

### 5.1 프론트엔드
```
- Framework: Next.js 14+ (React 18+)
- Language: TypeScript
- UI Library: shadcn/ui + Tailwind CSS
- State Management: Zustand 또는 React Context
- Authentication: Supabase Auth (@supabase/auth-helpers-nextjs)
- Backend Client: Supabase JavaScript Client
- File Upload: react-dropzone
- HTTP Client: Axios
```

### 5.2 백엔드

#### Supabase (BaaS - Backend as a Service)
```
- Authentication: Supabase Auth (이메일/소셜 로그인)
- Database: PostgreSQL (자동 제공)
- Storage: Supabase Storage (이미지 파일 저장)
- Real-time: Supabase Realtime (선택적)
- Row Level Security (RLS): 사용자별 데이터 보안
- Edge Functions: 간단한 서버 로직 (선택적)
```

#### AI 처리 서버 (Python/FastAPI)
```
- Framework: FastAPI (Python 3.10+)
- AI/ML: PyTorch, ONNX Runtime
- Image Processing: OpenCV, PIL/Pillow
- Task Queue: 선택적 (초기에는 동기 처리)
- Deployment: Railway, Render, 또는 AWS Lambda
- API Documentation: Swagger/OpenAPI
```

**아키텍처 전략**
- Supabase: 사용자 인증, 데이터베이스, 파일 스토리지
- AI 서버: 이미지 처리 전용 (배경 제거, 업스케일링)
- 분리 이유: AI 모델 처리는 GPU와 높은 컴퓨팅 파워 필요

### 5.3 AI 모델
```
배경 제거:
- Primary: U²-Net 또는 RMBG-v1.4
- Alternative: MODNet, Segment Anything

업스케일링:
- Primary: Real-ESRGAN
- Alternative: SwinIR, GFPGAN (얼굴 특화)
```

### 5.4 인프라
```
- Frontend Hosting: Netlify (자동 배포, CDN 포함)
  - Git 연동 자동 배포 (GitHub/GitLab)
  - Preview Deployments (PR별 미리보기)
  - Environment Variables 관리
  - 무료 SSL 인증서
  
- Backend Services: Supabase (BaaS)
  - Database: PostgreSQL (Supabase 제공)
  - Storage: Supabase Storage (이미지 저장)
  - Authentication: Supabase Auth
  - CDN: 자동 포함
  
- AI Processing Server: Railway / Render / AWS Lambda
  - Python FastAPI 서버
  - GPU 인스턴스 (필요 시)
  - Docker 컨테이너 배포
  
- Monitoring & Analytics:
  - Frontend: Netlify Analytics
  - Error Tracking: Sentry
  - Application Monitoring: Supabase Dashboard
```

**비용 효율적인 구조**
- Netlify: 무료 티어로 시작 가능 (월 100GB 대역폭)
- Supabase: 무료 티어로 시작 가능 (500MB DB, 1GB Storage)
- AI 서버: 사용량 기반 과금 (Railway/Render $5-20/월)

### 5.5 시스템 아키텍처

```
┌──────────────────────────────────────────────┐
│              사용자 (Browser)                 │
└────────┬─────────────────────────┬───────────┘
         │                         │
         │ HTTPS                   │ HTTPS
         ▼                         ▼
┌─────────────────┐       ┌──────────────────────┐
│    Frontend     │       │    AI Processing     │
│    (Netlify)    │       │      Server          │
│   - Next.js     │       │   (Railway/Render)   │
│   - React       │◀──────│   - FastAPI          │
│   - TypeScript  │ API   │   - PyTorch Models   │
└────────┬────────┘ Call  │   - Image Processing │
         │                └──────────────────────┘
         │ API Calls
         │ (Auth, DB, Storage)
         ▼
┌──────────────────────────────────────────────┐
│              Supabase (BaaS)                 │
├──────────────┬───────────────┬───────────────┤
│  Auth        │  PostgreSQL   │   Storage     │
│  - 로그인     │  - 사용자정보  │  - 이미지파일  │
│  - 회원가입   │  - 처리이력   │  - 결과파일    │
│  - 세션관리   │  - 사용량통계  │  - 임시파일    │
└──────────────┴───────────────┴───────────────┘
```

**데이터 플로우**
1. 사용자가 Netlify 호스팅 웹사이트 접속
2. Supabase Auth로 로그인/회원가입
3. 이미지 업로드 → Supabase Storage에 저장
4. AI 처리 요청 → Railway/Render 서버로 전송
5. AI 서버에서 처리 완료 → 결과를 Supabase Storage에 저장
6. 처리 이력을 Supabase DB에 기록
7. 사용자에게 결과 전달 및 다운로드

**장점**
- 서버 관리 부담 최소화 (Supabase, Netlify 활용)
- 무료 티어로 시작 가능 (초기 비용 절감)
- 자동 스케일링 및 CDN 적용
- Git 기반 자동 배포로 개발 효율성 증대

---

## 6. UI/UX 요구사항

### 6.1 디자인 원칙
- **단순함**: 3클릭 이내에 작업 완료
- **직관성**: 설명 없이도 사용 가능한 인터페이스
- **즉각성**: 실시간 피드백 및 프리뷰
- **반응성**: 모바일, 태블릿, 데스크톱 최적화

### 6.2 주요 화면 구성

#### 로그인/회원가입 화면
```
┌────────────────────────────────────┐
│         로고                        │
├────────────────────────────────────┤
│                                    │
│    Image Util에 오신 것을          │
│         환영합니다                  │
│                                    │
│  ┌──────────────────────────┐     │
│  │  이메일                   │     │
│  └──────────────────────────┘     │
│  ┌──────────────────────────┐     │
│  │  비밀번호                 │     │
│  └──────────────────────────┘     │
│                                    │
│     [로그인]   [회원가입]           │
│                                    │
│   또는 소셜 로그인 (Phase 2)        │
│     [Google]  [GitHub]             │
│                                    │
└────────────────────────────────────┘
```

#### 홈페이지 (로그인 후)
```
┌────────────────────────────────────┐
│  로고 + 네비게이션  [프로필 ▼]      │
├────────────────────────────────────┤
│                                    │
│    AI 이미지 처리 서비스            │
│    배경 제거 & 업스케일링            │
│                                    │
│  ┌──────────────────────────┐     │
│  │   이미지를 드래그하거나    │     │
│  │   클릭하여 업로드하세요    │     │
│  └──────────────────────────┘     │
│                                    │
│  [배경 제거]  [업스케일링]          │
│                                    │
│  오늘 처리: 2/5회 (무료 플랜)       │
└────────────────────────────────────┘
```

#### 처리 화면
```
┌────────────────────────────────────┐
│  ← 뒤로가기                         │
├─────────────┬──────────────────────┤
│             │                      │
│   원본      │      결과            │
│   이미지    │    (처리중...)       │
│             │                      │
│             │   [━━━━━━━  ] 60%   │
│             │                      │
├─────────────┴──────────────────────┤
│  [다시 업로드]  [다운로드]          │
└────────────────────────────────────┘
```

### 6.3 디자인 스타일
- **컬러 팔레트**: 
  - Primary: Blue (#3B82F6)
  - Secondary: Purple (#8B5CF6)
  - Background: White/Gray
  - Accent: Green (#10B981) for success
- **타이포그래피**: Inter 또는 Pretendard
- **아이콘**: Lucide Icons 또는 Heroicons
- **애니메이션**: Framer Motion (부드러운 전환)

---

## 7. 비기능 요구사항

### 7.1 성능
- **페이지 로드**: 2초 이내 (Lighthouse 90점 이상)
- **API 응답**: 100ms 이내 (이미지 처리 제외)
- **동시 사용자**: 최소 100명 동시 처리
- **업타임**: 99.5% 이상

### 7.2 보안
- **HTTPS**: 모든 통신 암호화 (Netlify, Supabase 자동 적용)
- **인증**: Supabase Auth의 JWT 기반 보안 인증
- **RLS (Row Level Security)**: Supabase DB에서 사용자별 데이터 접근 제어
  - 사용자는 본인의 처리 이력만 조회 가능
  - 파일 스토리지도 사용자별 접근 권한 분리
- **파일 검증**: 악성 파일 업로드 방지
  - 파일 타입 검증 (MIME type)
  - 파일 크기 제한 (10MB)
  - 이미지 헤더 검증
- **Rate Limiting**: 
  - Supabase Auth의 내장 Rate Limiting
  - API 엔드포인트별 요청 제한
- **데이터 보호**: 
  - 처리 후 24시간 내 원본 이미지 자동 삭제
  - 민감 정보 암호화 (비밀번호는 Supabase에서 자동 해싱)

### 7.3 확장성
- **수평 확장**: 로드 밸런서를 통한 서버 추가
- **모델 최적화**: ONNX 또는 TensorRT 변환
- **캐싱**: 동일 이미지 재처리 방지

### 7.4 접근성
- **WCAG 2.1 AA** 준수
- **키보드 네비게이션** 지원
- **스크린 리더** 호환
- **다국어 지원** (한국어, 영어)

---

## 8. 비즈니스 모델

### 8.1 수익화 전략

#### Phase 1: Freemium (MVP)

| 플랜 | 무료 | 프로 |
|------|------|------|
| **가격** | $0/월 | $9.99/월 |
| **배경 제거** | 5개/일 | 무제한 |
| **업스케일링** | 3개/일 | 무제한 |
| **최대 파일 크기** | 5MB | 20MB |
| **일괄 처리** | ✗ | ✓ (10장) |
| **워터마크** | ✓ | ✗ |
| **API 접근** | ✗ | ✗ |

#### Phase 2: API 제공
- **Hobby**: $29/월 (1,000 requests)
- **Business**: $99/월 (10,000 requests)
- **Enterprise**: 맞춤 견적

### 8.2 핵심 지표 (KPI)
- **MAU** (Monthly Active Users): 목표 1,000명 (6개월 내)
- **전환율**: 무료 → 유료 5% 이상
- **이탈률**: 30% 이하
- **NPS** (Net Promoter Score): 50 이상
- **처리 성공률**: 98% 이상

---

## 9. 개발 로드맵

### Phase 1: MVP (8-10주)

#### Week 1-2: 기획 및 설계
- [ ] 기술 스택 최종 확정
- [ ] Supabase 프로젝트 생성 및 설정
- [ ] DB 스키마 설계 (Supabase)
- [ ] UI/UX 디자인 완료 (Figma)
- [ ] API 명세 작성
- [ ] Netlify 계정 설정 및 연동

#### Week 3-4: AI 모델 구축
- [ ] 배경 제거 모델 선정 및 테스트
- [ ] 업스케일링 모델 선정 및 테스트
- [ ] 모델 최적화 (ONNX 변환)
- [ ] 벤치마크 테스트

#### Week 5-6: 백엔드 개발
- [ ] Supabase 인증 설정 (Auth)
  - [ ] 이메일/비밀번호 인증 활성화
  - [ ] 인증 이메일 템플릿 커스터마이징
  - [ ] RLS (Row Level Security) 정책 설정
- [ ] Supabase 데이터베이스 테이블 생성
  - [ ] users 프로필 테이블
  - [ ] processing_history 테이블
  - [ ] usage_stats 테이블
- [ ] Supabase Storage 버킷 생성
  - [ ] 원본 이미지 버킷
  - [ ] 처리된 이미지 버킷
- [ ] AI 처리 서버 (FastAPI) 구축
  - [ ] FastAPI 프로젝트 셋업
  - [ ] 배경 제거 API 엔드포인트
  - [ ] 업스케일링 API 엔드포인트
  - [ ] Railway/Render에 배포

#### Week 7-8: 프론트엔드 개발
- [ ] Next.js 프로젝트 셋업
  - [ ] Supabase 클라이언트 설정
  - [ ] 환경변수 설정 (.env.local)
- [ ] 인증 UI 구현
  - [ ] 회원가입 페이지
  - [ ] 로그인 페이지
  - [ ] 비밀번호 재설정 페이지
  - [ ] 프로필 페이지
- [ ] 메인 기능 UI 구현
  - [ ] 홈페이지 (랜딩)
  - [ ] 파일 업로드 컴포넌트
  - [ ] 처리 화면 (배경 제거/업스케일링)
  - [ ] 결과 프리뷰 및 다운로드
  - [ ] 히스토리 페이지
- [ ] Supabase 연동
  - [ ] 인증 상태 관리
  - [ ] Storage 업로드/다운로드
  - [ ] DB 쿼리 (처리 이력)
- [ ] 반응형 디자인 적용
- [ ] Netlify 배포 설정

#### Week 9-10: 테스트 및 배포
- [ ] 단위 테스트 작성
- [ ] 통합 테스트
  - [ ] Supabase Auth 플로우 테스트
  - [ ] 이미지 업로드/다운로드 테스트
  - [ ] AI 처리 end-to-end 테스트
- [ ] 사용자 테스트 (베타)
- [ ] 성능 최적화
  - [ ] Next.js 이미지 최적화
  - [ ] Lighthouse 점수 개선
- [ ] 프로덕션 배포
  - [ ] Netlify 프로덕션 배포
  - [ ] 커스텀 도메인 연결 (선택적)
  - [ ] AI 서버 프로덕션 배포
- [ ] 모니터링 설정
  - [ ] Sentry 에러 트래킹
  - [ ] Netlify Analytics
  - [ ] Supabase 대시보드 모니터링

### Phase 2: 사용자 피드백 및 개선 (4주)
- [ ] 사용자 피드백 수집
- [ ] 일괄 처리 기능 추가
- [ ] 배경 색상 변경 기능
- [ ] 성능 개선
- [ ] 버그 수정

### Phase 3: 수익화 (4주)
- [ ] 결제 시스템 통합 (Stripe)
  - [ ] Stripe Checkout 연동
  - [ ] 구독 플랜 생성
  - [ ] Webhook 처리 (결제 완료)
- [ ] 구독 관리 시스템
  - [ ] Supabase DB에 구독 정보 저장
  - [ ] 플랜별 사용량 제한 로직
  - [ ] 구독 취소/변경 처리
- [ ] 사용량 추적 시스템
  - [ ] 일일 처리 횟수 추적
  - [ ] 사용 통계 대시보드
- [ ] 사용자 대시보드 구현
  - [ ] 구독 현황
  - [ ] 사용 이력
  - [ ] 청구 내역

### Phase 4: 확장 (8주)
- [ ] API 개발 및 문서화
- [ ] 일괄 처리 고도화
- [ ] 추가 AI 기능 (배경 생성 등)
- [ ] 모바일 앱 검토

---

## 10. 위험 요소 및 대응 방안

### 10.1 기술적 위험

| 위험 요소 | 영향 | 확률 | 대응 방안 |
|-----------|------|------|-----------|
| AI 모델 성능 부족 | 높음 | 중간 | 여러 모델 사전 테스트, 앙상블 적용 |
| 처리 시간 과다 | 높음 | 중간 | GPU 인스턴스 사용, 모델 경량화 |
| 서버 비용 초과 | 중간 | 높음 | 오토스케일링, 서버리스 검토 |
| 동시 접속 처리 | 중간 | 중간 | 큐 시스템, 로드 밸런싱 |

### 10.2 비즈니스 위험

| 위험 요소 | 영향 | 확률 | 대응 방안 |
|-----------|------|------|-----------|
| 시장 경쟁 심화 | 높음 | 높음 | 차별화된 UX, 한국 시장 특화 |
| 사용자 확보 실패 | 높음 | 중간 | 마케팅 예산 확보, 바이럴 전략 |
| 저작권 문제 | 중간 | 낮음 | 이용약관 명확화, 책임 제한 |
| 수익화 실패 | 높음 | 중간 | 다양한 수익 모델 테스트 |

---

## 11. 성공 기준

### 11.1 출시 기준 (Launch Criteria)
- [ ] 배경 제거 95% 정확도 달성
- [ ] 평균 처리 시간 5초 이내
- [ ] 모바일/데스크톱 반응형 완성
- [ ] 보안 취약점 0건
- [ ] 페이지 로드 2초 이내
- [ ] 베타 테스터 만족도 4.0/5.0 이상

### 11.2 6개월 목표
- MAU 1,000명 달성
- 무료 회원 중 5% 유료 전환
- 일일 처리 이미지 500장 이상
- 평균 세션 시간 5분 이상
- 재방문율 40% 이상

---

## 12. 제약사항 및 가정

### 12.1 제약사항
- **예산**: 
  - 초기 단계: 무료 티어 활용으로 $0-50/월 예상
  - Netlify: 무료 (월 100GB 대역폭)
  - Supabase: 무료 (500MB DB, 1GB Storage)
  - AI 서버: Railway/Render $5-20/월
  - 성장 단계: 유료 플랜 전환 시 $100-300/월 예상
- **인력**: 개발자 1-2명으로 시작
- **시간**: MVP 출시까지 8-10주 목표
- **인프라**: 
  - Supabase 무료 티어 제한 (500MB DB, 1GB Storage)
  - Netlify 무료 티어 제한 (월 100GB 대역폭)
  - AI 서버 GPU 사용 시 추가 비용 발생

### 12.2 가정
- 사용자는 기본적인 이미지 편집 지식이 있음
- 대부분의 사용자는 모바일 또는 데스크톱 브라우저 사용
- 업로드되는 이미지는 대부분 일반적인 사진 (풍경, 인물, 제품)
- 사용자는 빠른 처리 시간을 품질보다 중요하게 생각함

---

## 13. 부록

### 13.1 용어 정의

**이미지 처리**
- **배경 제거**: 이미지에서 주요 피사체를 제외한 배경 영역을 제거하는 작업
- **업스케일링**: 저해상도 이미지를 고해상도로 확대하는 기술
- **투명 배경**: 알파 채널을 가진 PNG 형식으로 배경이 없는 상태
- **PSNR**: Peak Signal-to-Noise Ratio, 이미지 품질 측정 지표
- **SSIM**: Structural Similarity Index, 이미지 유사도 측정 지표

**기술 용어**
- **Supabase**: PostgreSQL 기반의 오픈소스 BaaS(Backend as a Service) 플랫폼
- **BaaS**: Backend as a Service, 서버 인프라를 관리할 필요 없이 백엔드 기능을 제공하는 서비스
- **RLS**: Row Level Security, 데이터베이스 행 단위 보안 정책
- **JWT**: JSON Web Token, 사용자 인증에 사용되는 토큰 표준
- **Netlify**: JAMstack 웹사이트를 위한 호스팅 및 배포 플랫폼
- **Edge Functions**: 사용자와 가까운 위치에서 실행되는 서버리스 함수

### 13.2 참고 자료

**AI 모델**
- [U²-Net Paper](https://arxiv.org/abs/2005.09007)
- [Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN)
- [Remove.bg](https://www.remove.bg/)

**프레임워크 & 라이브러리**
- [Next.js Documentation](https://nextjs.org/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Tailwind CSS](https://tailwindcss.com/)
- [shadcn/ui](https://ui.shadcn.com/)

**백엔드 & 인프라**
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)
- [Supabase Storage Guide](https://supabase.com/docs/guides/storage)
- [Netlify Documentation](https://docs.netlify.com/)
- [Netlify Deployment](https://docs.netlify.com/site-deploys/overview/)
- [Railway Documentation](https://docs.railway.app/)
- [Render Documentation](https://render.com/docs)

### 13.3 데이터베이스 스키마 (Supabase)

#### users_profile 테이블
```sql
create table users_profile (
  id uuid references auth.users primary key,
  email text,
  full_name text,
  avatar_url text,
  subscription_tier text default 'free',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- RLS 정책
alter table users_profile enable row level security;

create policy "Users can view own profile"
  on users_profile for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on users_profile for update
  using (auth.uid() = id);
```

#### processing_history 테이블
```sql
create table processing_history (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  processing_type text not null, -- 'background_removal' or 'upscaling'
  original_image_url text not null,
  processed_image_url text,
  status text default 'processing', -- 'processing', 'completed', 'failed'
  file_size_bytes bigint,
  processing_time_ms integer,
  created_at timestamp with time zone default now()
);

-- RLS 정책
alter table processing_history enable row level security;

create policy "Users can view own history"
  on processing_history for select
  using (auth.uid() = user_id);

create policy "Users can insert own history"
  on processing_history for insert
  with check (auth.uid() = user_id);
```

#### usage_stats 테이블
```sql
create table usage_stats (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  date date not null,
  background_removal_count integer default 0,
  upscaling_count integer default 0,
  created_at timestamp with time zone default now(),
  unique(user_id, date)
);

-- RLS 정책
alter table usage_stats enable row level security;

create policy "Users can view own stats"
  on usage_stats for select
  using (auth.uid() = user_id);
```

### 13.4 연락처
- **프로덕트 오너**: TBD
- **기술 리드**: TBD
- **디자인 리드**: TBD

---

## 문서 변경 이력

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 1.0 | 2025-10-18 | AI Assistant | 초안 작성 |
| 1.1 | 2025-10-18 | AI Assistant | Supabase & Netlify 기반으로 기술 스택 변경 |

---

## 문서 승인

이 PRD 문서를 검토하고 다음 단계로 진행하기 전에 주요 이해관계자의 승인이 필요합니다.

- [ ] 프로덕트 오너
- [ ] 기술 리드
- [ ] 디자인 리드
- [ ] 비즈니스 리드

---

**📝 Note**: 이 문서는 프로젝트 진행 상황에 따라 지속적으로 업데이트됩니다.

