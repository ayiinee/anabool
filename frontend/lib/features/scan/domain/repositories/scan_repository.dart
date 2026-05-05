import '../entities/scan_image_file.dart';
import '../entities/scan_session.dart';

abstract class ScanRepository {
  Future<ScanSession> uploadScanImage(ScanImageFile imageFile);
  Future<ScanSession> processScan(ScanImageFile imageFile);
  Future<ScanSession> getScanResult(String scanId);
}
