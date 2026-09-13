# WE HERO

작은 선행을 기록하고 Everyday Hero를 성장시키는 Flutter MVP입니다.

## 실행

Flutter 3.47+와 Dart 3.13+가 필요합니다.

```bash
flutter pub get
flutter run
```

현재 앱은 credential 없이 핵심 흐름을 확인할 수 있는 로컬 데모 모드입니다. 시작하기 → Mission 선택 → 사진 인증 영역 탭 → 완료 → Coin/XP → Shop 구매/장착 → Profile 순서로 확인할 수 있습니다.

## Supabase 설정

1. Supabase 프로젝트를 만들고 CLI로 로그인합니다.
2. `.env.example`을 참고해 앱 환경을 설정합니다. 실제 secret은 커밋하지 않습니다.
3. `supabase/migrations/0001_we_hero.sql`을 적용한 후 `supabase/seed.sql`을 실행합니다.
4. `activity-proofs` Storage bucket은 Private으로 만들고, 사진 접근은 Signed URL로 제한합니다.

활동 완료와 보상은 서버 RPC/Edge Function에서 처리해야 합니다. 클라이언트가 보상 Coin/XP를 요청값으로 결정하지 않도록 `missions`를 서버에서 조회하는 계약을 유지합니다. OpenAI 호출은 Supabase Edge Function에서만 수행하며 `OPENAI_API_KEY`, `OPENAI_MODEL`은 Function secret으로 관리합니다.

## 구조 및 제한

화면은 초보자가 읽기 쉬운 작은 위젯으로 구성했고, 실제 Supabase 연결은 repository 계층으로 확장할 수 있도록 SQL 계약을 제공합니다. MVP 데모에서는 Auth, 실제 사진 선택/업로드, Edge Function, 자동 레벨 계산을 로컬 상태로 대체합니다. 다음 단계에서 `supabase_flutter`, `image_picker`, Riverpod, go_router를 추가해 해당 경계를 연결합니다.

## 검증

```bash
dart format .
flutter analyze
flutter test
```

## 보안

OpenAI 키와 Supabase service role key를 앱에 넣지 않습니다. 활동 사진은 공개 bucket으로 만들지 않으며, RLS는 사용자 소유 데이터만 읽도록 합니다. 향후 완료 함수에서 일일 완료 횟수, 중복 SHA-256, 보상 계산을 원자적으로 검증합니다.
