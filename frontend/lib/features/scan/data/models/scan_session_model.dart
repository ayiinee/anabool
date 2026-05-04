import '../../domain/entities/scan_session.dart';
import 'scan_detection_model.dart';
import 'waste_class_model.dart';

class ScanSessionModel extends ScanSession {
  const ScanSessionModel({
    required super.filename,
    required super.status,
    required super.wasteClass,
    required super.confidenceScore,
    required super.detection,
    required super.message,
    required super.rawPayload,
  });

  factory ScanSessionModel.fromApiResponse(Map<String, dynamic> json) {
    final data = _extractData(json);

    return ScanSessionModel(
      filename:
          _readString(data, const ['filename', 'file_name'], fallback: '-'),
      status: _readString(
        data,
        const ['scan_status', 'status'],
        fallback: _readString(json, const ['message'], fallback: 'completed'),
      ),
      wasteClass: WasteClassModel.fromJson(data),
      confidenceScore: _readConfidence(data),
      detection: ScanDetectionModel.fromJson(data),
      message: _readString(
        data,
        const ['message'],
        fallback:
            _readString(json, const ['message'], fallback: 'Scan completed'),
      ),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  static Map<String, dynamic> _extractData(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return json;
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

  static double _readConfidence(Map<String, dynamic> json) {
    final value =
        json['confidence_score'] ?? json['confidence'] ?? json['score'];
    if (value is num) {
      return value.toDouble() > 1 ? value.toDouble() / 100 : value.toDouble();
    }

    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed > 1 ? parsed / 100 : parsed;
      }
    }

    return 0;
  }
}
