import '../../../../core/auth/current_user_identity.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../domain/entities/cat_activity.dart';
import '../../domain/entities/cat_profile.dart';
import '../../domain/entities/litter_box.dart';
import '../../domain/repositories/cat_repository.dart';
import '../models/cat_activity_model.dart';
import '../models/cat_model.dart';
import '../models/litter_box_model.dart';

abstract class CatRemoteDatasource {
  Future<List<CatProfile>> getCats();

  Future<CatProfile> addCat(AddCatInput input);

  Future<CatProfile> updateCat(CatProfile profile);

  Future<CatActivity> recordCatActivity({
    required String catId,
    required CatActivityType type,
    String? notes,
  });

  Future<LitterBoxStatus> getLitterBoxStatus(String litterBoxId);
}

class LocalCatRemoteDatasource implements CatRemoteDatasource {
  LocalCatRemoteDatasource() {
    if (_profiles.isEmpty) {
      _profiles.addAll(_seedProfiles());
    }
  }

  static final List<CatProfile> _profiles = [];

  @override
  Future<List<CatProfile>> getCats() async {
    return List<CatProfile>.unmodifiable(_profiles);
  }

  @override
  Future<CatProfile> addCat(AddCatInput input) async {
    final now = DateTime.now();
    final id = 'cat-${now.microsecondsSinceEpoch}';
    final userId = CurrentUserIdentity.userId();
    final cat = CatModel(
      id: id,
      ownerId: userId,
      name: input.name.trim(),
      breed: input.breed.trim(),
      lifeStage: input.lifeStage,
      gender: input.gender,
      avatarAsset: CatAssets.personalizationMascot,
      peeFrequencyPerDay: input.peeFrequencyPerDay,
      poopFrequencyPerDay: input.poopFrequencyPerDay,
      healthNotes: input.healthNotes.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final litterBox = LitterBoxModel(
      id: 'box-${now.microsecondsSinceEpoch}',
      userId: userId,
      catId: id,
      locationLabel: input.locationLabel.trim(),
      boxType: input.boxType,
      litterType: input.litterType,
      boxCount: input.boxCount,
      cleaningFrequency: input.cleaningFrequency,
      lastCleanedLabel: input.lastCleanedLabel,
      status: _statusFromLastCleaned(input.lastCleanedLabel),
      lastCleanedAt: _lastCleanedAt(input.lastCleanedLabel, now),
      createdAt: now,
      updatedAt: now,
    );
    final profile = CatProfile(
      cat: cat,
      litterBox: litterBox,
      activities: [
        CatActivityModel(
          id: 'activity-${now.microsecondsSinceEpoch}',
          catId: id,
          litterBoxId: litterBox.id,
          type: CatActivityType.note,
          notes: 'Profil kucing dibuat',
          recordedAt: now,
          createdAt: now,
        ),
      ],
      status: LitterBoxStatus(
        cleanlinessStatus: litterBox.status,
        peeCount: input.peeFrequencyPerDay,
        poopCount: input.poopFrequencyPerDay,
        alertMessage: litterBox.status == 'Perlu dibersihkan'
            ? 'Kotak pasir sudah lama belum dibersihkan.'
            : null,
        abnormalPatternDetected: false,
      ),
    );

    _profiles.add(profile);
    return profile;
  }

  @override
  Future<CatProfile> updateCat(CatProfile profile) async {
    final index = _profiles.indexWhere((item) => item.cat.id == profile.cat.id);
    if (index == -1) {
      throw Exception('Profil kucing tidak ditemukan.');
    }

    _profiles[index] = profile;
    return profile;
  }

  @override
  Future<CatActivity> recordCatActivity({
    required String catId,
    required CatActivityType type,
    String? notes,
  }) async {
    final index = _profiles.indexWhere((item) => item.cat.id == catId);
    if (index == -1) {
      throw Exception('Profil kucing tidak ditemukan.');
    }

    final profile = _profiles[index];
    final now = DateTime.now();
    final activity = CatActivityModel(
      id: 'activity-${now.microsecondsSinceEpoch}',
      catId: catId,
      litterBoxId: profile.litterBox.id,
      type: type,
      notes: notes?.trim() ?? '',
      recordedAt: now,
      createdAt: now,
    );
    final activities = [activity, ...profile.activities];
    final peeCount = type == CatActivityType.pee
        ? profile.status.peeCount + 1
        : profile.status.peeCount;
    final poopCount = type == CatActivityType.poop
        ? profile.status.poopCount + 1
        : profile.status.poopCount;
    final nextStatus = type == CatActivityType.clean
        ? const LitterBoxStatus(
            cleanlinessStatus: 'Bersih',
            peeCount: 0,
            poopCount: 0,
            alertMessage: null,
            abnormalPatternDetected: false,
          )
        : LitterBoxStatus(
            cleanlinessStatus: profile.status.cleanlinessStatus,
            peeCount: peeCount,
            poopCount: poopCount,
            alertMessage: profile.status.alertMessage,
            abnormalPatternDetected: false,
          );

    _profiles[index] = CatProfile(
      cat: profile.cat,
      litterBox: profile.litterBox,
      activities: activities,
      status: nextStatus,
    );

    return activity;
  }

  @override
  Future<LitterBoxStatus> getLitterBoxStatus(String litterBoxId) async {
    for (final profile in _profiles) {
      if (profile.litterBox.id == litterBoxId) {
        return profile.status;
      }
    }

    throw Exception('Status litter box tidak ditemukan.');
  }

  static List<CatProfile> _seedProfiles() {
    final now = DateTime.now();
    final userId = CurrentUserIdentity.userId();
    return [
      _profile(
        id: 'gamora',
        userId: userId,
        name: 'Gamora',
        breed: 'Domestic Short Hair',
        lifeStage: 'Dewasa',
        gender: 'Betina',
        avatarAsset: HomeAssets.gamoraCat,
        peeFrequency: 4,
        poopFrequency: 2,
        boxType: 'Bak tertutup',
        litterType: 'Bentonite/Pasir Gumpal',
        boxCount: 1,
        location: 'Kamar mandi',
        cleaningFrequency: 'Sekali sehari',
        lastCleanedLabel: 'Hari ini',
        status: 'Normal',
        now: now,
      ),
      _profile(
        id: 'charlotte',
        userId: userId,
        name: 'Charlotte',
        breed: 'Persia Mix',
        lifeStage: 'Dewasa',
        gender: 'Betina',
        avatarAsset: HomeAssets.charlotteCat,
        peeFrequency: 4,
        poopFrequency: 2,
        boxType: 'Bak terbuka',
        litterType: 'Tofu',
        boxCount: 1,
        location: 'Balkon',
        cleaningFrequency: 'Sekali sehari',
        lastCleanedLabel: 'Kemarin',
        status: 'Perlu dicek',
        now: now,
      ),
    ];
  }

  static CatProfile _profile({
    required String id,
    required String userId,
    required String name,
    required String breed,
    required String lifeStage,
    required String gender,
    required String avatarAsset,
    required int peeFrequency,
    required int poopFrequency,
    required String boxType,
    required String litterType,
    required int boxCount,
    required String location,
    required String cleaningFrequency,
    required String lastCleanedLabel,
    required String status,
    required DateTime now,
  }) {
    final cat = CatModel(
      id: id,
      ownerId: userId,
      name: name,
      breed: breed,
      lifeStage: lifeStage,
      gender: gender,
      avatarAsset: avatarAsset,
      peeFrequencyPerDay: peeFrequency,
      poopFrequencyPerDay: poopFrequency,
      healthNotes: '',
      createdAt: now,
      updatedAt: now,
    );
    final litterBox = LitterBoxModel(
      id: 'box-$id',
      userId: userId,
      catId: id,
      locationLabel: location,
      boxType: boxType,
      litterType: litterType,
      boxCount: boxCount,
      cleaningFrequency: cleaningFrequency,
      lastCleanedLabel: lastCleanedLabel,
      status: status,
      lastCleanedAt: _lastCleanedAt(lastCleanedLabel, now),
      createdAt: now,
      updatedAt: now,
    );

    return CatProfile(
      cat: cat,
      litterBox: litterBox,
      activities: [
        CatActivityModel(
          id: 'activity-$id-clean',
          catId: id,
          litterBoxId: litterBox.id,
          type: CatActivityType.clean,
          notes: 'Kotak pasir dibersihkan',
          recordedAt: now.subtract(const Duration(hours: 3)),
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        CatActivityModel(
          id: 'activity-$id-poop',
          catId: id,
          litterBoxId: litterBox.id,
          type: CatActivityType.poop,
          notes: 'Rutinitas normal',
          recordedAt: now.subtract(const Duration(hours: 6)),
          createdAt: now.subtract(const Duration(hours: 6)),
        ),
      ],
      status: LitterBoxStatus(
        cleanlinessStatus: status,
        peeCount: peeFrequency,
        poopCount: poopFrequency,
        alertMessage:
            status == 'Perlu dicek' ? 'Jadwalkan pembersihan sore ini.' : null,
        abnormalPatternDetected: false,
      ),
    );
  }

  static DateTime? _lastCleanedAt(String label, DateTime now) {
    switch (label) {
      case 'Hari ini':
        return now;
      case 'Kemarin':
        return now.subtract(const Duration(days: 1));
      case 'Dua hari lalu':
        return now.subtract(const Duration(days: 2));
      case 'Lebih dari dua hari':
        return now.subtract(const Duration(days: 3));
      default:
        return null;
    }
  }

  static String _statusFromLastCleaned(String label) {
    switch (label) {
      case 'Hari ini':
        return 'Bersih';
      case 'Kemarin':
        return 'Normal';
      case 'Dua hari lalu':
        return 'Perlu dicek';
      case 'Lebih dari dua hari':
        return 'Perlu dibersihkan';
      default:
        return 'Normal';
    }
  }
}
