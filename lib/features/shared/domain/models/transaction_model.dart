class TransactionModel {
  final String id;
  final String sharkId;
  final String proponentId;
  final String ideaName;
  final double investmentValue;
  final double equityPercentage;

  // Máquina de Estados e Contraproposta
  final String
  status; // 'pending_proponent', 'counter_offered', 'accepted', 'rejected'
  final double? counterValue;
  final double? counterEquity;

  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.sharkId,
    required this.proponentId,
    required this.ideaName,
    required this.investmentValue,
    required this.equityPercentage,
    required this.status,
    this.counterValue,
    this.counterEquity,
    required this.timestamp,
  });

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      sharkId: map['sharkId'] ?? '',
      proponentId: map['proponentId'] ?? '',
      ideaName: map['ideaName'] ?? '',
      investmentValue: map['investmentValue']?.toDouble() ?? 0.0,
      equityPercentage: map['equityPercentage']?.toDouble() ?? 0.0,
      // Se não tiver status no antigo db, já foi 'accepted'
      status: map['status'] ?? 'accepted',
      counterValue: map['counterValue']?.toDouble(),
      counterEquity: map['counterEquity']?.toDouble(),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sharkId': sharkId,
      'proponentId': proponentId,
      'ideaName': ideaName,
      'investmentValue': investmentValue,
      'equityPercentage': equityPercentage,
      'status': status,
      if (counterValue != null) 'counterValue': counterValue,
      if (counterEquity != null) 'counterEquity': counterEquity,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
