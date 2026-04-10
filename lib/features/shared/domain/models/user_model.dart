class UserModel {
  final String id;
  final String name;
  final String role;

  // Específico do Shark
  final double? availableCapital;
  final double? reservedCapital; //Dinheiro Fantasma (preso em propostas)

  // Específico do Proponente
  final String? ideaName;
  final double? equityGiven; //Porcentagem já vendida (máximo 49%)

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.availableCapital,
    this.reservedCapital,
    this.ideaName,
    this.equityGiven,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      role: map['role'] ?? 'proponent',
      availableCapital: map['availableCapital']?.toDouble(),
      reservedCapital: map['reservedCapital']?.toDouble() ?? 0.0,
      ideaName: map['ideaName'],
      equityGiven: map['equityGiven']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      if (availableCapital != null) 'availableCapital': availableCapital,
      if (reservedCapital != null) 'reservedCapital': reservedCapital,
      if (ideaName != null) 'ideaName': ideaName,
      if (equityGiven != null) 'equityGiven': equityGiven,
    };
  }
}
