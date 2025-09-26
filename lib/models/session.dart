class Session {
  final String id;
  final String user_id;
  final String task_id;
  final DateTime start_ts;
  final DateTime end_ts;
  final String outcome;
  final int rating;
  final DateTime created_at;

  Session({
    required this.id,
    required this.user_id,
    required this.task_id,
    required this.start_ts,
    required this.end_ts,
    required this.outcome,
    required this.rating,
    required this.created_at,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      user_id: json['user_id'],
      task_id: json['task_id'],
      start_ts: json['start_ts'],
      end_ts: json['end_ts'],
      created_at: json['created_at'],
      outcome: json['outcome'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": user_id,
    "task_id": task_id,
    "start_ts": start_ts,
    "end_ts": end_ts,
    "created_at": created_at,
    "outcome": outcome,
    "rating": rating,
  };
}
