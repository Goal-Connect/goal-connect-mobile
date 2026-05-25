import 'package:goal_connect/features/auth/domain/entities/academy.dart';

class AcademyModel extends Academy {
  const AcademyModel({
    required super.id,
    required super.name,
    super.region,
    super.woreda,
    super.address,
    super.userId,
    super.ownerName,
    super.contactPhone,
    super.playerCount,
  });

  factory AcademyModel.fromJson(Map<String, dynamic> json) {
    String? str(dynamic v) {
      if (v is String && v.trim().isNotEmpty) return v.trim();
      return null;
    }

    int parseCount(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return AcademyModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name'] as String? ?? '',
      region: str(json['region']),
      woreda: str(json['woreda']),
      address: str(json['address']),
      userId: str(json['user']),
      ownerName: str(json['ownerName']),
      contactPhone: str(json['contactPhone']),
      playerCount: parseCount(json['playerCount']),
    );
  }
}
