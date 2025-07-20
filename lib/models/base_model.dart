abstract class IModel {
  final String id;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  IModel({
    required this.id,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson();
}

abstract class IModelInput {
  final String? id;
  final bool isActive;

  IModelInput({
    this.id,
    required this.isActive,
  });

  Map<String, dynamic> toJson();
}
