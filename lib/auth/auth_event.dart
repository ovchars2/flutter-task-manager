part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class Authenticated extends AuthEvent {
  final String userId;

  Authenticated(this.userId);
}

class LoggedOut extends AuthEvent {}