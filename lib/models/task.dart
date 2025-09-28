class Task {
  final String? id;
  final String title;
  final String subject;
  final int estimated_minutes;
  final DateTime deadline;
  final int priority;
  final String? status;
  final DateTime? created_at;
  final DateTime? completed_at;

  Task({
    required this.id,
    required this.title,
    required this.subject,
    required this.estimated_minutes,
    required this.deadline,
    required this.priority,
    required this.status,
    required this.created_at,
    required this.completed_at,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      deadline: DateTime.parse(json['deadline']),
      estimated_minutes: json['estimated_minutes'],
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      completed_at: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      priority: json['priority'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "subject": subject,
    "deadline": deadline.toIso8601String(),
    "estimated_minutes": estimated_minutes,
    "created_at": created_at?.toIso8601String(),
    "completed_at": completed_at?.toIso8601String(),
    "priority": priority,
    "status": status,
  };

  String getPriorityString() {
    switch (priority) {
      case 0:
        return "low";
      case 1:
        return "medium";
      case 2:
        return "high";
      default:
        return "low";
    }
  }

  Task copyWith({
    String? id,
    String? title,
    String? subject,
    int? estimated_minutes,
    DateTime? deadline,
    int? priority,
    String? status,
    DateTime? created_at,
    DateTime? completed_at,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      estimated_minutes: estimated_minutes ?? this.estimated_minutes,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      created_at: created_at ?? this.created_at,
      completed_at: completed_at ?? this.completed_at,
    );
  }
}
