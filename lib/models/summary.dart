class Summary {
  final DateTime from;
  final DateTime to;

  final int tasksCompleted;
  final int tasksLeft;
  final int tasksCreated;
  final double completionRatio;
  final int freeTimeMinutes;
  final int avgFreeTimeMinutes;
  final int studyStreakDays;

  /// Optional breakdown: null if no granularity
  final List<SummaryBreakdown>? breakdown;

  Summary({
    required this.from,
    required this.to,
    required this.tasksCompleted,
    required this.tasksLeft,
    required this.tasksCreated,
    required this.completionRatio,
    required this.freeTimeMinutes,
    required this.avgFreeTimeMinutes,
    required this.studyStreakDays,
    this.breakdown,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    final interval = json['interval'] as Map<String, dynamic>;

    return Summary(
      from: DateTime.parse(interval['from'] as String),
      to: DateTime.parse(interval['to'] as String),
      tasksCompleted: json['totals']['tasksCompleted'] as int,
      tasksLeft: json['totals']['tasksLeft'] as int,
      tasksCreated: json['totals']['tasksCreated'] as int,
      completionRatio: (json['totals']['completionRatio'] as num).toDouble(),
      freeTimeMinutes: json['totals']['freeTimeMinutes'] as int,
      avgFreeTimeMinutes: json['totals']['avgFreeTimeMinutes'] as int,
      studyStreakDays: json['studyStreakDays'] as int,
      breakdown: json['breakdown'] != null
          ? (json['breakdown'] as List)
                .map((e) => SummaryBreakdown.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interval': {'from': from.toIso8601String(), 'to': to.toIso8601String()},
      'totals': {
        'tasksCompleted': tasksCompleted,
        'tasksLeft': tasksLeft,
        'tasksCreated': tasksCreated,
        'completionRatio': completionRatio,
        'freeTimeMinutes': freeTimeMinutes,
        'avgFreeTimeMinutes': avgFreeTimeMinutes,
      },
      'studyStreakDays': studyStreakDays,
      'breakdown': breakdown?.map((e) => e.toJson()).toList(),
    };
  }

  String get freeTimeFormatted {
    final hours = freeTimeMinutes ~/ 60;
    final minutes = freeTimeMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get avgFreeTimeFormatted {
    final hours = avgFreeTimeMinutes ~/ 60;
    final minutes = avgFreeTimeMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

class SummaryBreakdown {
  final String date;
  final int completed;
  final int left;
  final int created;

  SummaryBreakdown({
    required this.date,
    required this.completed,
    required this.left,
    required this.created,
  });

  factory SummaryBreakdown.fromJson(Map<String, dynamic> json) {
    return SummaryBreakdown(
      date: json['date'] as String,
      completed: json['completed'] as int,
      left: json['left'] as int,
      created: json['created'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'completed': completed,
      'left': left,
      'created': created,
    };
  }
}
