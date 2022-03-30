class Activity {
  final String habitId;
  final DateTime? timestamp;

  const Activity({
    required this.habitId,
    this.timestamp,
  });

  @override
  String toString() => 'Activity($habitId, $timestamp)';
}

extension ActivityJson on Activity {
  static Activity fromJson(Map<String, dynamic> json) => Activity(
        habitId: json['habit_id'],
        timestamp:
            json['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'], isUtc: true) : null,
      );

  static Map<String, dynamic> toJson(Activity activity) => {
        'habit_id': activity.habitId,
        'timestamp': activity.timestamp?.toUtc().millisecondsSinceEpoch,
      };
}
