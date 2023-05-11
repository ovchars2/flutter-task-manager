part of 'firestore_bloc.dart';

@immutable
abstract class FirestoreEvent {}

class UserChanged extends FirestoreEvent {
  final String? userId;

  UserChanged(this.userId);
}

class FirestoreDataUpdated extends FirestoreEvent {
  final List<Task> data;

  FirestoreDataUpdated({required this.data});
}

class TaskCompleted extends FirestoreEvent {
  final Task task;

  TaskCompleted(this.task);
}

class TaskDeleted extends FirestoreEvent {
  final Task task;

  TaskDeleted(this.task);
}

class TaskAdded extends FirestoreEvent {
  final UnfinishedTask task;

  TaskAdded(this.task);
}
