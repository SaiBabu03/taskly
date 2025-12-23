import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';
import 'package:taskly/models/task_model.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TasksBloc() : super(TasksLoading()) {

    // 1. Load Tasks
    on<LoadTasks>((event, emit) async {
      final user = _auth.currentUser;
      if (user == null) {
        emit(TasksError("User not logged in"));
        return;
      }

      await emit.forEach<QuerySnapshot>(
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .orderBy('date', descending: false)
            .snapshots(),
        onData: (snapshot) {
          final tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
          return TasksLoaded(tasks);
        },
      );
    });

    // 2. Add Task
    on<AddTask>((event, emit) async {
      final user = _auth.currentUser;
      if (user == null) return;
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(event.task.id) // Use the generated ID from the model
            .set(event.task.toFirestore());
      } catch (e) {
        emit(TasksError(e.toString()));
      }
    });

    // 3. Toggle Task
    on<ToggleTask>((event, emit) async {
      final user = _auth.currentUser;
      if (user == null) return;
      try {
        final docRef = _firestore.collection('users').doc(user.uid).collection('tasks').doc(event.taskId);
        final doc = await docRef.get();
        await docRef.update({'isCompleted': !(doc['isCompleted'] ?? false)});
      } catch (e) {
        emit(TasksError(e.toString()));
      }
    });

    // 4. Update Task (REGISTERED HANDLER)
    on<UpdateTask>((event, emit) async {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('tasks')
              .doc(event.task.id)
              .update(event.task.toFirestore());
        }
      } catch (e) {
        emit(TasksError(e.toString()));
      }
    });

    // 5. Delete Task
    on<DeleteTask>((event, emit) async {
      final user = _auth.currentUser;
      if (user == null) return;
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(event.taskId)
            .delete();
      } catch (e) {
        emit(TasksError(e.toString()));
      }
    });
  }
}