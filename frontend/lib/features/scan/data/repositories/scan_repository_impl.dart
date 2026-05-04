import '../../domain/entities/scan_session.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_remote_datasource.dart';

class ScanRepositoryImpl implements ScanRepository {
  const ScanRepositoryImpl({
    required ScanRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final ScanRemoteDatasource _remoteDatasource;

  @override
  Future<ScanSession> uploadScanImage(String imagePath) {
    return _remoteDatasource.uploadScanImage(imagePath);
  }

  @override
  Future<ScanSession> processScan(String imagePath) {
    return uploadScanImage(imagePath);
  }

  @override
  Future<ScanSession> getScanResult(String scanId) {
    throw UnimplementedError(
      'Single-upload MVP returns scan results directly; no scan result lookup yet.',
    );
  }
}
