class FreeTimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final int duration;

  FreeTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.duration,
  });

  factory FreeTimeSlot.fromJson(Map<String, dynamic> json) {
    return FreeTimeSlot(
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration': duration,
    };
  }
}
