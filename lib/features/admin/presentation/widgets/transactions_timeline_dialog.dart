import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/domain/models/transaction_model.dart';

class TransactionTimelineDialog extends StatelessWidget {
  final TransactionModel t;

  const TransactionTimelineDialog({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundLight,
      title: Text(
        'Histórico da Negociação',
        style: const TextStyle(
          color: AppColors.emerald,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Shark Investidor:', t.sharkId),
              _buildInfoRow('Startup:', t.ideaName),
              _buildInfoRow(
                'Data de Início:',
                '${t.timestamp.day}/${t.timestamp.month}/${t.timestamp.year} às ${t.timestamp.hour}:${t.timestamp.minute.toString().padLeft(2, '0')}',
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Colors.white24),
              ),

              const Text(
                'LINHA DO TEMPO:',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),

              _buildTimelineStep(
                icon: Icons.monetization_on,
                color: AppColors.emerald,
                title: 'Oferta do Shark',
                description:
                    'Propôs \$${t.investmentValue.toStringAsFixed(0)} por ${t.equityPercentage}%.',
              ),

              if (t.counterValue != null) ...[
                _buildTimelineStep(
                  icon: Icons.handshake,
                  color: Colors.orangeAccent,
                  title: 'Contraproposta da Startup',
                  description:
                      'Pediu \$${t.counterValue?.toStringAsFixed(0)} por ${t.counterEquity}%.',
                ),
              ],

              _buildFinalStep(t.status),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Fechar',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep(String status) {
    IconData icon;
    Color color;
    String title;
    String desc;

    switch (status) {
      case 'accepted':
        icon = Icons.check_circle;
        color = AppColors.emerald;
        title = 'Negócio Fechado!';
        desc = 'A proposta foi aceita e o capital transferido.';
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = AppColors.error;
        title = 'Negócio Recusado';
        desc = 'As partes não chegaram a um acordo.';
        break;
      case 'counter_offered':
        icon = Icons.hourglass_empty;
        color = Colors.orangeAccent;
        title = 'Aguardando Shark';
        desc = 'O Shark precisa decidir se aceita a contraproposta.';
        break;
      case 'pending_proponent':
      default:
        icon = Icons.hourglass_empty;
        color = AppColors.gold;
        title = 'Aguardando Startup';
        desc = 'A startup ainda está avaliando a proposta.';
        break;
    }

    return _buildTimelineStep(
      icon: icon,
      color: color,
      title: title,
      description: desc,
    );
  }
}
