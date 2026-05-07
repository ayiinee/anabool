import 'cat.dart';
import 'cat_activity.dart';
import 'litter_box.dart';

class CatProfile {
  const CatProfile({
    required this.cat,
    required this.litterBox,
    required this.activities,
    required this.status,
  });

  final Cat cat;
  final LitterBox litterBox;
  final List<CatActivity> activities;
  final LitterBoxStatus status;
}
