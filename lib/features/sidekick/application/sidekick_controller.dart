import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../data/sidekick_repository.dart';
import '../domain/sidekick_recommendation.dart';

enum SidekickStatus { initial, loading, success, error }

class SidekickState {
  const SidekickState({
    this.status = SidekickStatus.initial,
    this.recommendation,
    this.message,
  });
  final SidekickStatus status;
  final SidekickRecommendation? recommendation;
  final String? message;
}

final sidekickRepositoryProvider = Provider<SidekickRepository>(
  (ref) => throw UnimplementedError('Sidekick repository must be overridden.'),
);

final sidekickControllerProvider =
    NotifierProvider<SidekickController, SidekickState>(SidekickController.new);

class SidekickController extends Notifier<SidekickState> {
  @override
  SidekickState build() => const SidekickState();

  Future<void> request({bool forceRefresh = false}) async {
    debugPrint(
      '[Sidekick] recommendation request started forceRefresh=$forceRefresh',
    );
    state = SidekickState(
      status: SidekickStatus.loading,
      recommendation: state.recommendation,
    );
    try {
      final recommendation = await ref
          .read(sidekickRepositoryProvider)
          .recommend(availableMinutes: 20, forceRefresh: forceRefresh);
      state = SidekickState(
        status: SidekickStatus.success,
        recommendation: recommendation,
      );
    } catch (error, stackTrace) {
      debugPrint('[Sidekick] request failed: ${error.runtimeType}: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = SidekickState(
        status: SidekickStatus.error,
        recommendation: state.recommendation,
        message: '추천 Mission을 불러오지 못했어. 잠시 후 다시 시도해줘.',
      );
    }
  }
}
