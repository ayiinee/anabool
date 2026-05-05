import 'package:flutter/foundation.dart';

import '../../data/datasources/scan_remote_datasource.dart';
import '../../data/repositories/scan_repository_impl.dart';
import '../../domain/entities/scan_image_file.dart';
import '../../domain/entities/scan_session.dart';
import '../../domain/usecases/upload_scan_image.dart';

class ScanController extends ChangeNotifier {
  ScanController({
    required UploadScanImage uploadScanImage,
  }) : _uploadScanImage = uploadScanImage;

  factory ScanController.create() {
    final datasource = DioScanRemoteDatasource();
    final repository = ScanRepositoryImpl(remoteDatasource: datasource);
    return ScanController(uploadScanImage: UploadScanImage(repository));
  }

  final UploadScanImage _uploadScanImage;

  bool isLoading = false;
  String? errorMessage;
  ScanSession? latestSession;

  Future<ScanSession?> analyzeImage(ScanImageFile imageFile) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      latestSession = await _uploadScanImage(imageFile);
      return latestSession;
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
