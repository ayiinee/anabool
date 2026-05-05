import '../entities/scan_image_file.dart';
import '../entities/scan_session.dart';
import '../repositories/scan_repository.dart';

class UploadScanImage {
  const UploadScanImage(this._repository);

  final ScanRepository _repository;

  Future<ScanSession> call(ScanImageFile imageFile) {
    return _repository.uploadScanImage(imageFile);
  }
}
