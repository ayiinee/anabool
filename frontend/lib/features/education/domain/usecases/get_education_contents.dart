import '../entities/education_category.dart';
import '../entities/education_content.dart';
import '../entities/user_edu_progress.dart';
import '../repositories/education_repository.dart';

class EducationCatalog {
  const EducationCatalog({
    required this.categories,
    required this.contents,
    required this.progress,
  });

  final List<EducationCategory> categories;
  final List<EducationContent> contents;
  final List<UserEduProgress> progress;
}

class GetEducationContents {
  const GetEducationContents(this._repository);

  final EducationRepository _repository;

  Future<EducationCatalog> call() async {
    final results = await Future.wait([
      _repository.getCategories(),
      _repository.getContents(),
      _repository.getProgress(),
    ]);

    return EducationCatalog(
      categories: results[0] as List<EducationCategory>,
      contents: results[1] as List<EducationContent>,
      progress: results[2] as List<UserEduProgress>,
    );
  }
}
