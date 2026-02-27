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
    return PartySummaryModel(
      id: json['id'] as int,
      name: (json['name_party'] ?? '') as String,
      dateStarted: DateTime.parse(json['date_started'] as String).toLocal(),
      dateClosed: DateTime.parse(json['date_closed'] as String).toLocal(),
    );
  }

  PartySummary toEntity() => PartySummary(
    id: id,
    name: name,
    dateStarted: dateStarted,
    dateClosed: dateClosed,
  );
}