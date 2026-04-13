import 'package:app_shark_tank/features/admin/presentation/widgets/transactions_timeline_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/shared_providers.dart';
import '../../../shared/domain/models/user_model.dart';

class TransactionsLogTab extends ConsumerWidget {
  const TransactionsLogTab({super.key});

  void _deleteTransaction(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: const Text(
          'REMOVER REGISTRO',
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Esta ação remove apenas o log visual. O capital investido não será estornado automaticamente.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'REMOVER',
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
    Color color;
    String label;

    switch (status) {
      case 'accepted':
        color = AppColors.emerald;
        label = 'FECHADO';
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'RECUSADO';
        break;
      case 'counter_offered':
        color = Colors.orangeAccent;
        label = 'CONTRAPROPOSTA';
        break;
      default:
        color = AppColors.gold;
        label = 'PENDENTE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final usersAsync = ref.watch(usersStreamProvider);

    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

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
              'SEM ATIVIDADE NO MOMENTO',
              style: TextStyle(color: AppColors.textMuted, letterSpacing: 2),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final t = transactions[index];
            final statusColor = _getStatusColor(t.status);

            // Buscamos apenas o nome real do Shark.
            // Para a Startup, usaremos o 'ideaName' que já está na transação.
            String sharkRealName = t.sharkId;

            usersAsync.whenData((users) {
              sharkRealName = users
                  .firstWhere(
                    (u) => u.id == t.sharkId,
                    orElse: () => UserModel(
                      id: t.sharkId,
                      name: t.sharkId,
                      role: 'shark',
                    ),
                  )
                  .name;
            });

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: statusColor, width: 4)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => TransactionTimelineDialog(t: t),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.swap_horiz_outlined,
                          color: statusColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.ideaName.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // FLUXO: NOME DO SHARK -> NOME DA STARTUP (ideaName)
                            Row(
                              children: [
                                Text(
                                  sharkRealName,
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: Icon(
                                    Icons.arrow_right_alt,
                                    color: AppColors.textMuted,
                                    size: 14,
                                  ),
                                ),
                                Text(
                                  t.ideaName, // Aqui usamos o nome da Startup (Ideia)
                                  style: const TextStyle(
                                    color: AppColors.emerald,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildStatusBadge(t.status),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currency.format(t.investmentValue),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${t.equityPercentage.toStringAsFixed(1)}% EQUITY',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _deleteTransaction(context, t.id),
                            child: const Icon(
                              Icons.delete_sweep_outlined,
                              color: AppColors.error,
                              size: 20,
                            ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.emerald;
      case 'rejected':
        return AppColors.error;
      case 'counter_offered':
        return Colors.orangeAccent;
      default:
        return AppColors.gold;
    }
  }
}
