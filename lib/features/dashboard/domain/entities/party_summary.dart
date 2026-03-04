class PartySummary {
  final int id;
  final String name;
  final DateTime dateStarted;
  final DateTime dateClosed;

  const PartySummary({
    required this.id,
    required this.name,
    required this.dateStarted,
    required this.dateClosed,
  });

  factory PartySummary.fromJson(Map<String, dynamic> json) {
    return PartySummary(
      id: json['id'],
      name: json['name'],
      dateStarted: DateTime.parse(json['date_started']),
      dateClosed: DateTime.parse(json['date_closed']),
    );
  }
}
