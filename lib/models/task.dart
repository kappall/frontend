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
      deadline: json['deadline'],
      estimated_minutes: json['estimated_minutes'],
      created_at: json['created_at'],
      completed_at: json['completed_at'],
      priority: json['priority'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "subject": subject,
    "deadline": deadline,
    "estimated_minutes": estimated_minutes,
    "created_at": created_at,
    "completed_at": completed_at,
    "priority": priority,
    "status": status,
  };
}
