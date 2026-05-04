import '../entities/scan_session.dart';

abstract class ScanRepository {
  Future<ScanSession> uploadScanImage(String imagePath);
  Future<ScanSession> processScan(String imagePath);
  Future<ScanSession> getScanResult(String scanId);
}
