import '../entities/cat_profile.dart';
import '../repositories/cat_repository.dart';

class UpdateCat {
  const UpdateCat(this._repository);

  final CatRepository _repository;

  Future<CatProfile> call(CatProfile profile) {
    return _repository.updateCat(profile);
  }
}
