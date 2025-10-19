#!/bin/bash

# 토스페이먼츠 구독 결제 API 테스트 스크립트

echo "======================================"
echo "토스페이먼츠 구독 결제 테스트"
echo "======================================"
echo ""

# 1. 사용량 체크 테스트
echo "1️⃣ 사용량 체크 테스트"
echo "curl -X POST http://localhost:3000/api/usage/check"
echo ""

# 참고: 실제로는 로그인 쿠키가 필요합니다
# 브라우저에서 로그인 후 개발자 도구에서 쿠키 확인

# 2. 월간 자동결제 테스트 (CRON_SECRET 필요)
echo "2️⃣ 월간 자동결제 테스트"
echo "curl -X POST http://localhost:3000/api/payment/process-recurring \\"
echo "  -H 'Authorization: Bearer YOUR_CRON_SECRET'"
echo ""

# 3. Supabase 데이터 확인
echo "3️⃣ Supabase에서 확인할 쿼리:"
echo ""
echo "-- 구독 플랜 조회"
echo "SELECT * FROM subscription_plans;"
echo ""
echo "-- 사용자 구독 조회"
echo "SELECT * FROM user_subscriptions;"
echo ""
echo "-- 결제 내역 조회"
echo "SELECT * FROM payment_history ORDER BY created_at DESC;"
echo ""
echo "-- 일일 사용량 조회"
echo "SELECT * FROM daily_usage WHERE date = CURRENT_DATE;"
echo ""

echo "======================================"
echo "테스트 URL"
echo "======================================"
echo "홈페이지: http://localhost:3000"
echo "회원가입: http://localhost:3000/signup"
echo "로그인: http://localhost:3000/login"
echo "Pricing: http://localhost:3000/pricing"
echo "Dashboard: http://localhost:3000/dashboard"
echo ""

echo "======================================"
echo "토스페이먼츠 테스트 카드 정보"
echo "======================================"
echo "카드번호: 5570002345678900"
echo "유효기간: 12/28"
echo "CVC: 123"
echo "비밀번호 앞 2자리: 12"
echo "생년월일: 800101"
echo ""

