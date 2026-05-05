import '../../../../core/constants/asset_constants.dart';
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
      'id': 'toxoplasma-basic',
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
      'id': 'pregnancy-risk',
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
      'id': 'cat-waste-spread',
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
      'id': 'safe-disposal',
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
      'id': 'hygiene-routine',
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
      'id': 'fertilizer-cycle',
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
  ];

  final Map<String, UserEduProgressModel> _progress = {
    'toxoplasma-basic': const UserEduProgressModel(
      contentId: 'toxoplasma-basic',
      progressPct: 72,
      isCompleted: false,
    ),
    'safe-disposal': const UserEduProgressModel(
      contentId: 'safe-disposal',
      progressPct: 38,
      isCompleted: false,
    ),
    'cat-waste-spread': const UserEduProgressModel(
      contentId: 'cat-waste-spread',
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
