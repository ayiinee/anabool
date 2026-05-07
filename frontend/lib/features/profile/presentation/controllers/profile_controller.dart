import 'package:flutter/foundation.dart';

import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_address.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/manage_address.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/update_safety_mode.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required UpdateSafetyMode updateSafetyMode,
    required ManageAddress manageAddress,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _updateSafetyMode = updateSafetyMode,
        _manageAddress = manageAddress;

  factory ProfileController.create() {
    final repository = _sharedRepository;
    return ProfileController(
      getProfile: GetProfile(repository),
      updateProfile: UpdateProfile(repository),
      updateSafetyMode: UpdateSafetyMode(repository),
      manageAddress: ManageAddress(repository),
    );
  }

  static final ProfileRepository _sharedRepository = ProfileRepositoryImpl(
    remoteDatasource: LocalProfileRemoteDatasource(),
  );

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final UpdateSafetyMode _updateSafetyMode;
  final ManageAddress _manageAddress;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  UserProfile? profile;

  Future<void> load({bool force = false}) async {
    if (isLoading || (profile != null && !force)) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _getProfile();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required String location,
  }) async {
    final current = profile;
    if (current == null) {
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _updateProfile(
        current.copyWith(
          name: name.trim(),
          email: email.trim(),
          phoneNumber: phoneNumber.trim(),
          location: location.trim(),
        ),
      );
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> setSafetyMode(bool enabled) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _updateSafetyMode(enabled);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveAddress(UserAddress address) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _manageAddress.save(address);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _manageAddress.delete(addressId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
