import 'scan_detection.dart';
import 'waste_class.dart';

class ScanSession {
  const ScanSession({
    required this.id,
    required this.filename,
    required this.status,
    required this.wasteClass,
    required this.confidenceScore,
    required this.detection,
    required this.message,
    required this.rawPayload,
  });

  final String id;
  final String filename;
  final String status;
  final WasteClass wasteClass;
  final double confidenceScore;
  final ScanDetection detection;
  final String message;
  final Map<String, dynamic> rawPayload;

  int get confidencePercent => (confidenceScore * 100).round().clamp(0, 100);
}
