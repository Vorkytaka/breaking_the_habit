import 'package:flutter/material.dart';

class Habit {
  const Habit({
    required this.color,
    required this.title,
    this.archive = false,
  });

  final Color color;
  final String title;
  final bool archive;
}

extension HabitJson on Habit {
  static const String keyColor = "color";
  static const String keyTitle = "title";
  static const String keyArchive = "archive";

  static Habit fromJson(Map<String, dynamic> json) => Habit(
        color: Color(json[keyColor]),
        title: json[keyTitle],
        archive: json[keyArchive] ?? false,
      );

  static Map<String, dynamic> toJson(Habit habit) => {
        keyColor: habit.color.value,
        keyTitle: habit.title,
        keyArchive: habit.archive,
      };
}
