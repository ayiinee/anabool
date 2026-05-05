import '../../domain/entities/education_category.dart';

class EducationCategoryModel extends EducationCategory {
  const EducationCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory EducationCategoryModel.fromMap(Map<String, dynamic> map) {
    return EducationCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      slug: map['slug'] as String,
    );
  }
}
