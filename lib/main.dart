import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/missions/domain/mission.dart';
import 'features/missions/data/mission_repository.dart';
import 'features/sidekick/application/sidekick_controller.dart';
import 'features/sidekick/data/sidekick_repository.dart';
import 'features/economy/data/economy_repository.dart';
import 'features/missions/application/activity_verification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final url = const String.fromEnvironment('SUPABASE_URL');
  final publishableKey = const String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  SidekickRepository repository = UnavailableSidekickRepository();
  MissionRepository missionRepository = const UnavailableMissionRepository();
  AuthRepository authRepository = const UnavailableAuthRepository();
  debugPrint(
    '[Supabase] configuration: url=${url.isNotEmpty}, '
    'publishableKey=${publishableKey.isNotEmpty}',
  );
  if (url.isNotEmpty && publishableKey.isNotEmpty) {
    await Supabase.initialize(url: url, publishableKey: publishableKey);
    debugPrint('[Supabase] initialized');
    final client = Supabase.instance.client;
    repository = SupabaseSidekickRepository(client);
    missionRepository = SupabaseMissionRepository(client);
    authRepository = SupabaseAuthRepository(client);
  } else {
    debugPrint(
      '[Supabase] not initialized. Start with --dart-define=SUPABASE_URL=... '
      'and --dart-define=SUPABASE_PUBLISHABLE_KEY=...',
    );
  }
  runApp(
    WeHeroApp(
      repository: repository,
      authRepository: authRepository,
      missionRepository: missionRepository,
    ),
  );
}

const navy = Color(0xFF17233C),
    yellow = Color(0xFFFFC857),
    mint = Color(0xFF8ED8C5),
    coral = Color(0xFFFF7D6E),
    bg = Color(0xFFF7F9FC);

class WeHeroApp extends StatelessWidget {
  const WeHeroApp({
    super.key,
    this.repository = const UnavailableSidekickRepository(),
    this.authRepository = const UnavailableAuthRepository(),
    this.missionRepository = const UnavailableMissionRepository(),
  });
  final SidekickRepository repository;
  final AuthRepository authRepository;
  final MissionRepository missionRepository;
  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      sidekickRepositoryProvider.overrideWithValue(repository),
      authRepositoryProvider.overrideWithValue(authRepository),
      missionRepositoryProvider.overrideWithValue(missionRepository),
    ],
    child: const _AuthenticatedApp(),
  );
}

class _AuthenticatedApp extends ConsumerStatefulWidget {
  const _AuthenticatedApp();

  @override
  ConsumerState<_AuthenticatedApp> createState() => _WeHeroAppState();
}

class _WeHeroAppState extends ConsumerState<_AuthenticatedApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  int tab = 0;
  final completed = <String>[];
  final owned = <String>{'기본 티셔츠'};
  String? equipped;
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'WE HERO',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        fontFamily: 'Arial',
      ),
      home: switch (authState.status) {
        AuthStatus.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        AuthStatus.authenticated => _shell(authState.nickname ?? ''),
        AuthStatus.error => Welcome(
          error: authState.message,
          onStart: (nickname) =>
              ref.read(authControllerProvider.notifier).signIn(nickname),
        ),
        AuthStatus.unauthenticated => Welcome(
          onStart: (nickname) =>
              ref.read(authControllerProvider.notifier).signIn(nickname),
        ),
      },
    );
  }

  Widget _shell(String nickname) {
    final economy = ref.watch(economyProvider);
    final missionState = ref.watch(missionsProvider);
    final missionList = missionState.valueOrNull ?? const <Mission>[];
    final pages = [
      Home(
        nickname: nickname,
        missions: missionList,
        coins: economy.coinBalance,
        xp: economy.heroXp,
        completed: completed,
        onMission: _openMission,
      ),
      Missions(
        missions: missionList,
        completed: completed,
        onMission: _openMission,
      ),
      HeroPage(
        nickname: nickname,
        coins: economy.coinBalance,
        xp: economy.heroXp,
        owned: owned,
        equipped: equipped,
        onBuy: _buy,
        onEquip: (v) => setState(() => equipped = v),
      ),
      Profile(
        coins: economy.coinBalance,
        xp: economy.heroXp,
        completed: completed,
        nickname: nickname,
        onLogout: () => ref.read(authControllerProvider.notifier).signOut(),
      ),
    ];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      floatingActionButton: tab < 2
          ? FloatingActionButton.extended(
              backgroundColor: navy,
              foregroundColor: Colors.white,
              onPressed: _sidekick,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Sidekick'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: '미션',
          ),
          NavigationDestination(
            icon: Icon(Icons.face_6_outlined),
            selectedIcon: Icon(Icons.face_6),
            label: '히어로',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }

  void _openMission(Mission mission) {
    debugPrint('[Mission] tapped id=${mission.id ?? 'unknown'}');
    try {
      debugPrint('[Mission] navigate to activity verification');
      _navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => MissionDetail(
            mission: mission,
            done: completed.contains(mission.title),
            onComplete: () {
              setState(() {
                if (!completed.contains(mission.title)) {
                  completed.add(mission.title);
                  ref
                      .read(economyProvider.notifier)
                      .addMissionReward(coins: mission.coin, xp: mission.xp);
                }
              });
              Navigator.pop(context);
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(
                    '완료했어요! Coin +${mission.coin}, XP +${mission.xp}',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('[Mission] navigation failed: ${error.runtimeType}: $error');
      debugPrintStack(stackTrace: stackTrace);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('활동 인증 화면을 열지 못했어요.')));
    }
  }

  void _buy(String item, int price) {
    if (!ref.read(economyProvider.notifier).purchaseItem(price)) return;
    setState(() {
      owned.add(item);
    });
  }

  void _sidekick() {
    debugPrint('[Sidekick] button tapped');
    showModalBottomSheet<void>(
      context: _navigatorKey.currentState!.overlay!.context,
      showDragHandle: true,
      builder: (_) => SidekickSheet(onMission: _openMission),
    );
  }
}

class Welcome extends StatefulWidget {
  const Welcome({super.key, required this.onStart, this.error});
  final ValueChanged<String> onStart;
  final String? error;
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final nicknameController = TextEditingController();
  String? validationMessage;

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  void _submit() {
    final nickname = nicknameController.text.trim();
    final length = nickname.runes.length;
    if (nickname.isEmpty) {
      setState(() => validationMessage = '닉네임을 입력해줘.');
    } else if (length < 2 || length > 20) {
      setState(() => validationMessage = '닉네임은 2~20자로 입력해줘.');
    } else {
      setState(() => validationMessage = null);
      widget.onStart(nickname);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: yellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: navy, size: 70),
          ),
          const SizedBox(height: 28),
          Text(
            'WE HERO',
            style: Theme.of(context).textTheme.displaySmall
                ?.copyWith(fontWeight: FontWeight.w900, color: navy),
          ),
          const SizedBox(height: 12),
          Text(
            '작은 실천이\n히어로를 만듭니다.',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: navy),
          ),
          const SizedBox(height: 12),
          const Text('현실의 좋은 행동을 기록하고\n나만의 Hero를 성장시켜 보세요.'),
          const SizedBox(height: 20),
          TextField(
            controller: nicknameController,
            maxLength: 20,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: '닉네임',
              hintText: '이름을 입력해줘',
              errorText: validationMessage ?? widget.error,
              border: const OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: yellow,
                foregroundColor: navy,
              ),
              onPressed: _submit,
              child: const Text(
                '시작하기',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(onPressed: _submit, child: const Text('바로 시작하기')),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

class Home extends ConsumerWidget {
  const Home({
    super.key,
    required this.nickname,
    required this.missions,
    required this.coins,
    required this.xp,
    required this.completed,
    required this.onMission,
  });
  final String nickname;
  final List<Mission> missions;
  final int coins, xp;
  final List<String> completed;
  final ValueChanged<Mission> onMission;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '좋은 아침이에요, $nickname님',
                style: TextStyle(
                  color: navy,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text('오늘도 작은 영웅이 되어볼까요?'),
            ],
          ),
          CircleAvatar(
            backgroundColor: yellow,
            child: Icon(Icons.star, color: navy),
          ),
        ],
      ),
      const SizedBox(height: 22),
      _heroCard(context),
      const SizedBox(height: 20),
      _sidekickCard(context),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '오늘의 Mission',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: navy),
          ),
          TextButton(
            onPressed: () {
              debugPrint('[Sidekick] today recommendation button tapped');
              ref.read(sidekickControllerProvider.notifier).request();
            },
            child: const Text('오늘의 추천받기'),
          ),
        ],
      ),
      if (missions.isEmpty) const Text('활성화된 Mission을 불러오는 중이거나 아직 없어요.'),
      ...missions
          .take(2)
          .map(
            (m) => MissionTile(
              mission: m,
              done: completed.contains(m.title),
              onTap: () => onMission(m),
            ),
          ),
    ],
  );
  Widget _heroCard(BuildContext c) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: navy,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        const Avatar(),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EVERYDAY HERO',
                style: TextStyle(
                  color: mint,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Lv. 2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (xp % 125) / 125,
                backgroundColor: Colors.white24,
                color: yellow,
              ),
              const SizedBox(height: 6),
              Text(
                '$xp / 225 Hero XP',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: yellow, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    '$coins Coin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _sidekickCard(BuildContext c) => SidekickCard(onMission: onMission);
}

class SidekickCard extends ConsumerWidget {
  const SidekickCard({super.key, required this.onMission});
  final ValueChanged<Mission> onMission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sidekickControllerProvider);
    final recommendation = state.recommendation;
    final mission = recommendation?.recommendedMission;
    final message = state.status == SidekickStatus.error
        ? state.message!
        : recommendation?.sidekickMessage ??
              '오늘 20분 정도 시간이 있다면\nSidekick에게 추천을 받아볼래?';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: mint.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.smart_toy, color: navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: state.status == SidekickStatus.loading
                ? const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('추천을 준비하고 있어요...'),
                    ],
                  )
                : Text(
                    message,
                    style: const TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          TextButton(
            onPressed: state.status == SidekickStatus.loading
                ? null
                : () async {
                    if (mission == null) {
                      await ref
                          .read(sidekickControllerProvider.notifier)
                          .request();
                    } else {
                      onMission(mission);
                    }
                  },
            child: Text(mission == null ? '추천받기' : '보기'),
          ),
        ],
      ),
    );
  }
}

class SidekickSheet extends ConsumerStatefulWidget {
  const SidekickSheet({super.key, required this.onMission});
  final ValueChanged<Mission> onMission;
  @override
  ConsumerState<SidekickSheet> createState() => _SidekickSheetState();
}

class _SidekickSheetState extends ConsumerState<SidekickSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(sidekickControllerProvider.notifier).request(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sidekickControllerProvider);
    final recommendation = state.recommendation;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: mint,
            child: Icon(Icons.smart_toy, color: navy, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            '오늘의 Sidekick',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: navy),
          ),
          const SizedBox(height: 8),
          if (state.status == SidekickStatus.loading)
            const Center(child: CircularProgressIndicator())
          else if (state.status == SidekickStatus.error)
            Text(state.message!)
          else ...[
            Text(recommendation?.sidekickMessage ?? ''),
            if (recommendation?.recommendedMission != null) ...[
              const SizedBox(height: 8),
              Text(
                recommendation!.recommendedMission!.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
            ],
            ...recommendation?.alternativeMissions
                    .take(2)
                    .map((m) => Text('• ${m.title}')) ??
                const <Widget>[],
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              FilledButton(
                onPressed: recommendation?.recommendedMission == null
                    ? null
                    : () {
                        Navigator.pop(context);
                        widget.onMission(recommendation!.recommendedMission!);
                      },
                child: const Text('추천 미션 보기'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => ref
                    .read(sidekickControllerProvider.notifier)
                    .request(forceRefresh: true),
                child: const Text('다른 Mission'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Missions extends StatelessWidget {
  const Missions({
    super.key,
    required this.missions,
    required this.completed,
    required this.onMission,
  });
  final List<Mission> missions;
  final List<String> completed;
  final ValueChanged<Mission> onMission;
  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Mission',
        style: Theme.of(c).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: navy),
      ),
      const Text('작은 행동 하나가 세상을 바꿔요.'),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: yellow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          '오늘의 추천\n부담 없이 10분부터 시작해요.',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      const SizedBox(height: 20),
      ...missions.map(
        (m) => MissionTile(
          mission: m,
          done: completed.contains(m.title),
          onTap: () => onMission(m),
        ),
      ),
    ],
  );
}

class MissionTile extends StatelessWidget {
  const MissionTile({
    super.key,
    required this.mission,
    required this.done,
    required this.onTap,
  });
  final Mission mission;
  final bool done;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      onTap: () {
        debugPrint(
          '[Mission] card tap title=${mission.title} id=${mission.id ?? 'unknown'}',
        );
        onTap();
      },
      contentPadding: const EdgeInsets.all(12),
      leading: CircleAvatar(
        backgroundColor: mint,
        child: Icon(mission.icon, color: navy),
      ),
      title: Text(
        mission.title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: navy),
      ),
      subtitle: Text(
        '${mission.category} · ${mission.minutes}분 · Coin ${mission.coin}',
      ),
      trailing: done
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.chevron_right),
    ),
  );
}

class MissionDetail extends StatefulWidget {
  const MissionDetail({
    super.key,
    required this.mission,
    required this.done,
    required this.onComplete,
  });
  final Mission mission;
  final bool done;
  final VoidCallback onComplete;
  @override
  State<MissionDetail> createState() => _MissionDetailState();
}

class _MissionDetailState extends State<MissionDetail> {
  final _picker = ImagePicker();
  final _verifier = PrototypeActivityVerificationService();
  XFile? photo;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[ActivityVerification] screen built');
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final selected = await _picker.pickImage(source: source);
      if (selected != null) setState(() => photo = selected);
    } catch (error, stackTrace) {
      debugPrint(
        '[Activity] photo selection failed: ${error.runtimeType}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('사진을 불러오지 못했어요.')));
      }
    }
  }

  Future<void> _complete() async {
    if (photo == null || submitting) return;
    setState(() => submitting = true);
    try {
      final result = await _verifier.verifyActivity(photo!, widget.mission);
      if (result.approved) widget.onComplete();
    } catch (error, stackTrace) {
      debugPrint('[Activity] verification failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('활동 인증에 실패했어요.')));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Mission 상세')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: mint,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(widget.mission.icon, size: 90, color: navy),
        ),
        const SizedBox(height: 24),
        Text(
          widget.mission.title,
          style: Theme.of(c).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold, color: navy),
        ),
        const SizedBox(height: 10),
        Text(widget.mission.description, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 18),
        Row(
          children: [
            Chip(label: Text('${widget.mission.minutes}분')),
            const SizedBox(width: 8),
            Chip(label: Text('Coin +${widget.mission.coin}')),
            const SizedBox(width: 8),
            Chip(label: Text('XP +${widget.mission.xp}')),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          '활동 인증',
          style: Theme.of(c).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: navy),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pick(ImageSource.gallery),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: navy.withValues(alpha: .15)),
            ),
            child: Center(
              child: photo != null
                  ? Image.file(File(photo!.path), fit: BoxFit.cover)
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: navy, size: 32),
                        SizedBox(height: 8),
                        Text('사진을 한 장 올려주세요'),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('앨범'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _pick(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('촬영'),
            ),
            if (photo != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() => photo = null),
                child: const Text('삭제'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: widget.done || photo == null || submitting
                ? null
                : _complete,
            child: Text(widget.done ? '완료한 Mission' : 'Mission 완료하기'),
          ),
        ),
      ],
    ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar({super.key});
  @override
  Widget build(BuildContext c) => Container(
    width: 92,
    height: 110,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        const Positioned(
          top: 14,
          child: CircleAvatar(radius: 25, backgroundColor: Color(0xFFFFD2B8)),
        ),
        Positioned(
          top: 52,
          child: Container(
            width: 50,
            height: 48,
            decoration: const BoxDecoration(
              color: coral,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(10),
              ),
            ),
          ),
        ),
        const Positioned(
          top: 6,
          child: Icon(Icons.wb_sunny, color: yellow, size: 34),
        ),
      ],
    ),
  );
}

class HeroPage extends StatelessWidget {
  const HeroPage({
    super.key,
    required this.nickname,
    required this.coins,
    required this.xp,
    required this.owned,
    required this.equipped,
    required this.onBuy,
    required this.onEquip,
  });
  final int coins, xp;
  final String nickname;
  final Set<String> owned;
  final String? equipped;
  final void Function(String, int) onBuy;
  final ValueChanged<String> onEquip;
  @override
  Widget build(BuildContext c) {
    final items = {'민트 후디': 80, '노란 스니커즈': 60, '탐험가 모자': 100};
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '나의 Hero',
          style: Theme.of(c).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: navy),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Avatar(),
              SizedBox(height: 12),
              Text(
                '$nickname의 Everyday Hero',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
            ],
          ),
        ),
        Center(child: Text('Lv. 2 · $xp XP · $coins Coin')),
        const SizedBox(height: 28),
        Text(
          'Avatar Shop',
          style: Theme.of(c).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: navy),
        ),
        const SizedBox(height: 10),
        ...items.entries.map((e) {
          final isOwned = owned.contains(e.key);
          return Card(
            child: ListTile(
              title: Text(
                e.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(isOwned ? '보유 중' : '${e.value} Coin'),
              leading: const CircleAvatar(
                backgroundColor: mint,
                child: Icon(Icons.checkroom, color: navy),
              ),
              trailing: FilledButton(
                onPressed: isOwned
                    ? () => onEquip(e.key)
                    : () => onBuy(e.key, e.value),
                child: Text(
                  isOwned ? (equipped == e.key ? '착용 중' : '착용') : '구매',
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({
    super.key,
    required this.coins,
    required this.xp,
    required this.completed,
    required this.nickname,
    required this.onLogout,
  });
  final int coins, xp;
  final List<String> completed;
  final String nickname;
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        '프로필',
        style: Theme.of(c).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: navy),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          const Avatar(),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              Text('Everyday Hero'),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text('Lv. 2 · $coins Coin · $xp XP'),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout),
        label: const Text('로그아웃 (데이터 초기화)'),
      ),
      const SizedBox(height: 28),
      const Text(
        'Hero Identity',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: navy,
        ),
      ),
      const SizedBox(height: 14),
      _bar('환경', .55, mint),
      _bar('나눔', .25, yellow),
      _bar('지역사회', .2, coral),
      const SizedBox(height: 24),
      Text(
        '최근 활동 ${completed.length}개',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: navy,
        ),
      ),
      const SizedBox(height: 10),
      if (completed.isEmpty)
        const Text('아직 기록이 없어요. 첫 Mission을 시작해보세요.')
      else
        ...completed.map(
          (x) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(x),
            subtitle: const Text('Mission 완료'),
          ),
        ),
    ],
  );
  Widget _bar(String label, double value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(width: 65, child: Text(label)),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            color: color,
            minHeight: 9,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 10),
        Text('${(value * 100).round()}%'),
      ],
    ),
  );
}
