import '../entities/cat_profile.dart';
import '../repositories/cat_repository.dart';

class AddCat {
  const AddCat(this._repository);

  final CatRepository _repository;

  Future<CatProfile> call(AddCatInput input) {
    return _repository.addCat(input);
  }
}
