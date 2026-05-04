import '../entities/scan_session.dart';
import '../repositories/scan_repository.dart';

class ProcessScan {
  const ProcessScan(this._repository);

  final ScanRepository _repository;

  Future<ScanSession> call(String imagePath) {
    return _repository.processScan(imagePath);
  }
}
