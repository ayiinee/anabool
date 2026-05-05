import 'package:dio/dio.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../core/network/api_config.dart';
import '../models/education_category_model.dart';
import '../models/education_content_model.dart';
import '../models/user_edu_progress_model.dart';

abstract class EducationRemoteDatasource {
  Future<List<EducationCategoryModel>> getCategories();
  Future<List<EducationContentModel>> getContents();
  Future<EducationContentModel> getDetail(String contentId);
  Future<List<UserEduProgressModel>> getProgress();
  Future<UserEduProgressModel> completeContent(String contentId);
}

class DioEducationRemoteDatasource implements EducationRemoteDatasource {
  DioEducationRemoteDatasource({
    Dio? dio,
    String? baseUrl,
    EducationRemoteDatasource? fallbackDatasource,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 30),
              ),
            ),
        _fallbackDatasource =
            fallbackDatasource ?? LocalEducationRemoteDatasource();

  final Dio _dio;
  final EducationRemoteDatasource _fallbackDatasource;

  List<EducationCategoryModel> _categories = const [];
  List<EducationContentModel> _contents = const [];
  List<UserEduProgressModel> _progress = const [];
  Future<void>? _catalogLoad;

  @override
  Future<List<EducationCategoryModel>> getCategories() async {
    await _loadCatalog();
    return _categories;
  }

  @override
  Future<List<EducationContentModel>> getContents() async {
    await _loadCatalog();
    return _contents;
  }

  @override
  Future<EducationContentModel> getDetail(String contentId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/modules/$contentId',
      );
      final data = _readData(response.data);
      return EducationContentModel.fromMap(data);
    } on DioException {
      return _fallbackDatasource.getDetail(contentId);
    } on EducationRemoteException {
      rethrow;
    } catch (error) {
      throw EducationRemoteException(error.toString());
    }
  }

  @override
  Future<List<UserEduProgressModel>> getProgress() async {
    await _loadCatalog();
    return _progress;
  }

  @override
  Future<UserEduProgressModel> completeContent(String contentId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/modules/$contentId/complete',
      );
      final data = _readData(response.data);
      return UserEduProgressModel.fromMap(data);
    } on DioException {
      return _fallbackDatasource.completeContent(contentId);
    } catch (error) {
      throw EducationRemoteException(error.toString());
    }
  }

  Future<void> _loadCatalog() async {
    if (_catalogLoad != null) {
      return _catalogLoad;
    }

    _catalogLoad = _fetchCatalog();
    try {
      await _catalogLoad;
    } finally {
      _catalogLoad = null;
    }
  }

  Future<void> _fetchCatalog() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/modules');
      final data = _readData(response.data);

      _categories = (data['categories'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(EducationCategoryModel.fromMap)
          .toList();
      _contents = (data['contents'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(EducationContentModel.fromMap)
          .toList();
      _progress = (data['progress'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(UserEduProgressModel.fromMap)
          .toList();
    } on DioException {
      _categories = await _fallbackDatasource.getCategories();
      _contents = await _fallbackDatasource.getContents();
      _progress = await _fallbackDatasource.getProgress();
    } catch (error) {
      throw EducationRemoteException(error.toString());
    }
  }

  Map<String, dynamic> _readData(Map<String, dynamic>? body) {
    if (body == null) {
      throw const EducationRemoteException('Backend modul kosong.');
    }

    if (body['success'] == false) {
      throw EducationRemoteException(
        body['message']?.toString() ?? 'Gagal mengambil modul.',
      );
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const EducationRemoteException('Format data modul tidak valid.');
    }

    return data;
  }
}

class LocalEducationRemoteDatasource implements EducationRemoteDatasource {
  LocalEducationRemoteDatasource();

  static const _categories = [
    {
      'id': 'cat-education',
      'name': 'Edukasi',
      'slug': 'education',
    },
    {
      'id': 'cat-tutorial',
      'name': 'Tutorial',
      'slug': 'tutorial',
    },
  ];

  static const _contents = [
    {
      'id': 'modul-1-toxoplasma-gondii',
      'category_id': 'cat-education',
      'category_slug': 'education',
      'title': 'Memahami Toksoplasma Gondii',
      'summary':
          'Pelajari apa itu Toksoplasma gondii dan alasan pemilik kucing perlu memahami risikonya.',
      'body':
          'Toksoplasma gondii adalah parasit yang dapat hidup di tubuh kucing dan lingkungan sekitarnya. Modul ini membantu kamu mengenali sumber risiko, cara penyebaran, dan kebiasaan sederhana untuk menjaga keluarga serta anabul tetap aman.',
      'thumbnail_asset': EducationAssets.moduleCat,
      'reward_points': 80,
      'duration_minutes': 6,
      'is_featured': true,
    },
    {
      'id': 'modul-2-risiko-ibu-hamil',
      'category_id': 'cat-education',
      'category_slug': 'education',
      'title': 'Risiko Toksoplasmosis untuk Kehamilan',
      'summary':
          'Pahami mengapa ibu hamil perlu lebih berhati-hati saat membersihkan kotak pasir.',
      'body':
          'Risiko toksoplasmosis dapat ditekan dengan kebiasaan higienis yang konsisten. Gunakan sarung tangan, minta bantuan anggota keluarga lain bila memungkinkan, dan selalu cuci tangan setelah kontak dengan pasir atau limbah anabul.',
      'thumbnail_asset': EducationAssets.moduleThinkingCat,
      'reward_points': 90,
      'duration_minutes': 8,
      'is_featured': false,
    },
    {
      'id': 'modul-3-penyebaran-kotoran-kucing',
      'category_id': 'cat-education',
      'category_slug': 'education',
      'title': 'Cara Penyebaran dari Limbah Kucing',
      'summary':
          'Kenali jalur paparan melalui pasir, tanah, dan permukaan yang tidak dibersihkan.',
      'body':
          'Paparan dapat terjadi ketika partikel dari limbah kucing terbawa ke tangan, alat pembersih, atau area rumah. Pisahkan alat kebersihan kotak pasir dari alat rumah tangga lain dan bersihkan area secara berkala.',
      'thumbnail_asset': EducationAssets.moduleCat,
      'reward_points': 75,
      'duration_minutes': 5,
      'is_featured': false,
    },
    {
      'id': 'modul-4-protokol-aman',
      'category_id': 'cat-tutorial',
      'category_slug': 'tutorial',
      'title': 'Membuang Limbah Kucing dengan Aman',
      'summary':
          'Ikuti langkah praktis untuk membungkus dan membuang limbah tanpa menyebarkan risiko.',
      'body':
          'Gunakan sekop khusus, masukkan limbah ke kantong tertutup, lalu buang ke tempat sampah yang sesuai. Setelah itu bersihkan sekop dan cuci tangan dengan sabun selama minimal dua puluh detik.',
      'thumbnail_asset': EducationAssets.moduleThinkingCat,
      'reward_points': 70,
      'duration_minutes': 7,
      'is_featured': true,
    },
    {
      'id': 'modul-5-hygiene-measures',
      'category_id': 'cat-tutorial',
      'category_slug': 'tutorial',
      'title': 'Rutinitas Higienis Harian',
      'summary':
          'Bangun kebiasaan sederhana untuk menurunkan risiko saat merawat kotak pasir.',
      'body':
          'Jadwalkan pembersihan kotak pasir, gunakan perlengkapan khusus, simpan pasir cadangan di tempat kering, dan pantau perubahan perilaku buang air anabul melalui ANABOOL.',
      'thumbnail_asset': EducationAssets.moduleCat,
      'reward_points': 85,
      'duration_minutes': 6,
      'is_featured': false,
    },
    {
      'id': 'modul-7-circular-economy',
      'category_id': 'cat-education',
      'category_slug': 'education',
      'title': 'Dari Limbah Menjadi Pupuk',
      'summary':
          'Lihat bagaimana pengelolaan limbah yang aman bisa mendukung ekonomi sirkular.',
      'body':
          'Pengelolaan limbah anabul membutuhkan proses terkontrol agar aman. Modul ini memperkenalkan konsep pemilahan, penanganan awal, dan peran layanan terjadwal dalam menciptakan sistem yang lebih bertanggung jawab.',
      'thumbnail_asset': EducationAssets.moduleThinkingCat,
      'reward_points': 100,
      'duration_minutes': 9,
      'is_featured': false,
    },
    {
      'id': 'modul-6-mitos-larangan',
      'category_id': 'cat-education',
      'category_slug': 'education',
      'title': 'Modul 6 Mitos, Larangan, dan Kesalahan Fatal',
      'summary':
          'Luruskan mitos umum tentang kucing, kehamilan, dan pencegahan toksoplasmosis.',
      'body':
          'Tidak semua larangan seputar kucing dan kehamilan akurat. Modul ini membantu membedakan mitos, kebiasaan yang benar-benar berisiko, dan tindakan pencegahan yang lebih aman untuk keluarga.',
      'thumbnail_asset': EducationAssets.moduleThinkingCat,
      'reward_points': 95,
      'duration_minutes': 8,
      'is_featured': false,
    },
  ];

  final Map<String, UserEduProgressModel> _progress = {
    'modul-1-toxoplasma-gondii': const UserEduProgressModel(
      contentId: 'modul-1-toxoplasma-gondii',
      progressPct: 72,
      isCompleted: false,
    ),
    'modul-4-protokol-aman': const UserEduProgressModel(
      contentId: 'modul-4-protokol-aman',
      progressPct: 38,
      isCompleted: false,
    ),
    'modul-3-penyebaran-kotoran-kucing': const UserEduProgressModel(
      contentId: 'modul-3-penyebaran-kotoran-kucing',
      progressPct: 100,
      isCompleted: true,
    ),
  };

  @override
  Future<List<EducationCategoryModel>> getCategories() async {
    return _categories.map(EducationCategoryModel.fromMap).toList();
  }

  @override
  Future<List<EducationContentModel>> getContents() async {
    return _contents.map(EducationContentModel.fromMap).toList();
  }

  @override
  Future<EducationContentModel> getDetail(String contentId) async {
    for (final content in _contents) {
      if (content['id'] == contentId) {
        return EducationContentModel.fromMap(content);
      }
    }

    throw const EducationRemoteException('Modul tidak ditemukan.');
  }

  @override
  Future<List<UserEduProgressModel>> getProgress() async {
    return List.unmodifiable(_progress.values);
  }

  @override
  Future<UserEduProgressModel> completeContent(String contentId) async {
    await getDetail(contentId);
    final completed = UserEduProgressModel(
      contentId: contentId,
      progressPct: 100,
      isCompleted: true,
    );
    _progress[contentId] = completed;
    return completed;
  }
}

class EducationRemoteException implements Exception {
  const EducationRemoteException(this.message);

  final String message;

  @override
  String toString() => message;
}
