import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/domain/models/transaction_model.dart';
import '../controllers/investment_controller.dart';

class SharkCounterOfferCard extends ConsumerWidget {
  final TransactionModel transaction;

  const SharkCounterOfferCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(investmentControllerProvider.notifier);

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
            const Text(
              'CONTRAPROPOSTA RECEBIDA',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ideia: ${transaction.ideaName}',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Original: \$${transaction.investmentValue.toStringAsFixed(0)} por ${transaction.equityPercentage}%',
              style: const TextStyle(
                color: AppColors.textMuted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              'Eles Pedem: \$${transaction.counterValue?.toStringAsFixed(0)} por ${transaction.counterEquity}%',
              style: const TextStyle(
                color: AppColors.emerald,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.cancel, color: AppColors.error),
                  label: const Text(
                    'Pular Fora',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onPressed: () => controller.rejectCounterOffer(transaction),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Aceitar'),
                  onPressed: () => controller.acceptCounterOffer(transaction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
