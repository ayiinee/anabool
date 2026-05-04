import '../entities/scan_session.dart';
import '../repositories/scan_repository.dart';

class GetScanResult {
  const GetScanResult(this._repository);

  final ScanRepository _repository;

  Future<ScanSession> call(String scanId) {
    return _repository.getScanResult(scanId);
  }
}
