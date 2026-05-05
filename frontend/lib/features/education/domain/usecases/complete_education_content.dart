import '../entities/user_edu_progress.dart';
import '../repositories/education_repository.dart';

class CompleteEducationContent {
  const CompleteEducationContent(this._repository);

  final EducationRepository _repository;

  Future<UserEduProgress> call(String contentId) {
    return _repository.completeContent(contentId);
  }
}
