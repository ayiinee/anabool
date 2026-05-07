import '../entities/cat_activity.dart';
import '../repositories/cat_repository.dart';

class RecordCatActivity {
  const RecordCatActivity(this._repository);

  final CatRepository _repository;

  Future<CatActivity> call({
    required String catId,
    required CatActivityType type,
    String? notes,
  }) {
    return _repository.recordCatActivity(
      catId: catId,
      type: type,
      notes: notes,
    );
  }
}
