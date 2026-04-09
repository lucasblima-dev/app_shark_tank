import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/transaction_model.dart';
import '../domain/models/user_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> processInvestment(TransactionModel transaction) async {
    final sharkRef = _firestore.collection('users').doc(transaction.sharkId);
    final transactionRef = _firestore.collection('transactions').doc();

    try {
      await _firestore.runTransaction((tx) async {
        final sharkSnapshot = await tx.get(sharkRef);

        if (!sharkSnapshot.exists) {
          throw Exception('Shark não encontrado no sistema.');
        }

        final sharkData = UserModel.fromMap(
          sharkSnapshot.data()!,
          sharkSnapshot.id,
        );
        final currentCapital = sharkData.availableCapital ?? 0.0;

        if (currentCapital < transaction.investmentValue) {
          throw Exception('Operação negada: Saldo insuficiente.');
        }

        if (transaction.equityPercentage <= 0 ||
            transaction.equityPercentage > 100) {
          throw Exception('A porcentagem de equity deve estar entre 1 e 100.');
        }

        final newCapital = currentCapital - transaction.investmentValue;

        tx.update(sharkRef, {'availableCapital': newCapital});

        tx.set(transactionRef, transaction.toMap());
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<TransactionModel>> watchAllTransactions() {
    return _firestore
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
