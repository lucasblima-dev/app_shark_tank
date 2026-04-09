import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchAllTransactions();
});
