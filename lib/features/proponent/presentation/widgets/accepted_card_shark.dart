import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/domain/models/transaction_model.dart';

class AcceptedSharkCard extends StatelessWidget {
  final TransactionModel transaction;

  const AcceptedSharkCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardDark,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.monetization_on, color: AppColors.emerald),
        title: Text(
          'Shark ID: ${transaction.sharkId}',
          style: const TextStyle(color: AppColors.textWhite),
        ),
        trailing: Text(
          '\$${transaction.investmentValue.toStringAsFixed(0)} (${transaction.equityPercentage}%)',
          style: const TextStyle(
            color: AppColors.emerald,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
