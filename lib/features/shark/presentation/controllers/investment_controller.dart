import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../shared/data/shared_providers.dart';
import '../../../shared/domain/models/transaction_model.dart';

class InvestmentController extends StateNotifier<AsyncValue<void>> {
  InvestmentController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> makeInvestment({
    required String sharkId,
    required String proponentId,
    required String ideaName,
    required double value,
    required double equity,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(transactionRepositoryProvider);

      final newTransaction = TransactionModel(
        id: '', // id gerado automaticamente
        sharkId: sharkId,
        proponentId: proponentId,
        ideaName: ideaName,
        investmentValue: value,
        equityPercentage: equity,
        timestamp: DateTime.now(),
      );

      await repository.processInvestment(newTransaction);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final investmentControllerProvider =
    StateNotifierProvider<InvestmentController, AsyncValue<void>>((ref) {
      return InvestmentController(ref);
    });
