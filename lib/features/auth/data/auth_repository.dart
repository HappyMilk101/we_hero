import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRepository {
  Future<String?> restoreSession();
  Future<String?> signInWithNickname(String nickname);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<String?> restoreSession() async {
    final user = _client.auth.currentUser;
    debugPrint('[Auth] restore: session=${user != null}');
    if (user == null) return null;
    final profile = await _client
        .from('profiles')
        .select('nickname')
        .eq('id', user.id)
        .maybeSingle();
    final nickname = profile?['nickname'] as String?;
    debugPrint(
      '[Auth] restore: profileExists=${nickname != null} userId=${user.id}',
    );
    return nickname;
  }

  @override
  Future<String?> signInWithNickname(String nickname) async {
    debugPrint('[Auth] signInAnonymously: started');
    final response = await _client.auth.signInAnonymously();
    debugPrint(
      '[Auth] signInAnonymously: session=${response.session != null}, '
      'user=${response.user?.id ?? _client.auth.currentUser?.id}',
    );
    final user = response.user ?? _client.auth.currentUser;
    if (user == null) throw Exception('Anonymous Auth 세션을 만들지 못했어요.');

    final exists = await _profileExists(user.id);
    debugPrint('[Auth] profile lookup: exists=$exists userId=${user.id}');
    if (!exists) {
      // Server-managed profile fields intentionally use their database defaults.
      debugPrint('[Auth] profiles insert: started userId=${user.id}');
      await _client.from('profiles').insert({
        'id': user.id,
        'nickname': nickname,
      });
      debugPrint('[Auth] profiles insert: succeeded userId=${user.id}');
      return nickname;
    }
    final profile = await _client
        .from('profiles')
        .select('nickname')
        .eq('id', user.id)
        .single();
    return profile['nickname'] as String?;
  }

  Future<bool> _profileExists(String userId) async {
    try {
      final profile = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return profile != null;
    } catch (error, stackTrace) {
      debugPrint('[Auth] profiles select failed: ${error.runtimeType}: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  Future<String?> restoreSession() async => null;

  @override
  Future<String?> signInWithNickname(String nickname) =>
      throw Exception('Supabase가 아직 설정되지 않았어요.');

  @override
  Future<void> signOut() async {}
}
