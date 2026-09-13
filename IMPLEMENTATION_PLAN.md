# WE HERO 구현 계획

## 범위

- Flutter Material 3 기반 Cozy Everyday Hero UI
- 로컬 데모 저장소로 온보딩, 미션, 인증, 보상, 아바타 상점/장착, 프로필, Sidekick 흐름 구현
- Supabase 연동을 교체 가능한 repository 경계로 유지하고 SQL migration/seed 제공
- credential이 없는 환경에서도 `flutter run`으로 핵심 제품 루프 확인

## 검증

- `flutter pub get`, `dart format .`, `flutter analyze`, `flutter test`
- 가능하면 `flutter build`로 컴파일 확인
