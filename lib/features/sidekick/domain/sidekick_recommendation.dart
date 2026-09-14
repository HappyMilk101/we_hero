import '../../missions/domain/mission.dart';

enum RecommendationSource { ai, fallback, cache }

class SidekickRecommendation {
  const SidekickRecommendation({
    required this.source,
    required this.recommendedMissionId,
    required this.alternativeMissionIds,
    required this.reasonCode,
    required this.sidekickMessage,
    this.recommendedMission,
    this.alternativeMissions = const [],
    this.cachedAt,
  });

  factory SidekickRecommendation.fromJson(
    Map<String, dynamic> json, {
    List<Mission> missions = const [],
  }) {
    final byId = {for (final mission in missions) mission.id: mission};
    final recommendedId = json['recommended_mission_id'] as String?;
    final alternativeIds =
        (json['alternative_mission_ids'] as List<dynamic>? ?? [])
            .whereType<String>()
            .take(2)
            .toList();
    return SidekickRecommendation(
      source: RecommendationSource.values.firstWhere(
        (source) => source.name == json['source'],
        orElse: () => RecommendationSource.fallback,
      ),
      recommendedMissionId: recommendedId ?? '',
      alternativeMissionIds: alternativeIds,
      reasonCode: json['reason_code'] as String? ?? 'good_fit',
      sidekickMessage:
          json['sidekick_message'] as String? ?? '오늘은 가볍게 하나부터 시작해볼까요?',
      recommendedMission: byId[recommendedId],
      alternativeMissions: alternativeIds
          .map((id) => byId[id])
          .whereType<Mission>()
          .toList(),
      cachedAt: json['cached_at'] as String?,
    );
  }

  final RecommendationSource source;
  final String recommendedMissionId, reasonCode, sidekickMessage;
  final List<String> alternativeMissionIds;
  final Mission? recommendedMission;
  final List<Mission> alternativeMissions;
  final String? cachedAt;
}
