import '../../domain/entities/scout_preference.dart';

class ScoutPreferenceModel extends ScoutPreference {
  const ScoutPreferenceModel({
    super.positions,
    super.regions,
    super.minAge,
    super.maxAge,
  });

  factory ScoutPreferenceModel.fromEntity(ScoutPreference p) {
    return ScoutPreferenceModel(
      positions: p.positions,
      regions: p.regions,
      minAge: p.minAge,
      maxAge: p.maxAge,
    );
  }

  /// Parses the `data` payload from the API. Tolerates both shapes the
  /// backend uses:
  ///  * `GET /scouts/preferences` → `{ interestedPositions: [], preferredRegions: [], preferredAgeRange: { min, max } }`
  ///  * `POST/PUT` echo → `{ position: [], region: [], minAge, maxAge }`
  factory ScoutPreferenceModel.fromJson(Map<String, dynamic> json) {
    final positions = _stringList(json['position']) ??
        _stringList(json['positions']) ??
        _stringList(json['interestedPositions']) ??
        const <String>[];
    final regions = _stringList(json['region']) ??
        _stringList(json['regions']) ??
        _stringList(json['preferredRegions']) ??
        const <String>[];

    int? minAge = _toInt(json['minAge']);
    int? maxAge = _toInt(json['maxAge']);
    final range = json['preferredAgeRange'];
    if (range is Map) {
      final rMap = Map<String, dynamic>.from(range);
      minAge ??= _toInt(rMap['min']);
      maxAge ??= _toInt(rMap['max']);
    }

    return ScoutPreferenceModel(
      positions: positions,
      regions: regions,
      minAge: minAge,
      maxAge: maxAge,
    );
  }

  /// Body for POST/PUT — single-key arrays, age as flat min/max ints.
  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{};
    if (positions.isNotEmpty) out['position'] = positions;
    if (regions.isNotEmpty) out['region'] = regions;
    if (minAge != null) out['minAge'] = minAge;
    if (maxAge != null) out['maxAge'] = maxAge;
    return out;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static List<String>? _stringList(dynamic v) {
    if (v == null) return null;
    if (v is List) {
      final out = <String>[];
      for (final e in v) {
        if (e == null) continue;
        final s = e.toString().trim();
        if (s.isNotEmpty) out.add(s);
      }
      return out;
    }
    if (v is String) {
      final s = v.trim();
      return s.isEmpty ? const [] : [s];
    }
    return null;
  }
}
