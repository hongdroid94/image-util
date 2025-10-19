# 빠른 시작 가이드 (Quick Start)

## ⚡ 5분 안에 시작하기

### 1단계: 환경변수 설정 (필수)

#### Supabase API Keys 찾기

1. [Supabase Dashboard](https://supabase.com/dashboard) 접속
2. `vibecoder-community` 프로젝트 선택
3. 왼쪽 메뉴: Settings → API
4. **anon public** 키 복사

#### 환경변수 파일 생성

```bash
# frontend/.env.local 파일 생성
cd frontend
cat > .env.local << 'EOF'
NEXT_PUBLIC_SUPABASE_URL=https://qxxfxwspeaqyreoybbhu.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=여기에_복사한_키_붙여넣기
NEXT_PUBLIC_AI_SERVER_URL=http://localhost:8000
EOF
```

**⚠️ 중요**: `NEXT_PUBLIC_SUPABASE_ANON_KEY` 값을 실제 키로 변경하세요!

---

### 2단계: 백엔드 서버 실행 ✅

**이미 실행 중입니다!** 🎉

- URL: http://localhost:8000
- API 문서: http://localhost:8000/docs
- 상태: 백그라운드 실행 중

서버를 다시 시작하려면:
```bash
cd backend
source venv/bin/activate
python main.py
```

---

### 3단계: 프론트엔드 서버 실행

**새 터미널을 열고** 다음 명령어를 실행하세요:

```bash
cd frontend
npm run dev
```

그러면 브라우저에서 자동으로 열립니다:
- URL: http://localhost:3000

---

## 🧪 테스트하기

### 1. 회원가입
1. http://localhost:3000 접속
2. "회원가입" 클릭
3. 이메일과 비밀번호 입력
4. 이메일 인증 (또는 Supabase에서 비활성화)

### 2. 로그인
1. 이메일과 비밀번호로 로그인
2. 대시보드로 이동

### 3. 이미지 배경 제거
1. 이미지 드래그 앤 드롭
2. AI 처리 대기 (5-10초)
3. Before/After 비교
4. 다운로드

---

## 📊 통계 확인

대시보드에서 확인 가능:
- ✅ 오늘 배경 제거: 0 / 5회 (무료 플랜)
- ✅ 총 처리 이미지: 0개
- ✅ 구독 플랜: 무료

---

## 🔧 문제 해결

### "Invalid API key" 오류
```bash
# .env.local 파일 확인
cat frontend/.env.local

# Supabase Dashboard에서 키 재확인
# 개발 서버 재시작
cd frontend
npm run dev
```

### 백엔드 서버 오류
```bash
# 서버 로그 확인
cd backend
source venv/bin/activate
python main.py

# 포트 충돌 시
lsof -ti:8000 | xargs kill -9
```

### 프론트엔드 빌드 오류
```bash
# node_modules 재설치
cd frontend
rm -rf node_modules package-lock.json
npm install
```

---

## 📝 다음 단계

1. **Storage 버킷 생성** (필수)
   - Supabase Dashboard → Storage → New bucket
   - Name: `images`, Public: ✅

2. **이메일 인증 설정**
   - Supabase Dashboard → Authentication → Providers
   - Email 설정 확인

3. **테스트 이미지 업로드**
   - 다양한 배경의 이미지 테스트
   - 사용량 제한 테스트 (5회)

4. **배포 준비**
   - [SETUP.md](./SETUP.md)의 "배포" 섹션 참고
   - Netlify + Railway/Render

---

## 🎯 빠른 명령어 모음

```bash
# 백엔드 실행
cd backend && source venv/bin/activate && python main.py

# 프론트엔드 실행
cd frontend && npm run dev

# 전체 재시작
# 터미널 1
cd backend && source venv/bin/activate && python main.py

# 터미널 2 (새 터미널)
cd frontend && npm run dev
```

---

## 📚 추가 문서

- [PRD.md](./PRD.md) - 제품 요구사항 문서
- [SETUP.md](./SETUP.md) - 상세 설정 가이드
- [ENV_SETUP.md](./ENV_SETUP.md) - 환경변수 상세 가이드

---

**질문이 있으시면 [ENV_SETUP.md](./ENV_SETUP.md)를 먼저 확인해보세요!** 📖

