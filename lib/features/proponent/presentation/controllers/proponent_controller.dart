import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../shared/domain/models/transaction_model.dart';
import '../../../shared/domain/models/user_model.dart';

class ProponentController extends StateNotifier<AsyncValue<void>> {
  ProponentController() : super(const AsyncValue.data(null));

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateIdeaName(String userId, String newName) async {
    await _firestore.collection('users').doc(userId).update({
      'ideaName': newName,
    });
  }

  Future<void> acceptProposal(TransactionModel t, UserModel proponent) async {
    state = const AsyncValue.loading();
    try {
      final sharkRef = _firestore.collection('users').doc(t.sharkId);
      final propRef = _firestore.collection('users').doc(proponent.id);
      final tRef = _firestore.collection('transactions').doc(t.id);

      await _firestore.runTransaction((tx) async {
        // Verifica limite de 49% do Proponente
        final propDoc = await tx.get(propRef);
        final currentEquity = propDoc.data()?['equityGiven']?.toDouble() ?? 0.0;

        if (currentEquity + t.equityPercentage > 49.0) {
          throw Exception('Você não pode ceder mais que 49% da empresa.');
        }

        final sharkDoc = await tx.get(sharkRef);
        if (sharkDoc.exists) {
          final currentReserved =
              sharkDoc.data()?['reservedCapital']?.toDouble() ?? 0.0;
          tx.update(sharkRef, {
            'reservedCapital': currentReserved - t.investmentValue,
          });
        }

        tx.update(propRef, {'equityGiven': currentEquity + t.equityPercentage});
        tx.update(tRef, {'status': 'accepted'});
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectProposal(TransactionModel t) async {
    state = const AsyncValue.loading();
    try {
      final sharkRef = _firestore.collection('users').doc(t.sharkId);
      final tRef = _firestore.collection('transactions').doc(t.id);

      await _firestore.runTransaction((tx) async {
        final sharkDoc = await tx.get(sharkRef);
        if (sharkDoc.exists) {
          final currentAvail =
              sharkDoc.data()?['availableCapital']?.toDouble() ?? 0.0;
          final currentReserved =
              sharkDoc.data()?['reservedCapital']?.toDouble() ?? 0.0;

          tx.update(sharkRef, {
            'availableCapital': currentAvail + t.investmentValue,
            'reservedCapital': currentReserved - t.investmentValue,
          });
        }
        tx.update(tRef, {'status': 'rejected'});
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> counterProposal(
    TransactionModel t,
    double newVal,
    double newEq,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('transactions').doc(t.id).update({
        'status': 'counter_offered',
        'counterValue': newVal,
        'counterEquity': newEq,
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final proponentControllerProvider =
    StateNotifierProvider<ProponentController, AsyncValue<void>>((ref) {
      return ProponentController();
    });
