import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

enum AuthStatus { loading, unauthenticated, authenticated, error }

class AuthState {
  const AuthState(this.status, {this.message, this.nickname});
  const AuthState.loading() : this(AuthStatus.loading);
  const AuthState.unauthenticated() : this(AuthStatus.unauthenticated);
  const AuthState.authenticated() : this(AuthStatus.authenticated);
  const AuthState.error(String message)
    : this(AuthStatus.error, message: message);

  final AuthStatus status;
  final String? message;
  final String? nickname;
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError('Auth repository must be overridden.'),
);

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_restoreSession);
    return const AuthState.loading();
  }

  Future<void> _restoreSession() async {
    try {
      final hasProfile = await ref
          .read(authRepositoryProvider)
          .restoreSession();
      state = hasProfile != null
          ? AuthState(AuthStatus.authenticated, nickname: hasProfile)
          : const AuthState.unauthenticated();
    } catch (error, stackTrace) {
      debugPrint('[Auth] restore failed: ${error.runtimeType}: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = const AuthState.error('로그인 상태를 확인하지 못했어요. 잠시 후 다시 시도해줘.');
    }
  }

  Future<void> signIn(String nickname) async {
    state = const AuthState.loading();
    try {
      final savedNickname = await ref
          .read(authRepositoryProvider)
          .signInWithNickname(nickname);
      state = AuthState(AuthStatus.authenticated, nickname: savedNickname);
    } catch (error, stackTrace) {
      debugPrint('[Auth] sign-in failed: ${error.runtimeType}: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = const AuthState.error('시작하지 못했어요. 잠시 후 다시 시도해줘.');
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AuthState.unauthenticated();
    } catch (error, stackTrace) {
      debugPrint('[Auth] sign-out failed: ${error.runtimeType}: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = const AuthState.error('로그아웃하지 못했어요. 잠시 후 다시 시도해줘.');
    }
  }
}
