import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../scan/domain/entities/scan_session.dart';
import '../models/chat_session_model.dart';

abstract class ChatRemoteDatasource {
  Future<ChatSessionModel> startChatFromScan({
    String? scanId,
    ScanSession? scanSession,
  });
  Future<ChatSessionModel> sendChatMessage(String sessionId, String content);
}

class DioChatRemoteDatasource implements ChatRemoteDatasource {
  DioChatRemoteDatasource({
    Dio? dio,
    String? baseUrl,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ChatApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 60),
              ),
            );

  final Dio _dio;

  @override
  Future<ChatSessionModel> startChatFromScan({
    String? scanId,
    ScanSession? scanSession,
  }) async {
    final response = await _runChatRequest(
      () => _dio.post<Map<String, dynamic>>(
        '/api/v1/chats/sessions',
        data: {
          if (scanId != null && scanId.trim().isNotEmpty) 'scan_id': scanId,
          if (scanSession != null) ...{
            'detected_class': scanSession.wasteClass.category,
            'confidence_score': scanSession.confidenceScore,
            if (scanSession.wasteClass.riskLevel != null)
              'risk_level': scanSession.wasteClass.riskLevel,
            'filename': scanSession.filename,
          },
        },
      ),
    );

    return _readSession(response.data);
  }

  @override
  Future<ChatSessionModel> sendChatMessage(
    String sessionId,
    String content,
  ) async {
    final response = await _runChatRequest(
      () => _dio.post<Map<String, dynamic>>(
        '/api/v1/chats/$sessionId/messages',
        data: {'content': content},
      ),
    );

    return _readSession(response.data);
  }

  Future<Response<Map<String, dynamic>>> _runChatRequest(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ChatRemoteException(_friendlyDioMessage(error));
    }
  }

  String _friendlyDioMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return 'Ana belum tersambung ke backend. Pastikan server backend ANABOOL berjalan dan alamat API sesuai perangkat ini.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return statusCode == null
            ? 'Backend chat mengembalikan respons yang belum bisa diproses.'
            : 'Backend chat mengembalikan error $statusCode. Coba lagi setelah endpoint RAG diperbaiki.';
      case DioExceptionType.cancel:
        return 'Permintaan chat dibatalkan. Coba kirim ulang pesan.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return 'Koneksi ke backend chat belum berhasil. Periksa alamat API dan koneksi perangkat.';
    }
  }

  ChatSessionModel _readSession(Map<String, dynamic>? body) {
    if (body == null) {
      throw const ChatRemoteException('Backend returned an empty response.');
    }

    if (body['success'] == false) {
      throw ChatRemoteException(
        body['message']?.toString() ?? 'Chat request failed.',
      );
    }

    return ChatSessionModel.fromApiResponse(body);
  }
}

class ChatApiConfig {
  const ChatApiConfig._();

  static String get baseUrl => ApiConfig.baseUrl;
}

class ChatRemoteException implements Exception {
  const ChatRemoteException(this.message);

  final String message;

  @override
  String toString() => message;
}
