class ScheduleItem {
  final DateTime time;
  final String title;
  final String type;
  final String location;
  final int duration;

  ScheduleItem({
    required this.time,
    required this.title,
    required this.type,
    required this.location,
    required this.duration,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      time: DateTime.parse(json['time']),
      title: json['title'],
      type: json['type'],
      location: json['location'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'title': title,
      'type': type,
      'location': location,
      'duration': duration,
    };
  }
}
