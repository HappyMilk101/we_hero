# WE HERO

**WE HERO는 현실에서 작은 선행을 실천할수록 나만의 Hero 아바타가 성장하는 모바일 앱입니다.**

플로깅, 봉사, 나눔, 환경보호 같은 활동을 Mission 형태로 수행하고 인증하면 Coin과 Hero XP를 얻습니다. 사용자는 보상으로 아바타를 꾸미고 성장시키며, AI Sidekick에게 자신의 성향과 활동 이력에 맞는 다음 Mission을 추천받을 수 있습니다.

> **영웅은 특별한 능력이 아니라 작은 실천과 선행으로 성장합니다.**

## 핵심 기능

* **Mission**: 환경·돌봄·나눔·교육·동물·지역사회 활동 참여
* **활동 인증**: 사진을 등록해 Mission 완료
* **Hero 성장**: 활동으로 Coin과 Hero XP 획득
* **Avatar 꾸미기**: Coin으로 아이템 구매 및 장착
* **Hero Identity**: 실제 활동 분야를 기반으로 나의 사회공헌 성향 시각화
* **AI Sidekick**: 관심사·최근 활동·가용시간을 분석해 다음 Mission 추천

## 핵심 사용자 흐름

```text
작은 선행
→ Mission 인증
→ Coin + Hero XP
→ Hero 성장
→ 아바타 꾸미기
→ AI Sidekick 추천
→ 새로운 Mission
```

## 디자인 컨셉

**Cozy Everyday Hero**

전투형 슈퍼히어로가 아니라, 일상의 작은 실천으로 성장하는 Hero를 표현합니다.

* 단순하고 친근한 2D 캐릭터
* 성인도 부담 없는 세련된 스타일
* Hero와 AI Sidekick 중심 UI
* 게임처럼 재미있지만 사회공헌의 의미는 유지

## 향후 확장

초기에는 개인 사용자용 B2C 서비스로 시작하며, 이후 기업 임직원 대상 CSR 플랫폼으로 확장할 수 있습니다.

```text
기업 CSR Campaign
→ 임직원 Mission 참여
→ 활동 인증
→ 기업 전용 Hero Item
→ 참여율·재참여율·활동 데이터 관리
```

## 현재 MVP

현재는 credential 없이 핵심 흐름을 확인할 수 있는 로컬 데모 모드입니다.

```text
시작하기
→ Mission 선택
→ 사진 인증
→ Mission 완료
→ Coin / XP
→ Shop
→ 아이템 구매·장착
→ Profile
```

## 기술 스택

* Flutter 3.47+
* Dart 3.13+
* Supabase
* PostgreSQL
* Supabase Auth / Storage / RLS / Edge Functions
* OpenAI API

AI는 앱에서 직접 호출하지 않고 다음 구조를 사용합니다.

```text
Flutter
→ Supabase Edge Function
→ OpenAI API
```

## 실행

```bash
flutter pub get
flutter run
```

## 검증

```bash
dart format .
flutter analyze
flutter test
```

## 보안 원칙

* OpenAI API Key와 Supabase Service Role Key를 앱에 저장하지 않음
* 활동 사진은 Private Storage 사용
* Coin / XP는 서버에서 계산
* 사용자 데이터는 RLS로 보호

## 장기 비전

**사용자가 Hero입니다.**

Avatar는 사용자의 행동을 보여주고, Mission은 현실의 실천을 만들며, AI Sidekick은 다음 행동을 함께 찾습니다.

