import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../shared/domain/models/transaction_model.dart';
//import '../../../shared/domain/models/user_model.dart';

class InvestmentController extends StateNotifier<AsyncValue<void>> {
  InvestmentController() : super(const AsyncValue.data(null));

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> makeInvestment({
    required String sharkId,
    required String proponentId,
    required String ideaName,
    required double value,
    required double equity,
  }) async {
    state = const AsyncValue.loading();
    try {
      final sharkRef = _firestore.collection('users').doc(sharkId);
      final transactionRef = _firestore.collection('transactions').doc();

      await _firestore.runTransaction((tx) async {
        final sharkDoc = await tx.get(sharkRef);
        final currentAvail =
            sharkDoc.data()?['availableCapital']?.toDouble() ?? 0.0;
        final currentReserved =
            sharkDoc.data()?['reservedCapital']?.toDouble() ?? 0.0;

        if (currentAvail < value) throw Exception('Saldo insuficiente.');

        tx.update(sharkRef, {
          'availableCapital': currentAvail - value,
          'reservedCapital': currentReserved + value,
        });

        final newTransaction = TransactionModel(
          id: '',
          sharkId: sharkId,
          proponentId: proponentId,
          ideaName: ideaName,
          investmentValue: value,
          equityPercentage: equity,
          status: 'pending_proponent',
          timestamp: DateTime.now(),
        );

        tx.set(transactionRef, newTransaction.toMap());
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acceptCounterOffer(TransactionModel t) async {
    state = const AsyncValue.loading();
    try {
      final sharkRef = _firestore.collection('users').doc(t.sharkId);
      final propRef = _firestore.collection('users').doc(t.proponentId);
      final tRef = _firestore.collection('transactions').doc(t.id);

      await _firestore.runTransaction((tx) async {
        final sharkDoc = await tx.get(sharkRef);
        final propDoc = await tx.get(propRef);

        final avail = sharkDoc.data()?['availableCapital']?.toDouble() ?? 0.0;
        final reserved = sharkDoc.data()?['reservedCapital']?.toDouble() ?? 0.0;
        final currentPropEquity =
            propDoc.data()?['equityGiven']?.toDouble() ?? 0.0;

        final diff = t.counterValue! - t.investmentValue;
        if (avail < diff) {
          throw Exception(
            'Você não tem saldo livre para cobrir a contraproposta.',
          );
        }
        if (currentPropEquity + t.counterEquity! > 49.0) {
          throw Exception('A startup estourou o limite de 49%.');
        }

        tx.update(sharkRef, {
          'availableCapital': avail - diff,
          'reservedCapital': reserved - t.investmentValue,
        });

        tx.update(propRef, {
          'equityGiven': currentPropEquity + t.counterEquity!,
        });
        tx.update(tRef, {
          'status': 'accepted',
          'investmentValue': t.counterValue,
          'equityPercentage': t.counterEquity,
        });
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectCounterOffer(TransactionModel t) async {
    state = const AsyncValue.loading();
    try {
      final sharkRef = _firestore.collection('users').doc(t.sharkId);
      final tRef = _firestore.collection('transactions').doc(t.id);

      await _firestore.runTransaction((tx) async {
        final sharkDoc = await tx.get(sharkRef);
        final avail = sharkDoc.data()?['availableCapital']?.toDouble() ?? 0.0;
        final reserved = sharkDoc.data()?['reservedCapital']?.toDouble() ?? 0.0;

        tx.update(sharkRef, {
          'availableCapital': avail + t.investmentValue,
          'reservedCapital': reserved - t.investmentValue,
        });

        tx.update(tRef, {'status': 'rejected'});
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final investmentControllerProvider =
    StateNotifierProvider<InvestmentController, AsyncValue<void>>((ref) {
      return InvestmentController();
    });
