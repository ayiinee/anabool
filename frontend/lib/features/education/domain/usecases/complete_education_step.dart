import '../entities/user_edu_progress.dart';
import '../repositories/education_repository.dart';

class CompleteEducationStep {
  const CompleteEducationStep(this._repository);

  final EducationRepository _repository;

  Future<UserEduProgress> call(String contentId, String stepId) {
    return _repository.completeStep(contentId, stepId);
  }
}
