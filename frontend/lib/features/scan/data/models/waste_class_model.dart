import '../../domain/entities/waste_class.dart';

class WasteClassModel extends WasteClass {
  const WasteClassModel({
    required super.category,
    super.riskLevel,
  });

  factory WasteClassModel.fromJson(Map<String, dynamic> json) {
    return WasteClassModel(
      category: _readString(
        json,
        const ['condition_category', 'detected_class', 'category', 'label'],
        fallback: 'unknown',
      ),
      riskLevel: _readNullableString(json, const ['risk_level', 'riskLevel']),
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }

    return fallback;
  }

  static String? _readNullableString(
      Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }
}
