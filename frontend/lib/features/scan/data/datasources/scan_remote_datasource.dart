import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../domain/entities/scan_image_file.dart';
import '../models/scan_session_model.dart';

abstract class ScanRemoteDatasource {
  Future<ScanSessionModel> uploadScanImage(ScanImageFile imageFile);
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
  Future<ScanSessionModel> uploadScanImage(ScanImageFile imageFile) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        imageFile.bytes,
        filename: imageFile.filename.isEmpty ? 'scan.jpg' : imageFile.filename,
      ),
    });

    final response = await _runScanRequest(
      () => _dio.post<Map<String, dynamic>>(
        '/api/v1/scans/process',
        data: formData,
      ),
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

  Future<Response<Map<String, dynamic>>> _runScanRequest(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ScanRemoteException(_friendlyDioMessage(error));
    }
  }

  String _friendlyDioMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return 'Scan API is not reachable. Make sure the FastAPI backend is running and accessible at ${_dio.options.baseUrl}.';
      case DioExceptionType.badResponse:
        final message = _readBackendMessage(error.response?.data);
        if (message != null) {
          return message;
        }

        final statusCode = error.response?.statusCode;
        return statusCode == null
            ? 'Scan API returned an invalid response.'
            : 'Scan API returned error $statusCode.';
      case DioExceptionType.cancel:
        return 'Scan request was cancelled. Please try again.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return 'Scan API connection failed. Check the API address and network connection.';
    }
  }

  String? _readBackendMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return null;
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
