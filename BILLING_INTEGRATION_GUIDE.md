# 토스페이먼츠 월 구독제 결제 통합 가이드

## 📚 목차

1. [개요](#개요)
2. [사전 준비](#사전-준비)
3. [구현 완료 목록](#구현-완료-목록)
4. [설정 방법](#설정-방법)
5. [테스트 방법](#테스트-방법)
6. [프로덕션 배포](#프로덕션-배포)
7. [FAQ](#faq)

---

## 개요

이 프로젝트는 **토스페이먼츠 자동결제(빌링) API**를 사용하여 월 구독제 결제를 구현했습니다.

### 주요 기능

✅ 무료 플랜 / 프로 플랜 ($9.99/월)  
✅ 자동 월간 결제 (빌링키 기반)  
✅ 일일 사용량 제한 관리  
✅ 구독 취소 기능  
✅ 결제 내역 조회  

### 기술 스택

- **Frontend:** Next.js 15, React 19, TypeScript
- **Backend:** Next.js API Routes
- **Database:** Supabase (PostgreSQL)
- **Payment:** 토스페이먼츠 Billing API v1
- **Auth:** Supabase Auth

---

## 사전 준비

### 1. 토스페이먼츠 API 키 (✅ 완료)

- **클라이언트 키:** `test_ck_ALnQvDd2VJldYnln4Q1Y8Mj7X41m`
- **시크릿 키:** `test_sk_BX7zk2yd8ynJ7j6o164Y3x9POLqK`

> ⚠️ 현재는 테스트 키이므로 실제 결제가 발생하지 않습니다.

### 2. Supabase 프로젝트

Supabase 대시보드에서:
1. 새 프로젝트 생성
2. SQL Editor에서 `SUPABASE_SCHEMA.sql` 실행
3. API 키 확인 (Settings > API)

### 3. 환경 변수 설정

`frontend/.env.local` 파일 생성:

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url_here
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# 토스페이먼츠
NEXT_PUBLIC_TOSS_CLIENT_KEY=test_ck_ALnQvDd2VJldYnln4Q1Y8Mj7X41m
TOSS_SECRET_KEY=test_sk_BX7zk2yd8ynJ7j6o164Y3x9POLqK

# Site URL (프로덕션에서는 실제 도메인)
NEXT_PUBLIC_SITE_URL=http://localhost:3000

# Cron Secret (스케줄러 인증용)
CRON_SECRET=your-random-secret-here

# Backend
NEXT_PUBLIC_BACKEND_URL=http://localhost:8000
```

**CRON_SECRET 생성:**
```bash
openssl rand -base64 32
```

---

## 구현 완료 목록

### ✅ 데이터베이스 스키마

- [x] `subscription_plans` - 구독 플랜 정보
- [x] `user_subscriptions` - 사용자 구독 정보
- [x] `payment_history` - 결제 내역
- [x] `daily_usage` - 일일 사용량 추적
- [x] RLS (Row Level Security) 정책
- [x] 헬퍼 함수 (사용량 체크, 증가)

### ✅ 프론트엔드

- [x] `/pricing` - 구독 플랜 선택 페이지
- [x] `PricingClient` - 구독 UI 컴포넌트
- [x] 토스페이먼츠 SDK 연동
- [x] 구독 취소 기능

### ✅ 백엔드 API

- [x] `POST /api/payment/subscribe` - 구독 시작
- [x] `GET /api/payment/success` - 결제 성공 처리
- [x] `POST /api/payment/cancel-subscription` - 구독 취소
- [x] `POST /api/payment/process-recurring` - 월간 자동결제
- [x] `POST /api/usage/check` - 사용량 확인
- [x] `POST /api/usage/increment` - 사용량 증가

### ✅ 헬퍼 라이브러리

- [x] `lib/tosspayments.ts` - 토스페이먼츠 API 래퍼

### ✅ 문서

- [x] `SUPABASE_SCHEMA.sql` - DB 스키마
- [x] `SCHEDULER_SETUP.md` - 스케줄러 설정 가이드
- [x] `ENV_VARS.md` - 환경 변수 가이드
- [x] `BILLING_INTEGRATION_GUIDE.md` - 통합 가이드 (현재 문서)

---

## 설정 방법

### Step 1: 데이터베이스 설정

1. Supabase 대시보드 > SQL Editor 접속
2. `SUPABASE_SCHEMA.sql` 파일 내용 복사
3. SQL Editor에 붙여넣기
4. "Run" 버튼 클릭

**확인:**
```sql
SELECT * FROM subscription_plans;
-- 2개의 플랜(free, pro)이 보여야 합니다.
```

### Step 2: 환경 변수 설정

1. `frontend/.env.local` 파일 생성
2. 위의 "환경 변수 설정" 섹션 참고하여 값 입력
3. Supabase URL, Key는 Supabase 대시보드에서 복사

### Step 3: 프론트엔드 실행

```bash
cd frontend
npm install
npm run dev
```

브라우저에서 `http://localhost:3000` 접속

### Step 4: 스케줄러 설정 (선택사항)

월간 자동결제를 위해 스케줄러를 설정하세요.  
자세한 내용은 `SCHEDULER_SETUP.md` 참고

**간단한 테스트용 (GitHub Actions):**

`.github/workflows/monthly-billing.yml` 생성:

```yaml
name: Monthly Billing

on:
  schedule:
    - cron: '0 0 * * *'  # 매일 자정
  workflow_dispatch:

jobs:
  billing:
    runs-on: ubuntu-latest
    steps:
      - name: Process recurring payments
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.CRON_SECRET }}" \
            https://your-domain.com/api/payment/process-recurring
```

---

## 테스트 방법

### 1. 회원가입/로그인 테스트

1. `/signup` 접속
2. 이메일/비밀번호로 회원가입
3. 이메일 인증 (Supabase에서 자동 발송)
4. 로그인

### 2. 구독 플랜 선택 테스트

1. 로그인 후 `/pricing` 접속
2. "프로 플랜" 선택
3. "구독하기" 버튼 클릭

### 3. 결제 테스트 (토스페이먼츠 샌드박스)

토스페이먼츠 결제창이 열리면:

**테스트 카드 정보:**
- 카드번호: `5570002345678900` (마스터카드)
- 유효기간: `12/28`
- CVC: `123`
- 비밀번호 앞 2자리: `12`
- 생년월일: `800101`

결제 완료 후 `/dashboard?subscribed=success`로 리다이렉트됩니다.

### 4. 사용량 제한 테스트

**API 직접 호출:**

```bash
# 사용량 확인
curl -X POST http://localhost:3000/api/usage/check \
  -H "Content-Type: application/json" \
  -H "Cookie: sb-access-token=YOUR_TOKEN" \
  -d '{"type": "background_removal"}'

# 사용량 증가
curl -X POST http://localhost:3000/api/usage/increment \
  -H "Content-Type: application/json" \
  -H "Cookie: sb-access-token=YOUR_TOKEN" \
  -d '{"type": "background_removal"}'
```

### 5. 월간 자동결제 테스트

```bash
curl -X POST http://localhost:3000/api/payment/process-recurring \
  -H "Authorization: Bearer YOUR_CRON_SECRET" \
  -H "Content-Type: application/json"
```

**응답 예시:**
```json
{
  "success": true,
  "processed": 3,
  "succeeded": 3,
  "failed": 0
}
```

### 6. 구독 취소 테스트

1. `/pricing` 접속
2. "구독 취소" 버튼 클릭
3. 확인 대화상자에서 "예" 클릭
4. 구독이 취소되었지만 현재 기간 종료까지 사용 가능

---

## 프로덕션 배포

### 1. 환경 변수 업데이트

프로덕션 환경에서는:

```bash
# 실제 토스페이먼츠 라이브 키로 변경
NEXT_PUBLIC_TOSS_CLIENT_KEY=live_ck_...
TOSS_SECRET_KEY=live_sk_...

# 실제 도메인
NEXT_PUBLIC_SITE_URL=https://yourdomain.com
```

### 2. Vercel 배포

```bash
# Vercel CLI 설치
npm install -g vercel

# 배포
cd frontend
vercel --prod
```

### 3. 환경 변수 설정 (Vercel)

Vercel Dashboard > Settings > Environment Variables에서:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `NEXT_PUBLIC_TOSS_CLIENT_KEY`
- `TOSS_SECRET_KEY`
- `NEXT_PUBLIC_SITE_URL`
- `CRON_SECRET`

### 4. 스케줄러 배포

**Vercel Cron 사용:**

`vercel.json` 파일 생성:

```json
{
  "crons": [
    {
      "path": "/api/payment/process-recurring",
      "schedule": "0 0 * * *"
    }
  ]
}
```

재배포: `vercel --prod`

---

## FAQ

### Q1: 실제 결제가 되나요?

아니요, 현재는 **테스트 키**를 사용하므로 실제 결제가 발생하지 않습니다.  
프로덕션에서는 토스페이먼츠와 계약 후 **라이브 키**로 변경해야 합니다.

### Q2: 토스페이먼츠 계약은 어떻게 하나요?

1. 토스페이먼츠 고객센터 연락: 1544-7772
2. 이메일: support@tosspayments.com
3. 사업자등록증, 통장사본 등 서류 제출
4. 심사 완료 후 라이브 키 발급

### Q3: 구독을 즉시 취소하고 환불하려면?

현재 구현은 "기간 종료 시 취소"입니다.  
즉시 취소 및 환불을 원한다면:

```typescript
// cancel-subscription/route.ts 수정
import { cancelPayment } from '@/lib/tosspayments'

// 마지막 결제 취소
await cancelPayment({
  paymentKey: subscription.last_payment_key,
  cancelReason: '구매자 요청',
})

// 구독 상태 즉시 변경
await supabase
  .from('user_subscriptions')
  .update({ status: 'canceled' })
  .eq('id', subscription.id)
```

### Q4: 월 구독이 아닌 연 구독도 가능한가요?

네, 가능합니다.

1. `subscription_plans` 테이블에 `yearly` 플랜 추가
2. `current_period_end` 계산 시 12개월 추가
3. 스케줄러는 동일하게 사용 (결제 날짜만 체크)

### Q5: 결제 실패 시 어떻게 되나요?

자동결제 실패 시:
1. 구독 상태가 `failed`로 변경
2. `payment_history`에 실패 기록
3. 사용자에게 알림 발송 (구현 필요)
4. 재시도 로직 추가 가능

### Q6: 사용량 제한은 어떻게 적용하나요?

이미지 처리 API에서 사용량 체크:

```typescript
// app/api/remove-background/route.ts
import { createClient } from '@/lib/supabase/server'

export async function POST(request: NextRequest) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  
  // 1. 사용량 체크
  const checkResponse = await fetch(`${process.env.NEXT_PUBLIC_SITE_URL}/api/usage/check`, {
    method: 'POST',
    body: JSON.stringify({ type: 'background_removal' }),
  })
  const usageData = await checkResponse.json()
  
  if (!usageData.canUse) {
    return NextResponse.json(
      { error: '일일 사용량을 초과했습니다. 프로 플랜으로 업그레이드하세요.' },
      { status: 403 }
    )
  }
  
  // 2. 이미지 처리
  // ...
  
  // 3. 사용량 증가
  await fetch(`${process.env.NEXT_PUBLIC_SITE_URL}/api/usage/increment`, {
    method: 'POST',
    body: JSON.stringify({ type: 'background_removal' }),
  })
  
  return NextResponse.json({ success: true })
}
```

### Q7: 웹훅은 어떻게 설정하나요?

토스페이먼츠 웹훅 설정:

1. 개발자센터 > 웹훅 설정
2. 엔드포인트 추가: `https://yourdomain.com/api/webhook/tosspayments`
3. 웹훅 API 구현:

```typescript
// app/api/webhook/tosspayments/route.ts
export async function POST(request: NextRequest) {
  const body = await request.json()
  
  if (body.eventType === 'PAYMENT_STATUS_CHANGED') {
    // 결제 상태 변경 처리
  }
  
  if (body.eventType === 'BILLING_DELETED') {
    // 빌링키 삭제 처리
  }
  
  return NextResponse.json({ received: true })
}
```

---

## 다음 단계

1. ✅ 테스트 환경에서 결제 플로우 검증
2. ✅ 사용량 제한 로직을 이미지 처리 API에 통합
3. ⬜ 이메일 알림 추가 (결제 성공/실패, 구독 만료 등)
4. ⬜ 관리자 대시보드 구현
5. ⬜ 토스페이먼츠와 정식 계약
6. ⬜ 프로덕션 배포

---

## 지원

문제가 발생하면:

1. **토스페이먼츠:** 1544-7772, support@tosspayments.com
2. **Supabase:** https://supabase.com/docs
3. **프로젝트 이슈:** GitHub Issues

---

**축하합니다! 🎉**  
토스페이먼츠 월 구독제 결제 시스템이 준비되었습니다.

