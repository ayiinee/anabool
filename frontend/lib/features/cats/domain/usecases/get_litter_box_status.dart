import '../entities/litter_box.dart';
import '../repositories/cat_repository.dart';

class GetLitterBoxStatus {
  const GetLitterBoxStatus(this._repository);

  final CatRepository _repository;

  Future<LitterBoxStatus> call(String litterBoxId) {
    return _repository.getLitterBoxStatus(litterBoxId);
  }
}
