class Summary {
  final int tasksDueToday;
  final int tasksCompletedToday;
  final int freeTimeMinutes;
  final int studyStreakDays;

  Summary({
    required this.tasksDueToday,
    required this.tasksCompletedToday,
    required this.freeTimeMinutes,
    required this.studyStreakDays,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      tasksDueToday: json['tasksDueToday'] as int,
      tasksCompletedToday: json['tasksCompletedToday'] as int,
      freeTimeMinutes: json['freeTimeMinutes'] as int,
      studyStreakDays: json['studyStreakDays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasksDueToday': tasksDueToday,
      'tasksCompletedToday': tasksCompletedToday,
      'freeTimeMinutes': freeTimeMinutes,
      'studyStreakDays': studyStreakDays,
    };
  }
}
