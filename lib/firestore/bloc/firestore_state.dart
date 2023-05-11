part of 'firestore_bloc.dart';

@immutable
class FirestoreState {
  final List<Task> tasks;

  const FirestoreState(this.tasks);
}
