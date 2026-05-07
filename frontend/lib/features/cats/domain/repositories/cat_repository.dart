import '../entities/cat_activity.dart';
import '../entities/cat_profile.dart';
import '../entities/litter_box.dart';

class AddCatInput {
  const AddCatInput({
    required this.name,
    required this.breed,
    required this.lifeStage,
    required this.gender,
    required this.boxType,
    required this.litterType,
    required this.boxCount,
    required this.locationLabel,
    required this.peeFrequencyPerDay,
    required this.poopFrequencyPerDay,
    required this.cleaningFrequency,
    required this.lastCleanedLabel,
    required this.healthNotes,
  });

  final String name;
  final String breed;
  final String lifeStage;
  final String gender;
  final String boxType;
  final String litterType;
  final int boxCount;
  final String locationLabel;
  final int peeFrequencyPerDay;
  final int poopFrequencyPerDay;
  final String cleaningFrequency;
  final String lastCleanedLabel;
  final String healthNotes;
}

abstract class CatRepository {
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
