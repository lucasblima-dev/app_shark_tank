import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/domain/models/user_model.dart';
import 'investment_form_dialog.dart';

class ProponentShowcaseCard extends StatelessWidget {
  final UserModel proponent;
  final UserModel liveShark;

  const ProponentShowcaseCard({
    super.key,
    required this.proponent,
    required this.liveShark,
  });

  @override
  Widget build(BuildContext context) {
    final equityGiven = proponent.equityGiven ?? 0.0;
    // startup vendeu >= 49% ou o Shark não tem plata
    final isLocked =
        equityGiven >= 49.0 || (liveShark.availableCapital ?? 0) <= 0;

    return GestureDetector(
      onTap: isLocked
          ? null
          : () => showDialog(
              context: context,
              builder: (_) => InvestmentFormDialog(
                liveShark: liveShark,
                proponent: proponent,
              ),
            ),
      child: Opacity(
        opacity: isLocked ? 0.4 : 1.0,
        child: Container(
          width: 200,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked
                  ? Colors.grey
                  : AppColors.gold.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock : Icons.rocket_launch,
                color: isLocked ? Colors.grey : AppColors.gold,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                proponent.ideaName ?? 'Sem Nome',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                'Percentual Cedido: $equityGiven%',
                style: TextStyle(
                  color: isLocked ? AppColors.error : AppColors.emerald,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLocked)
                const Text(
                  'ESGOTADO',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
