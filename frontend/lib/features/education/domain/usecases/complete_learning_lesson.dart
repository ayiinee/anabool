import '../entities/user_edu_progress.dart';
import '../repositories/education_repository.dart';

class CompleteLearningLesson {
  const CompleteLearningLesson(this._repository);

  final EducationRepository _repository;

  Future<UserEduProgress> call(String contentId, String lessonId) {
    return _repository.completeLesson(contentId, lessonId);
  }
}
