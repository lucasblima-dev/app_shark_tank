import 'package:app_shark_tank/features/admin/presentation/widgets/transactions_timeline_dialog.dart';
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
          'Apagar Histórico?',
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: const Text(
          'Isso apenas remove o log da tela. O dinheiro NÃO será devolvido automaticamente.',
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

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    String label;

    switch (status) {
      case 'accepted':
        bgColor = AppColors.emerald;
        label = 'Fechado';
        break;
      case 'rejected':
        bgColor = AppColors.error;
        label = 'Recusado';
        break;
      case 'counter_offered':
        bgColor = Colors.orangeAccent;
        label = 'Contraproposta';
        break;
      case 'pending_proponent':
      default:
        bgColor = AppColors.gold;
        label = 'Pendente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bgColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bgColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
              'Nenhuma transação no sistema.',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => TransactionTimelineDialog(t: t),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.ideaName,
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${t.sharkId} -> ${t.proponentId}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildStatusBadge(t.status),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${t.investmentValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.emerald,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${t.equityPercentage}%',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
