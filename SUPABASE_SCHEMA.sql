-- =============================================
-- 토스페이먼츠 월 구독제 결제 스키마
-- =============================================

-- 1. 구독 플랜 테이블
CREATE TABLE IF NOT EXISTS subscription_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL, -- 'free', 'pro'
  display_name TEXT NOT NULL, -- '무료 플랜', '프로 플랜'
  price DECIMAL(10, 2) NOT NULL, -- 0, 9.99
  currency TEXT DEFAULT 'KRW',
  
  -- 플랜별 제한
  daily_background_removal_limit INTEGER NOT NULL, -- 5 (free), 999999 (pro, unlimited)
  daily_upscaling_limit INTEGER NOT NULL, -- 3 (free), 999999 (pro, unlimited)
  max_file_size_mb INTEGER NOT NULL, -- 5 (free), 20 (pro)
  batch_processing_enabled BOOLEAN DEFAULT false, -- false (free), true (pro)
  watermark_enabled BOOLEAN DEFAULT true, -- true (free), false (pro)
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 사용자 구독 정보 테이블
CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  plan_id UUID REFERENCES subscription_plans NOT NULL,
  
  -- 토스페이먼츠 빌링 정보
  billing_key TEXT, -- 빌링키 (자동결제용)
  customer_key TEXT NOT NULL, -- 토스페이먼츠 고객 식별키
  
  -- 구독 상태
  status TEXT NOT NULL DEFAULT 'active', -- 'active', 'canceled', 'expired', 'failed'
  
  -- 구독 기간
  current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
  current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
  cancel_at_period_end BOOLEAN DEFAULT false, -- 기간 종료 시 취소 여부
  
  -- 결제 정보
  last_payment_at TIMESTAMP WITH TIME ZONE,
  next_payment_at TIMESTAMP WITH TIME ZONE,
  last_payment_key TEXT, -- 마지막 결제의 paymentKey
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id)
);

-- 3. 결제 내역 테이블
CREATE TABLE IF NOT EXISTS payment_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  subscription_id UUID REFERENCES user_subscriptions,
  
  -- 토스페이먼츠 결제 정보
  payment_key TEXT NOT NULL UNIQUE, -- 토스페이먼츠 결제 고유 키
  order_id TEXT NOT NULL UNIQUE, -- 주문 ID
  order_name TEXT NOT NULL, -- 주문명
  
  -- 금액 정보
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'KRW',
  
  -- 결제 상태
  status TEXT NOT NULL, -- 'DONE', 'CANCELED', 'FAILED'
  payment_method TEXT, -- '카드', '계좌이체' 등
  
  -- 결제 시간
  requested_at TIMESTAMP WITH TIME ZONE,
  approved_at TIMESTAMP WITH TIME ZONE,
  
  -- 취소 정보
  canceled_at TIMESTAMP WITH TIME ZONE,
  cancel_reason TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. 일일 사용량 추적 테이블 (기존 usage_stats와 유사)
CREATE TABLE IF NOT EXISTS daily_usage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  date DATE NOT NULL,
  
  background_removal_count INTEGER DEFAULT 0,
  upscaling_count INTEGER DEFAULT 0,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id, date)
);

-- =============================================
-- RLS (Row Level Security) 정책
-- =============================================

-- subscription_plans: 모든 사용자가 읽기 가능
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view subscription plans"
  ON subscription_plans FOR SELECT
  USING (true);

-- user_subscriptions: 본인 구독 정보만 조회/수정 가능
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription"
  ON user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscription"
  ON user_subscriptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subscription"
  ON user_subscriptions FOR UPDATE
  USING (auth.uid() = user_id);

-- payment_history: 본인 결제 내역만 조회 가능
ALTER TABLE payment_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own payment history"
  ON payment_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own payment history"
  ON payment_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- daily_usage: 본인 사용량만 조회/수정 가능
ALTER TABLE daily_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own usage"
  ON daily_usage FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own usage"
  ON daily_usage FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own usage"
  ON daily_usage FOR UPDATE
  USING (auth.uid() = user_id);

-- =============================================
-- 기본 플랜 데이터 삽입
-- =============================================

INSERT INTO subscription_plans (name, display_name, price, currency, 
  daily_background_removal_limit, daily_upscaling_limit, 
  max_file_size_mb, batch_processing_enabled, watermark_enabled)
VALUES 
  ('free', '무료 플랜', 0, 'KRW', 5, 3, 5, false, true),
  ('pro', '프로 플랜', 9.99, 'USD', 999999, 999999, 20, true, false)
ON CONFLICT DO NOTHING;

-- =============================================
-- 인덱스 생성 (성능 최적화)
-- =============================================

CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_next_payment ON user_subscriptions(next_payment_at);

CREATE INDEX IF NOT EXISTS idx_payment_history_user_id ON payment_history(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_history_payment_key ON payment_history(payment_key);
CREATE INDEX IF NOT EXISTS idx_payment_history_status ON payment_history(status);

CREATE INDEX IF NOT EXISTS idx_daily_usage_user_date ON daily_usage(user_id, date);

-- =============================================
-- 함수: 사용자 구독 플랜 확인
-- =============================================

CREATE OR REPLACE FUNCTION get_user_subscription_plan(p_user_id UUID)
RETURNS TABLE (
  plan_name TEXT,
  daily_background_removal_limit INTEGER,
  daily_upscaling_limit INTEGER,
  max_file_size_mb INTEGER,
  batch_processing_enabled BOOLEAN,
  watermark_enabled BOOLEAN,
  subscription_status TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    sp.name,
    sp.daily_background_removal_limit,
    sp.daily_upscaling_limit,
    sp.max_file_size_mb,
    sp.batch_processing_enabled,
    sp.watermark_enabled,
    COALESCE(us.status, 'free') as subscription_status
  FROM subscription_plans sp
  LEFT JOIN user_subscriptions us ON us.plan_id = sp.id AND us.user_id = p_user_id
  WHERE sp.name = COALESCE((SELECT name FROM subscription_plans WHERE id = us.plan_id), 'free')
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 함수: 일일 사용량 증가
-- =============================================

CREATE OR REPLACE FUNCTION increment_daily_usage(
  p_user_id UUID,
  p_usage_type TEXT -- 'background_removal' or 'upscaling'
)
RETURNS BOOLEAN AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
BEGIN
  -- 오늘 날짜의 레코드가 없으면 생성
  INSERT INTO daily_usage (user_id, date, background_removal_count, upscaling_count)
  VALUES (p_user_id, v_today, 0, 0)
  ON CONFLICT (user_id, date) DO NOTHING;
  
  -- 사용량 증가
  IF p_usage_type = 'background_removal' THEN
    UPDATE daily_usage
    SET background_removal_count = background_removal_count + 1,
        updated_at = NOW()
    WHERE user_id = p_user_id AND date = v_today;
  ELSIF p_usage_type = 'upscaling' THEN
    UPDATE daily_usage
    SET upscaling_count = upscaling_count + 1,
        updated_at = NOW()
    WHERE user_id = p_user_id AND date = v_today;
  END IF;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 완료!
-- =============================================
-- 이 스키마를 Supabase SQL Editor에서 실행하세요.

