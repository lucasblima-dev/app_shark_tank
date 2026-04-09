class UserModel {
  final String id;
  final String name;
  final String role;
  final double? availableCapital;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.availableCapital,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      role: map['role'] ?? 'proponent',
      availableCapital: map['availableCapital']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      if (availableCapital != null) 'availableCapital': availableCapital,
    };
  }
}
