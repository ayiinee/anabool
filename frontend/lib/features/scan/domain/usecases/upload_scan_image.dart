import '../entities/scan_session.dart';
import '../repositories/scan_repository.dart';

class UploadScanImage {
  const UploadScanImage(this._repository);

  final ScanRepository _repository;

  Future<ScanSession> call(String imagePath) {
    return _repository.uploadScanImage(imagePath);
  }
}
