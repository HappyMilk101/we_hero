import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../missions/domain/mission.dart';
import '../domain/sidekick_recommendation.dart';

abstract interface class SidekickRepository {
  Future<SidekickRecommendation> recommend({
    required int availableMinutes,
    required bool forceRefresh,
  });
}

class SupabaseSidekickRepository implements SidekickRepository {
  SupabaseSidekickRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<SidekickRecommendation> recommend({
    required int availableMinutes,
    required bool forceRefresh,
  }) async {
    final session = _client.auth.currentSession;
    final userId = _client.auth.currentUser?.id;
    debugPrint(
      '[Sidekick] auth before invoke: session=${session != null} '
      'userId=${userId ?? 'none'}',
    );
    if (session == null || userId == null) {
      throw Exception('로그인 후 Sidekick 추천을 요청할 수 있어요.');
    }
    final body = {
      'available_minutes': availableMinutes,
      'force_refresh': forceRefresh,
    };
    debugPrint(
      '[Sidekick] invoke started function=recommend-missions body=$body',
    );
    late final FunctionResponse response;
    try {
      response = await _client.functions.invoke(
        'recommend-missions',
        body: body,
      );
    } on FunctionException catch (error, stackTrace) {
      debugPrint(
        '[Sidekick] FunctionsException status=${error.status} '
        'reason=${error.reasonPhrase} details=${error.details}',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('[Sidekick] invoke exception ${error.runtimeType}: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
    debugPrint(
      '[Sidekick] invoke completed status=${response.status} data=${response.data}',
    );
    final data = response.data;
    if (data is! Map) throw Exception('추천 응답을 이해하지 못했어요.');
    final json = Map<String, dynamic>.from(data);
    if (json['error'] is Map) {
      final error = json['error'];
      throw Exception('recommend-missions failed: $error');
    }

    final ids = <String>[
      if (json['recommended_mission_id'] is String)
        json['recommended_mission_id'] as String,
      ...(json['alternative_mission_ids'] as List<dynamic>? ?? [])
          .whereType<String>()
          .take(2),
    ];
    final rows = ids.isEmpty
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(
            await _client
                .from('missions')
                .select(
                  'id, title, description, category, estimated_minutes, base_coin_reward, base_xp_reward',
                )
                .inFilter('id', ids),
          );
    return SidekickRecommendation.fromJson(
      json,
      missions: rows.map(Mission.fromJson).toList(),
    );
  }
}

class UnavailableSidekickRepository implements SidekickRepository {
  const UnavailableSidekickRepository();

  @override
  Future<SidekickRecommendation> recommend({
    required int availableMinutes,
    required bool forceRefresh,
  }) => throw Exception('Supabase가 아직 설정되지 않았어요.');
}
