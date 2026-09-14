import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameEconomyState {
  const GameEconomyState({
    this.coinBalance = 500,
    this.heroXp = 0,
    this.heroLevel = 1,
  });
  final int coinBalance, heroXp, heroLevel;
  GameEconomyState copyWith({int? coinBalance, int? heroXp, int? heroLevel}) =>
      GameEconomyState(
        coinBalance: coinBalance ?? this.coinBalance,
        heroXp: heroXp ?? this.heroXp,
        heroLevel: heroLevel ?? this.heroLevel,
      );
}

abstract interface class EconomyRepository {
  GameEconomyState get state;
  GameEconomyState addMissionReward({required int coins, required int xp});
  GameEconomyState purchaseItem({required int price});
}

class LocalEconomyRepository implements EconomyRepository {
  GameEconomyState _state = const GameEconomyState();
  @override
  GameEconomyState get state => _state;
  @override
  GameEconomyState addMissionReward({required int coins, required int xp}) {
    _state = _state.copyWith(
      coinBalance: _state.coinBalance + coins,
      heroXp: _state.heroXp + xp,
    );
    return _state;
  }

  @override
  GameEconomyState purchaseItem({required int price}) {
    if (_state.coinBalance < price) return _state;
    _state = _state.copyWith(coinBalance: _state.coinBalance - price);
    return _state;
  }
}

final economyRepositoryProvider = Provider<EconomyRepository>(
  (ref) => LocalEconomyRepository(),
);
final economyProvider = NotifierProvider<EconomyController, GameEconomyState>(
  EconomyController.new,
);

class EconomyController extends Notifier<GameEconomyState> {
  @override
  GameEconomyState build() => ref.read(economyRepositoryProvider).state;
  void addMissionReward({required int coins, required int xp}) => state = ref
      .read(economyRepositoryProvider)
      .addMissionReward(coins: coins, xp: xp);
  bool purchaseItem(int price) {
    final before = state.coinBalance;
    state = ref.read(economyRepositoryProvider).purchaseItem(price: price);
    return state.coinBalance < before;
  }
}
