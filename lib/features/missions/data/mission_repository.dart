import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/mission.dart';

final missionRepositoryProvider = Provider<MissionRepository>(
  (ref) => throw UnimplementedError('Mission repository must be overridden.'),
);
final missionsProvider = FutureProvider<List<Mission>>(
  (ref) => ref.read(missionRepositoryProvider).fetchActive(),
);

abstract interface class MissionRepository {
  Future<List<Mission>> fetchActive();
}

class SupabaseMissionRepository implements MissionRepository {
  SupabaseMissionRepository(this._client);
  final SupabaseClient _client;
  @override
  Future<List<Mission>> fetchActive() async {
    final response = await _client
        .from('missions')
        .select(
          'id, title, description, category, estimated_minutes, base_coin_reward, base_xp_reward',
        )
        .eq('active', true)
        .order('estimated_minutes');
    debugPrint('[Missions] loaded active=${response.length}');
    return response.map((row) => Mission.fromJson(row)).toList();
  }
}

class UnavailableMissionRepository implements MissionRepository {
  const UnavailableMissionRepository();
  @override
  Future<List<Mission>> fetchActive() =>
      throw Exception('Supabase가 아직 설정되지 않았어요.');
}
