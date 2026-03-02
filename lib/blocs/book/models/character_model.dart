class CharacterModel {
  final String name;
  final String description;

  CharacterModel({required this.name, required this.description});
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': DateTime.now(),
    };
  }

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
