import '../../domain/entities/education_category.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/entities/user_edu_progress.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_remote_datasource.dart';

class EducationRepositoryImpl implements EducationRepository {
  const EducationRepositoryImpl({
    required EducationRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final EducationRemoteDatasource _remoteDatasource;

  @override
  Future<List<EducationCategory>> getCategories() {
    return _remoteDatasource.getCategories();
  }

  @override
  Future<List<EducationContent>> getContents() {
    return _remoteDatasource.getContents();
  }

  @override
  Future<EducationContent> getDetail(String contentId) {
    return _remoteDatasource.getDetail(contentId);
  }

  @override
  Future<List<UserEduProgress>> getProgress() {
    return _remoteDatasource.getProgress();
  }

  @override
  Future<UserEduProgress> completeContent(String contentId) {
    return _remoteDatasource.completeContent(contentId);
  }
}
