# 월간 자동결제 스케줄러 설정 가이드

이 문서는 월 구독제 자동결제를 처리하기 위한 스케줄러 설정 방법을 설명합니다.

## 개요

토스페이먼츠 자동결제(빌링) 시스템은 자체적으로 스케줄링 기능을 제공하지 않습니다. 따라서 매월 정해진 시간에 자동으로 결제를 처리하려면 외부 스케줄러를 설정해야 합니다.

## 옵션 1: GitHub Actions (무료, 간단)

GitHub Actions를 사용하면 무료로 cron job을 설정할 수 있습니다.

### 설정 방법

1. `.github/workflows/monthly-billing.yml` 파일 생성:

```yaml
name: Monthly Billing Processor

on:
  schedule:
    # 매일 오전 9시 (KST 기준 오후 6시)에 실행
    - cron: '0 0 * * *'
  workflow_dispatch: # 수동 실행 가능

jobs:
  process-recurring-payments:
    runs-on: ubuntu-latest
    
    steps:
      - name: Call recurring payment API
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.CRON_SECRET }}" \
            -H "Content-Type: application/json" \
            https://your-domain.com/api/payment/process-recurring

      - name: Check response
        run: echo "Billing processed successfully"
```

2. GitHub Repository Settings > Secrets에 `CRON_SECRET` 추가

3. 완료! 매일 자동으로 실행되며, 결제 날짜가 된 구독만 처리됩니다.

**장점:**
- 무료
- 설정 간단
- GitHub에서 실행 로그 확인 가능

**단점:**
- 최소 실행 주기가 5분 (실시간 처리 불가)
- GitHub 서비스에 의존

---

## 옵션 2: Vercel Cron Jobs (Vercel 배포 시)

Vercel에 배포한 경우 Vercel Cron을 사용할 수 있습니다.

### 설정 방법

1. `vercel.json` 파일에 cron 설정 추가:

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

2. Vercel 환경 변수에 `CRON_SECRET` 추가

3. Vercel에 재배포

**장점:**
- Vercel과 통합
- 안정적
- 무료 티어에서도 사용 가능

**단점:**
- Vercel에 종속

---

## 옵션 3: AWS EventBridge (프로덕션 권장)

대규모 프로덕션 환경에서는 AWS EventBridge를 사용하는 것이 좋습니다.

### 설정 방법

1. AWS Lambda 함수 생성:

```javascript
// lambda/monthly-billing.js
const https = require('https');

exports.handler = async (event) => {
  const options = {
    hostname: 'your-domain.com',
    path: '/api/payment/process-recurring',
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.CRON_SECRET}`,
      'Content-Type': 'application/json'
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => resolve({ statusCode: 200, body: data }));
    });

    req.on('error', reject);
    req.end();
  });
};
```

2. EventBridge 규칙 생성:
   - Schedule expression: `cron(0 0 * * ? *)`
   - Target: Lambda 함수

**장점:**
- 안정성 높음
- 확장성 뛰어남
- AWS 생태계와 통합

**단점:**
- 설정 복잡
- 비용 발생 (소량은 무료)

---

## 옵션 4: Node-Cron (자체 서버)

자체 Node.js 서버가 있다면 node-cron을 사용할 수 있습니다.

### 설정 방법

1. 패키지 설치:

```bash
npm install node-cron
```

2. 스케줄러 코드 작성:

```javascript
// backend/scheduler.js
const cron = require('node-cron');
const axios = require('axios');

// 매일 오전 9시에 실행
cron.schedule('0 9 * * *', async () => {
  console.log('Running monthly billing processor...');
  
  try {
    const response = await axios.post(
      'http://localhost:3000/api/payment/process-recurring',
      {},
      {
        headers: {
          'Authorization': `Bearer ${process.env.CRON_SECRET}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    console.log('Billing processed:', response.data);
  } catch (error) {
    console.error('Billing error:', error.message);
  }
});

console.log('Scheduler started!');
```

3. 서버 시작 시 스케줄러 실행:

```javascript
// backend/server.js
require('./scheduler');
// ... 나머지 서버 코드
```

**장점:**
- 완전한 제어 가능
- 커스터마이징 용이

**단점:**
- 서버가 항상 실행 중이어야 함
- 서버 장애 시 스케줄러도 중단

---

## 옵션 5: Supabase Edge Functions + pg_cron

Supabase를 사용하는 경우 pg_cron을 활용할 수 있습니다.

### 설정 방법

1. Supabase SQL Editor에서 pg_cron 활성화:

```sql
-- pg_cron 확장 활성화
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 매일 오전 9시에 HTTP 요청 실행
SELECT cron.schedule(
  'monthly-billing',
  '0 9 * * *',
  $$
  SELECT
    net.http_post(
      url:='https://your-domain.com/api/payment/process-recurring',
      headers:=jsonb_build_object(
        'Authorization', 'Bearer YOUR_CRON_SECRET',
        'Content-Type', 'application/json'
      ),
      body:='{}'::jsonb
    ) AS request_id;
  $$
);
```

2. Supabase 환경 변수에 CRON_SECRET 추가

**장점:**
- Supabase와 완벽 통합
- 별도 서버 불필요

**단점:**
- Supabase Pro 플랜 필요 (pg_cron)

---

## 환경 변수 설정

모든 옵션에서 다음 환경 변수가 필요합니다:

```bash
# .env.local 또는 환경 변수
CRON_SECRET=your-random-secret-key-here
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key
```

**CRON_SECRET 생성:**

```bash
# 랜덤 시크릿 생성
openssl rand -base64 32
```

---

## 테스트 방법

### 수동으로 API 호출하여 테스트:

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_CRON_SECRET" \
  -H "Content-Type: application/json" \
  http://localhost:3000/api/payment/process-recurring
```

### 응답 예시:

```json
{
  "success": true,
  "processed": 5,
  "succeeded": 4,
  "failed": 1,
  "details": {
    "success": ["user-id-1", "user-id-2", "user-id-3", "user-id-4"],
    "failed": [
      {
        "userId": "user-id-5",
        "error": "카드 잔액 부족"
      }
    ]
  }
}
```

---

## 권장 사항

**개발/테스트 환경:**
- GitHub Actions 또는 수동 호출

**프로덕션 환경:**
- Vercel Cron (Vercel 사용 시)
- AWS EventBridge (대규모)
- Supabase pg_cron (Supabase Pro 사용 시)

---

## 모니터링

스케줄러가 정상 작동하는지 확인하려면:

1. **로그 확인:**
   - GitHub Actions: Actions 탭에서 확인
   - Vercel: Vercel Dashboard > Logs
   - AWS: CloudWatch Logs

2. **Supabase에서 결제 내역 확인:**
   ```sql
   SELECT * FROM payment_history
   WHERE created_at >= NOW() - INTERVAL '1 day'
   ORDER BY created_at DESC;
   ```

3. **알림 설정:**
   - 실패한 결제에 대해 이메일/Slack 알림 설정
   - Sentry 등 에러 트래킹 도구 연동

---

## 문제 해결

### Q: 스케줄러가 실행되지 않아요
- CRON_SECRET이 올바르게 설정되었는지 확인
- 스케줄 표현식이 올바른지 확인 (cron 문법)
- 타임존 확인 (UTC vs KST)

### Q: 결제가 중복으로 처리돼요
- `next_payment_at` 필드가 제대로 업데이트되는지 확인
- 트랜잭션 처리 추가 고려

### Q: 실패한 결제는 어떻게 재시도하나요?
- `status='failed'` 구독을 별도로 조회하여 재시도 로직 추가
- 최대 재시도 횟수 설정 (예: 3회)

---

## 다음 단계

1. 원하는 스케줄러 옵션 선택
2. 환경 변수 설정
3. 테스트 실행
4. 프로덕션 배포
5. 모니터링 설정

문의사항이 있으시면 토스페이먼츠 고객센터(1544-7772)로 연락하세요.

