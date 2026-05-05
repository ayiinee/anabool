import '../entities/education_content.dart';
import '../repositories/education_repository.dart';

class GetEducationDetail {
  const GetEducationDetail(this._repository);

  final EducationRepository _repository;

  Future<EducationContent> call(String contentId) {
    return _repository.getDetail(contentId);
  }
}
