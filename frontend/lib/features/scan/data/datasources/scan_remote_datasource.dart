import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../models/scan_session_model.dart';

abstract class ScanRemoteDatasource {
  Future<ScanSessionModel> uploadScanImage(String imagePath);
}

class DioScanRemoteDatasource implements ScanRemoteDatasource {
  DioScanRemoteDatasource({
    Dio? dio,
    String? baseUrl,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ScanApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 60),
              ),
            );

  final Dio _dio;

  @override
  Future<ScanSessionModel> uploadScanImage(String imagePath) async {
    final filename = imagePath.split(RegExp(r'[\\/]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imagePath,
        filename: filename.isEmpty ? 'scan.jpg' : filename,
      ),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/scans/process',
      data: formData,
    );

    final body = response.data;
    if (body == null) {
      throw const ScanRemoteException('Backend returned an empty response.');
    }

    if (body['success'] == false) {
      throw ScanRemoteException(
        body['message']?.toString() ?? 'Scan request failed.',
      );
    }

    return ScanSessionModel.fromApiResponse(body);
  }
}

class ScanApiConfig {
  const ScanApiConfig._();

  static String get baseUrl => ApiConfig.baseUrl;
}

class ScanRemoteException implements Exception {
  const ScanRemoteException(this.message);

  final String message;

  @override
  String toString() => message;
}
