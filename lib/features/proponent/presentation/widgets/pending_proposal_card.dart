import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/domain/models/transaction_model.dart';
import '../../../shared/domain/models/user_model.dart';
import '../controllers/proponent_controller.dart';
import 'proponent_dialogs.dart';

class PendingProposalCard extends ConsumerWidget {
  final TransactionModel transaction;
  final UserModel liveUser;

  const PendingProposalCard({
    super.key,
    required this.transaction,
    required this.liveUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(proponentControllerProvider.notifier);

    return Card(
      color: AppColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.gold),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shark: ${transaction.sharkId}',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Oferece: \$${transaction.investmentValue.toStringAsFixed(0)} por ${transaction.equityPercentage}%',
              style: const TextStyle(color: AppColors.emerald, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ACEITAR
                IconButton(
                  icon: const Icon(
                    Icons.check_circle,
                    color: AppColors.emerald,
                    size: 32,
                  ),
                  tooltip: 'Aceitar Proposta',
                  onPressed: () async {
                    await controller.acceptProposal(transaction, liveUser);
                    if (ref.read(proponentControllerProvider).hasError &&
                        context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ref
                                .read(proponentControllerProvider)
                                .error
                                .toString(),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
                // CONTRAPROPOSTA
                IconButton(
                  icon: const Icon(
                    Icons.handshake,
                    color: AppColors.gold,
                    size: 32,
                  ),
                  tooltip: 'Fazer Contraproposta',
                  onPressed: () async {
                    final result = await showDialog<Map<String, double>>(
                      context: context,
                      builder: (_) => CounterOfferDialog(
                        originalValue: transaction.investmentValue,
                        originalEquity: transaction.equityPercentage,
                      ),
                    );
                    if (result != null) {
                      controller.counterProposal(
                        transaction,
                        result['val']!,
                        result['eq']!,
                      );
                    }
                  },
                ),
                // RECUSAR
                IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: AppColors.error,
                    size: 32,
                  ),
                  tooltip: 'Recusar Proposta',
                  onPressed: () => controller.rejectProposal(transaction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
