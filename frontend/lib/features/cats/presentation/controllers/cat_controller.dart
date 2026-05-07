import 'package:flutter/foundation.dart';

import '../../data/datasources/cat_remote_datasource.dart';
import '../../data/repositories/cat_repository_impl.dart';
import '../../domain/entities/cat_activity.dart';
import '../../domain/entities/cat_profile.dart';
import '../../domain/repositories/cat_repository.dart';
import '../../domain/usecases/add_cat.dart';
import '../../domain/usecases/get_cats.dart';
import '../../domain/usecases/get_litter_box_status.dart';
import '../../domain/usecases/record_cat_activity.dart';
import '../../domain/usecases/update_cat.dart';

class CatController extends ChangeNotifier {
  CatController({
    required GetCats getCats,
    required AddCat addCat,
    required UpdateCat updateCat,
    required RecordCatActivity recordCatActivity,
    required GetLitterBoxStatus getLitterBoxStatus,
  })  : _getCats = getCats,
        _addCat = addCat,
        _updateCat = updateCat,
        _recordCatActivity = recordCatActivity,
        _getLitterBoxStatus = getLitterBoxStatus;

  factory CatController.create() {
    final repository = _sharedRepository;
    return CatController(
      getCats: GetCats(repository),
      addCat: AddCat(repository),
      updateCat: UpdateCat(repository),
      recordCatActivity: RecordCatActivity(repository),
      getLitterBoxStatus: GetLitterBoxStatus(repository),
    );
  }

  static final CatRepository _sharedRepository = CatRepositoryImpl(
    remoteDatasource: LocalCatRemoteDatasource(),
  );

  final GetCats _getCats;
  final AddCat _addCat;
  final UpdateCat _updateCat;
  final RecordCatActivity _recordCatActivity;
  final GetLitterBoxStatus _getLitterBoxStatus;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  List<CatProfile> cats = const [];

  CatProfile? findCat(String catId) {
    for (final profile in cats) {
      if (profile.cat.id == catId) {
        return profile;
      }
    }

    return null;
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      cats = await _getCats();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCat(AddCatInput input) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _addCat(input);
      cats = await _getCats();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateCat(CatProfile profile) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _updateCat(profile);
      cats = await _getCats();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> recordActivity({
    required String catId,
    required CatActivityType type,
    String? notes,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _recordCatActivity(catId: catId, type: type, notes: notes);
      cats = await _getCats();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> refreshLitterStatus(String litterBoxId) async {
    try {
      await _getLitterBoxStatus(litterBoxId);
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }
}
