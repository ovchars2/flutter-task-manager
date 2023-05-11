import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:test/auth/auth_bloc.dart';
import 'package:test/firestore/model/task.dart';

part 'firestore_event.dart';

part 'firestore_state.dart';

class FirestoreBloc extends Bloc<FirestoreEvent, FirestoreState> {
  CollectionReference<Task>? ref;
  StreamSubscription? _firestoreSub;

  FirestoreBloc(AuthBloc authBloc) : super(const FirestoreState([])) {
    on<UserChanged>(_handleUserChange);
    on<FirestoreDataUpdated>(_handleDataUpdate);
    on<TaskCompleted>(_handleTaskCompleted);
    on<TaskDeleted>(_handleTaskDeleted);
    on<TaskAdded>(_handleTaskAdded);
    authBloc.stream.listen(authStateHandle);
    authStateHandle(authBloc.state);
  }

  void authStateHandle(AuthState authState) {
    if (authState is Authorized) {
      add(UserChanged(authState.userId));
    } else {
      add(UserChanged(null));
    }
  }

  FutureOr<void> _handleDataUpdate(FirestoreDataUpdated event, Emitter<FirestoreState> emit) {
    final tasks = [...event.data];
    tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    emit(FirestoreState(tasks));
  }

  Future<void> _handleTaskCompleted(TaskCompleted event, Emitter<FirestoreState> emit) async {
    if (ref == null) {
      return;
    }
    final query = await ref!.where('createdAt', isEqualTo: event.task.createdAt.millisecondsSinceEpoch).get();
    final id = query.docs.first.id;
    final upd = FinishedTask(
      createdAt: event.task.createdAt,
      name: event.task.name,
      completedAt: DateTime.now(),
    );
    await ref!.doc(id).update(upd.toMap());
  }

  Future<void> _handleTaskDeleted(TaskDeleted event, Emitter<FirestoreState> emit) async {
    if (ref == null) {
      return;
    }
    final query = await ref!.where('createdAt', isEqualTo: event.task.createdAt.millisecondsSinceEpoch).get();
    final id = query.docs.first.id;

    await ref!.doc(id).delete();
  }

  void _handleTaskAdded(TaskAdded event, Emitter<FirestoreState> emit) {
    if (ref == null) {
      return;
    }
    ref!.add(event.task);
  }

  void _handleUserChange(UserChanged event, Emitter<FirestoreState> emit) {
    if (event.userId == null) {
      ref = null;
      _firestoreSub?.cancel();
    } else {
      ref = null;
      _firestoreSub?.cancel();
      ref = FirebaseFirestore.instance.collection('users').doc(event.userId!).collection('tasks').withConverter(
            fromFirestore: (documentSnapshot, _) {
              return Task.fromMap(documentSnapshot.data()!);
            },
            toFirestore: (task, _) => task.toMap(),
          );
      _firestoreSub = ref!.snapshots().listen(_handleFirestoreUpdate);
    }
  }

  void _handleFirestoreUpdate(QuerySnapshot<Task> event) {
    final docs = event.docs.map((doc) => doc.data()).toList();
    add(FirestoreDataUpdated(data: docs));
  }
}
