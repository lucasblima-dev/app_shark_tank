import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ValuationCard extends StatelessWidget {
  final double totalRaised;
  final double totalEquity;

  const ValuationCard({
    super.key,
    required this.totalRaised,
    required this.totalEquity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL LEVANTADO',
            style: TextStyle(
              color: AppColors.textMuted,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalRaised.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.emerald,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PERCENTUAL CEDIDO: $totalEquity%',
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
