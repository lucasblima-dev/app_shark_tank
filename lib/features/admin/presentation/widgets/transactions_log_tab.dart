import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/shared_providers.dart';

class TransactionsLogTab extends ConsumerWidget {
  const TransactionsLogTab({super.key});

  void _deleteTransaction(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: const Text(
          'Desfazer Transação',
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: const Text(
          'Apagar este log NÃO devolverá o saldo ao Shark automaticamente.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Apagar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return transactionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      ),
      error: (e, stack) => Center(
        child: Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma transação.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final t = transactions[index];
            return Card(
              color: AppColors.backgroundLight,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  '${t.ideaName} (${t.equityPercentage}%)',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${t.sharkId} -> ${t.proponentId}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${t.investmentValue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.emerald,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      onPressed: () => _deleteTransaction(context, t.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
