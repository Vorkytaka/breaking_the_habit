part of 'auth_bloc.dart';

class AuthState {
  final AuthStateStatus status;

  const AuthState.init() : status = AuthStateStatus.noAuth;

  const AuthState({
    required this.status,
  });
}

enum AuthStateStatus {
  auth,
  noAuth,
}
