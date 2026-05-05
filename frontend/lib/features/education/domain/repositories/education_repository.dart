import '../entities/education_category.dart';
import '../entities/education_content.dart';
import '../entities/user_edu_progress.dart';

abstract class EducationRepository {
  Future<List<EducationCategory>> getCategories();
  Future<List<EducationContent>> getContents();
  Future<EducationContent> getDetail(String contentId);
  Future<UserEduProgress> completeContent(String contentId);
  Future<List<UserEduProgress>> getProgress();
}
