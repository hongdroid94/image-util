# 환경변수 설정 가이드

## Supabase 프로젝트 정보

현재 프로젝트에서 사용 중인 Supabase 정보입니다.

### 프로젝트 상세
- **프로젝트 ID**: `qxxfxwspeaqyreoybbhu`
- **프로젝트명**: `vibecoder-community`
- **리전**: `ap-northeast-2` (서울)
- **상태**: `ACTIVE_HEALTHY`

## 환경변수 설정

### 프론트엔드 (.env.local)

`frontend/.env.local` 파일을 생성하고 다음 내용을 추가하세요:

```env
# Supabase 설정
NEXT_PUBLIC_SUPABASE_URL=https://qxxfxwspeaqyreoybbhu.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# AI 처리 서버
NEXT_PUBLIC_AI_SERVER_URL=http://localhost:8000
```

### Supabase API Keys 찾는 방법

1. [Supabase Dashboard](https://supabase.com/dashboard) 접속
2. `vibecoder-community` 프로젝트 선택
3. 왼쪽 메뉴에서 `Settings` → `API` 클릭
4. **anon public** 키를 복사하여 위 파일에 붙여넣기

## 데이터베이스 구조

다음 테이블들이 이미 생성되었습니다:

### ✅ users_profile
```sql
- id (uuid, PK, FK to auth.users)
- email (text)
- full_name (text)
- avatar_url (text)
- subscription_tier (text: 'free', 'pro', 'enterprise')
- created_at (timestamptz)
- updated_at (timestamptz)
```

### ✅ processing_history
```sql
- id (uuid, PK)
- user_id (uuid, FK to auth.users)
- processing_type (text: 'background_removal', 'upscaling')
- original_image_url (text)
- processed_image_url (text)
- status (text: 'processing', 'completed', 'failed')
- file_size_bytes (bigint)
- processing_time_ms (integer)
- error_message (text)
- created_at (timestamptz)
```

### ✅ usage_stats
```sql
- id (uuid, PK)
- user_id (uuid, FK to auth.users)
- date (date)
- background_removal_count (integer)
- upscaling_count (integer)
- created_at (timestamptz)
- updated_at (timestamptz)
- UNIQUE(user_id, date)
```

## 보안 설정 (RLS)

모든 테이블에 Row Level Security(RLS)가 활성화되어 있습니다:

- **users_profile**: 사용자는 자신의 프로필만 조회/수정 가능
- **processing_history**: 사용자는 자신의 처리 이력만 조회/추가 가능
- **usage_stats**: 사용자는 자신의 사용량만 조회/수정 가능

## Storage Bucket 설정

Image Util에 필요한 스토리지 버킷을 수동으로 생성해야 합니다:

### 1. Supabase Dashboard에서 Storage 설정

1. [Supabase Dashboard](https://supabase.com/dashboard) 접속
2. `vibecoder-community` 프로젝트 선택
3. 왼쪽 메뉴에서 `Storage` 클릭
4. "New bucket" 클릭
5. Bucket 생성:
   - **Name**: `images`
   - **Public bucket**: ✅ 체크 (이미지 다운로드를 위해 필요)
6. "Create bucket" 클릭

### 2. Storage 정책 설정 (선택사항)

더 세밀한 접근 제어가 필요한 경우:

```sql
-- 사용자는 자신의 폴더에만 업로드 가능
create policy "Users can upload to own folder"
on storage.objects for insert
with check (
  bucket_id = 'images' 
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- 모든 사용자는 이미지를 읽을 수 있음 (public bucket)
create policy "Anyone can view images"
on storage.objects for select
using (bucket_id = 'images');
```

## 사용량 제한

기본 사용량 제한이 설정되어 있습니다:

### 무료 플랜 (free)
- 배경 제거: 5회/일
- 업스케일링: 3회/일

### 프로 플랜 (pro)
- 배경 제거: 무제한
- 업스케일링: 무제한

### 사용량 제한 변경

사용자의 플랜을 변경하려면:

```sql
-- Supabase SQL Editor에서 실행
update users_profile 
set subscription_tier = 'pro' 
where email = 'user@example.com';
```

## 유용한 SQL 쿼리

### 모든 사용자 조회
```sql
select * from users_profile;
```

### 오늘의 사용량 조회
```sql
select u.email, us.*
from usage_stats us
join users_profile u on u.id = us.user_id
where us.date = current_date;
```

### 처리 이력 조회
```sql
select u.email, ph.*
from processing_history ph
join users_profile u on u.id = ph.user_id
order by ph.created_at desc
limit 10;
```

## 문제 해결

### "Invalid API key" 오류
- `.env.local` 파일이 올바르게 생성되었는지 확인
- Supabase Dashboard에서 API Keys 재확인
- 개발 서버 재시작

### "Row Level Security policy" 오류
- RLS 정책이 올바르게 설정되었는지 확인
- Supabase SQL Editor에서 정책 확인:
  ```sql
  select * from pg_policies where schemaname = 'public';
  ```

### Storage 업로드 오류
- `images` 버킷이 생성되었는지 확인
- Public bucket으로 설정되었는지 확인

## 다음 단계

1. ✅ 데이터베이스 테이블 생성 완료
2. ⏳ Storage 버킷 수동 생성 필요
3. ⏳ 프론트엔드 환경변수 설정
4. ⏳ 백엔드 서버 실행
5. ⏳ 테스트

환경 설정이 완료되면 [SETUP.md](./SETUP.md)의 "5️⃣ 기능 테스트" 섹션으로 이동하세요!

