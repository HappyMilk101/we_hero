import 'package:flutter/material.dart';

void main() => runApp(const WeHeroApp());

const navy = Color(0xFF17233C),
    yellow = Color(0xFFFFC857),
    mint = Color(0xFF8ED8C5),
    coral = Color(0xFFFF7D6E),
    bg = Color(0xFFF7F9FC);

class Mission {
  const Mission(
    this.title,
    this.description,
    this.category,
    this.minutes,
    this.coin,
    this.xp,
    this.icon,
  );
  final String title, description, category;
  final int minutes, coin, xp;
  final IconData icon;
}

const missions = <Mission>[
  Mission(
    '플로깅 10분',
    '동네를 산책하며 눈에 보이는 쓰레기를 주워보세요.',
    '환경',
    10,
    10,
    10,
    Icons.eco,
  ),
  Mission(
    '텀블러 사용하기',
    '오늘 한 번, 일회용 컵 대신 나의 컵을 사용해요.',
    '환경',
    5,
    5,
    5,
    Icons.local_cafe,
  ),
  Mission(
    '물건 3개 기부 준비',
    '사용하지 않는 물건을 골라 나눔을 준비해요.',
    '나눔',
    20,
    15,
    10,
    Icons.favorite,
  ),
  Mission(
    '동네 봉사 참여하기',
    '지역을 더 따뜻하게 만드는 활동에 참여해요.',
    '지역사회',
    120,
    30,
    40,
    Icons.diversity_3,
  ),
];

class WeHeroApp extends StatefulWidget {
  const WeHeroApp({super.key});
  @override
  State<WeHeroApp> createState() => _WeHeroAppState();
}

class _WeHeroAppState extends State<WeHeroApp> {
  int tab = 0, coins = 120, xp = 65;
  bool onboarded = false;
  final completed = <String>[];
  final owned = <String>{'기본 티셔츠'};
  String? equipped;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'WE HERO',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: navy),
      fontFamily: 'Arial',
    ),
    home: onboarded
        ? _shell()
        : Welcome(onStart: () => setState(() => onboarded = true)),
  );
  Widget _shell() {
    final pages = [
      Home(coins: coins, xp: xp, completed: completed, onMission: _openMission),
      Missions(completed: completed, onMission: _openMission),
      HeroPage(
        coins: coins,
        xp: xp,
        owned: owned,
        equipped: equipped,
        onBuy: _buy,
        onEquip: (v) => setState(() => equipped = v),
      ),
      Profile(coins: coins, xp: xp, completed: completed),
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

  void _openMission(Mission mission) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MissionDetail(
        mission: mission,
        done: completed.contains(mission.title),
        onComplete: () {
          setState(() {
            if (!completed.contains(mission.title)) {
              completed.add(mission.title);
              coins += mission.coin;
              xp += mission.xp;
            }
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('완료했어요! Coin +${mission.coin}, XP +${mission.xp}'),
            ),
          );
        },
      ),
    ),
  );
  void _buy(String item, int price) {
    if (coins < price) return;
    setState(() {
      coins -= price;
      owned.add(item);
    });
  }

  void _sidekick() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
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
          const Text('최근 환경 미션을 잘 이어가고 있네! 오늘은 10분 플로깅으로 가볍게 시작해볼까?'),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _openMission(missions.first);
            },
            child: const Text('추천 미션 보기'),
          ),
        ],
      ),
    ),
  );
}

class Welcome extends StatelessWidget {
  const Welcome({super.key, required this.onStart});
  final VoidCallback onStart;
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
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: yellow,
                foregroundColor: navy,
              ),
              onPressed: onStart,
              child: const Text(
                '시작하기',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onStart,
              child: const Text('이미 계정이 있어요 · 로그인'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({
    super.key,
    required this.coins,
    required this.xp,
    required this.completed,
    required this.onMission,
  });
  final int coins, xp;
  final List<String> completed;
  final ValueChanged<Mission> onMission;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '좋은 아침이에요, 민지님',
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
            onPressed: () => onMission(missions.first),
            child: const Text('전체 보기'),
          ),
        ],
      ),
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
  Widget _sidekickCard(BuildContext c) => Container(
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
        const Expanded(
          child: Text(
            '오늘 10분 정도 시간이 있다면\n환경 Mission 하나 해볼래?',
            style: TextStyle(color: navy, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () => onMission(missions.first),
          child: const Text('보기'),
        ),
      ],
    ),
  );
}

class Missions extends StatelessWidget {
  const Missions({super.key, required this.completed, required this.onMission});
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
      onTap: onTap,
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
  bool photo = false;
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
          onTap: () => setState(() => photo = true),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: navy.withValues(alpha: .15)),
            ),
            child: Center(
              child: photo
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 42,
                    )
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
        const SizedBox(height: 18),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: widget.done || !photo ? null : widget.onComplete,
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
    required this.coins,
    required this.xp,
    required this.owned,
    required this.equipped,
    required this.onBuy,
    required this.onEquip,
  });
  final int coins, xp;
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
        const Center(
          child: Column(
            children: [
              Avatar(),
              SizedBox(height: 12),
              Text(
                '민지의 Everyday Hero',
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
  });
  final int coins, xp;
  final List<String> completed;
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '민지',
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
