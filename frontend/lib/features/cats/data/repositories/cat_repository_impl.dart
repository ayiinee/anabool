import '../../domain/entities/cat_activity.dart';
import '../../domain/entities/cat_profile.dart';
import '../../domain/entities/litter_box.dart';
import '../../domain/repositories/cat_repository.dart';
import '../datasources/cat_remote_datasource.dart';

class CatRepositoryImpl implements CatRepository {
  const CatRepositoryImpl({
    required CatRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final CatRemoteDatasource _remoteDatasource;

  @override
  Future<List<CatProfile>> getCats() {
    return _remoteDatasource.getCats();
  }

  @override
  Future<CatProfile> addCat(AddCatInput input) {
    return _remoteDatasource.addCat(input);
  }

  @override
  Future<CatProfile> updateCat(CatProfile profile) {
    return _remoteDatasource.updateCat(profile);
  }

  @override
  Future<CatActivity> recordCatActivity({
    required String catId,
    required CatActivityType type,
    String? notes,
  }) {
    return _remoteDatasource.recordCatActivity(
      catId: catId,
      type: type,
      notes: notes,
    );
  }

  @override
  Future<LitterBoxStatus> getLitterBoxStatus(String litterBoxId) {
    return _remoteDatasource.getLitterBoxStatus(litterBoxId);
  }
}
