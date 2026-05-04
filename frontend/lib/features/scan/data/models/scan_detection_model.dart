import '../../domain/entities/scan_detection.dart';

class ScanDetectionModel extends ScanDetection {
  const ScanDetectionModel({
    required super.visualSigns,
    super.photoQuality,
  });

  factory ScanDetectionModel.fromJson(Map<String, dynamic> json) {
    return ScanDetectionModel(
      visualSigns: _readSigns(json),
      photoQuality: _readNullableString(
        json,
        const ['photo_quality', 'photoQuality', 'quality'],
      ),
    );
  }

  static List<String> _readSigns(Map<String, dynamic> json) {
    final value = json['detected_visual_signs'] ??
        json['visual_signs'] ??
        json['detectedVisualSigns'];

    if (value is List) {
      return value
          .whereType<Object>()
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false);
    }

    if (value is String && value.trim().isNotEmpty) {
      return [value];
    }

    return const [];
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
