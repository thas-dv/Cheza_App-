// lib/models/party_model.dart

class PartyModel {
  final int id;
  final String name;
  final DateTime dateStarted;
  final DateTime? dateClosed;
  final bool active;

  PartyModel({
    required this.id,
    required this.name,
    required this.dateStarted,
    this.dateClosed,
    required this.active,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'],
      name: json['name_party'] ?? 'Sans nom',
      dateStarted: DateTime.parse(json['date_started']),
      dateClosed: json['date_closed'] == null
          ? null
          : DateTime.parse(json['date_closed']),
      active: json['active'] ?? false,
    );
  }
}
