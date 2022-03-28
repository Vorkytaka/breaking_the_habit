import 'package:flutter/material.dart';

class Habit {
  const Habit({
    required this.color,
    required this.title,
  });

  final Color color;
  final String title;
}

extension HabitJson on Habit {
  static const String keyColor = "color";
  static const String keyTitle = "title";

  static Habit fromJson(Map<String, dynamic> json) => Habit(
        color: Color(json[keyColor]),
        title: json[keyTitle],
      );

  static Map<String, dynamic> toJson(Habit habit) => {
        keyColor: habit.color.value,
        keyTitle: habit.title,
      };
}
