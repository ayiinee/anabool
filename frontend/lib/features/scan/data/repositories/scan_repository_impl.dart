import '../../domain/entities/scan_image_file.dart';
import '../../domain/entities/scan_session.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_remote_datasource.dart';

class ScanRepositoryImpl implements ScanRepository {
  const ScanRepositoryImpl({
    required ScanRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final ScanRemoteDatasource _remoteDatasource;

  @override
  Future<ScanSession> uploadScanImage(ScanImageFile imageFile) {
    return _remoteDatasource.uploadScanImage(imageFile);
  }

  @override
  Future<ScanSession> processScan(ScanImageFile imageFile) {
    return uploadScanImage(imageFile);
  }

  @override
  Future<ScanSession> getScanResult(String scanId) {
    throw UnimplementedError(
      'Single-upload MVP returns scan results directly; no scan result lookup yet.',
    );
  }
}
