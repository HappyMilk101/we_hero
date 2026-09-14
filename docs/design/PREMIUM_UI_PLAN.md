# WE HERO Premium UI Plan

## 1. Current UI and functional baseline

The app currently uses one `MaterialApp`, a four-tab shell, and a single large `lib/main.dart` presentation layer. Supabase Auth, mission loading, Sidekick, Mission Card navigation, camera/gallery verification, prototype Economy, and Shop callbacks are already wired.

## 2. Protected contracts

Keep `authControllerProvider`, `missionsProvider`, `sidekickControllerProvider`, `economyProvider`, `MissionDetail`, `_openMission`, `onMission`, `onComplete`, `onBuy`, and `onEquip` behavior unchanged. Do not alter migrations, RLS, Edge Function contracts, reward calculation, or persistence.

## 3. Design direction

“Everyday Hero HQ”: a cozy-futuristic, character-centered home where the next real-world action is immediately obvious. Preserve Hero Navy `#17233C`, Hope Yellow `#FFC857`, Hero Mint `#8ED8C5`, Soft Coral `#FF7D6E`, and `#F7F9FC`.

## 4. Research references and extracted principles

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines): hierarchy, familiar navigation, readable typography, accessible controls, and clear state changes.
- [Apple Accessibility HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility): support larger text, sufficient contrast, visual alternatives to audio, and reduced motion.
- [Apple Motion HIG](https://developer.apple.com/design/human-interface-guidelines/motion): use motion for feedback and orientation, not delay.
- Duolingo-inspired principles: one obvious next action, short copy, immediate reward feedback, character-led encouragement, and friendly empty/error states. WE HERO adapts these to real-world missions and its own palette and Hero HQ metaphor.

## 5. Token and component system

Add `lib/design/` tokens for colors, spacing, radius, typography, motion, and elevation. Add reusable presentation components for Hero stage, reward chips, mission cards, Sidekick bubble, XP bar, empty/error states, and item cards. Components must receive existing data/callbacks rather than duplicate business logic.

## 6. Screen hierarchy

1. Home: Hero stage, greeting/Coin, Sidekick, recommended Mission, compact progress.
2. Mission: scannable category/title/time/reward cards; preserve direct tap to verification.
3. Hero: Hero Locker preview and existing owned/equipped/purchase states.
4. Activity Verification: Quest Proof layout while preserving picker, preview, completion, and reward callbacks.
5. Profile: Hero Journey using only currently available data.

## 7. Art direction

Use the existing original geometric avatar and Material icon family consistently. Hero Gear should feel like original everyday rescue equipment through silhouette, badge, cape, visor, and utility shapes; do not use copyrighted character IP or third-party bitmap assets.

## 8. Motion and accessibility

Use 120–350ms transitions for tactile feedback, avoid blocking flows, and respect text scaling. Keep controls at least 44px where practical, expose semantic labels, avoid color-only status, and provide reduced-motion-safe behavior.

## 9. Regression risks

The main risks are losing callback wiring while extracting widgets, creating a second Coin state, breaking Navigator context, or changing mobile camera/gallery behavior. Each screen will be verified against the existing providers and callbacks before moving to the next screen.

## 10. Rollback

Baseline branch: `feat/premium-ui-v2`. Baseline commit: `de95d20 chore: snapshot functional prototype before UI redesign`. Revert presentation commits or return to that baseline branch/commit if a regression is found; preserve unrelated working-tree changes.

## DESIGN-RELATED SUGGESTIONS

- Persisting Economy data and activity history would improve retention but is out of scope.
- Dynamic Hero Identity percentages require real activity aggregation and should not be fabricated in this pass.
- AI photo verification and new Gear unlock rules should be proposed separately, not introduced as visual-only behavior.
