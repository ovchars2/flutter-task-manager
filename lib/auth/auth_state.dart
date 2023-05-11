part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class Authorized extends AuthState {
  final String userId;

  Authorized(this.userId);
}

class Unauthorized extends AuthState {}
