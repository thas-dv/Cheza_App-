class PartySummary {
  const PartySummary({
    required this.id,
    required this.name,
    required this.dateStarted,
    required this.dateClosed,
  });

  final int id;
  final String name;
  final DateTime dateStarted;
  final DateTime dateClosed;
}