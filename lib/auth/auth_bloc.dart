import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(Unauthorized()) {
    on<Authenticated>(_onAuth);
    on<LoggedOut>(_onLoggedOut);
    FirebaseAuth.instance.userChanges().listen((user) {
      if(user == null){
        add(LoggedOut());
      } else {
        add(Authenticated(user.uid));
      }
    });
  }

  void _onAuth(Authenticated event, Emitter<AuthState> emit) {
    emit(Authorized(event.userId));
  }

  void _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) {
    emit(Unauthorized());
  }
}
