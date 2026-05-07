import '../entities/learning_module.dart';
import '../repositories/education_repository.dart';

class GetLearningModule {
  const GetLearningModule(this._repository);

  final EducationRepository _repository;

  Future<LearningModule> call(String contentId) {
    return _repository.getLearningModule(contentId);
  }
}
