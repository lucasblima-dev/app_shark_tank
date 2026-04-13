import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/shared_providers.dart';
import '../../../shared/domain/models/transaction_model.dart';
import '../../../shared/domain/models/user_model.dart';

class TransactionTimelineDialog extends ConsumerWidget {
  final TransactionModel t;

  const TransactionTimelineDialog({super.key, required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutando a lista de usuários para buscar o nome real do Shark
    final usersAsync = ref.watch(usersStreamProvider);

    return AlertDialog(
      backgroundColor: AppColors.backgroundLight,
      title: const Text(
        'HISTÓRICO DA NEGOCIAÇÃO',
        style: TextStyle(
          color: AppColors.emerald,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          fontSize: 16,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: usersAsync.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.emerald),
            ),
          ),
          error: (e, _) => Text('Erro ao carregar dados: $e'),
          data: (users) {
            // Buscamos o nome real do Investidor (Shark)
            final sharkRealName = users
                .firstWhere(
                  (u) => u.id == t.sharkId,
                  orElse: () =>
                      UserModel(id: t.sharkId, name: t.sharkId, role: 'shark'),
                )
                .name;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome Real do Investidor
                  _buildInfoRow(
                    'INVESTIDOR:',
                    sharkRealName.toUpperCase(),
                    AppColors.gold,
                  ),

                  // Nome da Startup (vinda direto da ideia cadastrada)
                  _buildInfoRow(
                    'STARTUP:',
                    t.ideaName.toUpperCase(),
                    AppColors.emerald,
                  ),

                  _buildInfoRow(
                    'INÍCIO:',
                    '${t.timestamp.day}/${t.timestamp.month}/${t.timestamp.year} às ${t.timestamp.hour}:${t.timestamp.minute.toString().padLeft(2, '0')}',
                    AppColors.textWhite,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Colors.white10),
                  ),

                  const Text(
                    'LINHA DO TEMPO',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Oferta Inicial: Mantendo o símbolo $ e removendo "de equity"
                  _buildTimelineStep(
                    icon: Icons.outbond_outlined,
                    color: AppColors.gold,
                    title: 'OFERTA INICIAL',
                    description:
                        'Proposta de \$${t.investmentValue.toStringAsFixed(0)} por ${t.equityPercentage.toStringAsFixed(1)}%.',
                  ),

                  if (t.counterValue != null) ...[
                    // Contraproposta: Mantendo o símbolo $ e removendo "de equity"
                    _buildTimelineStep(
                      icon: Icons.reply_outlined,
                      color: Colors.orangeAccent,
                      title: 'CONTRAPROPOSTA',
                      description:
                          'Startup solicitou \$${t.counterValue?.toStringAsFixed(0)} por ${t.counterEquity?.toStringAsFixed(1)}%.',
                    ),
                  ],

                  _buildFinalStep(t.status),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'FECHAR',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: 14,
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(icon, color: color, size: 20),
              Expanded(child: Container(width: 1, color: Colors.white10)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
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
        icon = Icons.verified_outlined;
        color = AppColors.emerald;
        title = 'NEGÓCIO FECHADO';
        desc = 'A proposta foi aceita e o capital está garantido.';
        break;
      case 'rejected':
        icon = Icons.highlight_off_outlined;
        color = AppColors.error;
        title = 'NEGOCIAÇÃO ENCERRADA';
        desc = 'As partes não chegaram a um consenso.';
        break;
      case 'counter_offered':
        icon = Icons.schedule_outlined;
        color = Colors.orangeAccent;
        title = 'AGUARDANDO DECISÃO';
        desc = 'O Shark está analisando a nova proposta da Startup.';
        break;
      default:
        icon = Icons.hourglass_top_outlined;
        color = AppColors.gold;
        title = 'EM ANÁLISE';
        desc = 'A Startup está avaliando as condições propostas.';
    }

    return _buildTimelineStep(
      icon: icon,
      color: color,
      title: title,
      description: desc,
    );
  }
}
