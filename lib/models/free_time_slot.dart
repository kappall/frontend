class FreeTimeSlot {
  final DateTime start;
  final DateTime end;
  final int durationInMinutes;
  final Object? recommended;

  FreeTimeSlot({
    required this.start,
    required this.end,
    required this.durationInMinutes,
    required this.recommended,
  });
}
