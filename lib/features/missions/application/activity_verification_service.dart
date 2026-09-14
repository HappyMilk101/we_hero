import 'package:image_picker/image_picker.dart';

import '../domain/mission.dart';

class VerificationResult {
  const VerificationResult({required this.approved});
  final bool approved;
}

abstract interface class ActivityVerificationService {
  Future<VerificationResult> verifyActivity(XFile photo, Mission mission);
}

class PrototypeActivityVerificationService
    implements ActivityVerificationService {
  @override
  Future<VerificationResult> verifyActivity(
    XFile photo,
    Mission mission,
  ) async => const VerificationResult(approved: true);
}
