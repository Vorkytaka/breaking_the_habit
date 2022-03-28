import 'dart:async';

import 'package:breaking_the_habit/firebase_holder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthBloc extends Cubit<AuthState> {
  StreamSubscription<User?>? _authStateChanges;

  AuthBloc({
    required FirebaseHolder holder,
  }) : super(const AuthState.init()) {
    _authStateChanges = holder.auth.authStateChanges().listen((user) {
      emit(AuthState(status: user == null ? AuthStateStatus.noAuth : AuthStateStatus.auth));
    });
  }

  @override
  Future<void> close() async {
    await _authStateChanges?.cancel();
    super.close();
  }
}
