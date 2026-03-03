import 'package:cheza_app/features/dashboard/domain/entities/party_summary.dart';

class PartySummaryModel {
  const PartySummaryModel({
    required this.id,
    required this.name,
    required this.dateStarted,
    required this.dateClosed,
  });

  final int id;
  final String name;
  final DateTime dateStarted;
  final DateTime dateClosed;

  factory PartySummaryModel.fromJson(Map<String, dynamic> json) {
    final started = _parseDate(json['date_started']);
    final closed = _parseDate(json['date_closed']) ?? started;
    return PartySummaryModel(
      id: json['id'] as int,
      name: (json['name_party'] as String?) ?? '',
      dateStarted: started,
      dateClosed: closed,
    );
  }
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value.toLocal();

    final parsed = DateTime.tryParse(value.toString());
    return (parsed ?? DateTime.now()).toLocal();
  }

  PartySummary toEntity() => PartySummary(
    id: id,
    name: name,
    dateStarted: dateStarted,
    dateClosed: dateClosed,
  );
}
