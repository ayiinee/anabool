import '../entities/scan_image_file.dart';
import '../entities/scan_session.dart';
import '../repositories/scan_repository.dart';

class ProcessScan {
  const ProcessScan(this._repository);

  final ScanRepository _repository;

  Future<ScanSession> call(ScanImageFile imageFile) {
    return _repository.processScan(imageFile);
  }
}
