import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  String title;
  String description;
  DateTime date;
  TaskPriority priority;
  List<String> tags;
  List<Color> tagColors;
  bool isCompleted;

  // UI State fields (not saved to Firebase)
  bool isRevealDelete;
  bool isExpanded;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    required this.tags,
    required this.tagColors,
    this.isCompleted = false,
    this.isRevealDelete = false,
    this.isExpanded = false,
  });

  // Convert Firebase Document to Task Object
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      priority: TaskPriority.values.firstWhere(
              (p) => p.name == data['priority'],
          orElse: () => TaskPriority.medium
      ),
      tags: List<String>.from(data['tags'] ?? []),
      // Convert stored integers back to Flutter Colors
      tagColors: (data['tagColors'] as List).map((c) => Color(c as int)).toList(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  // Convert Task Object to Map for Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'priority': priority.name,
      'tags': tags,
      // Convert Flutter Colors to integers for storage
      'tagColors': tagColors.map((c) => c.value).toList(),
      'isCompleted': isCompleted,
    };
  }
}