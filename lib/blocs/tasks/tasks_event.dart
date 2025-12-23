
import 'package:taskly/models/task_model.dart';

abstract class TasksEvent {}

class LoadTasks extends TasksEvent {}

class AddTask extends TasksEvent {
  final Task task;
  AddTask(this.task);
}

class ToggleTask extends TasksEvent {
  final String taskId;
  ToggleTask(this.taskId);
}

class UpdateTask extends TasksEvent {
  final Task task;
  UpdateTask(this.task);
}

class DeleteTask extends TasksEvent {
  final String taskId;
  DeleteTask(this.taskId);
}