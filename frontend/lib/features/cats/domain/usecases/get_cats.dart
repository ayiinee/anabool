import '../entities/cat_profile.dart';
import '../repositories/cat_repository.dart';

class GetCats {
  const GetCats(this._repository);

  final CatRepository _repository;

  Future<List<CatProfile>> call() {
    return _repository.getCats();
  }
}
