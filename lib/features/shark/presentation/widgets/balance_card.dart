import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double reserved;

  const BalanceCard({super.key, required this.balance, required this.reserved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cardDark, AppColors.backgroundMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'CAPITAL DISPONÍVEL LIVRE',
            style: TextStyle(
              color: AppColors.textMuted,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
              shadows: [Shadow(color: AppColors.gold, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 8),
          if (reserved > 0)
            Text(
              'Em Propostas (Congelado): \$${reserved.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
