import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../shared/domain/models/user_model.dart';
import '../../shared/data/shared_providers.dart';
import '../../auth/presentation/login_screen.dart';
import 'controllers/proponent_controller.dart';
import 'widgets/valuation_card.dart';
import 'widgets/proponent_dialogs.dart';
import 'widgets/pending_proposal_card.dart';
// O widget AcceptedSharkCard antigo foi removido desta tela para criarmos a versão consolidada

class ProponentDashboardScreen extends ConsumerWidget {
  final UserModel proponentUser;

  const ProponentDashboardScreen({super.key, required this.proponentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final controller = ref.read(proponentControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          proponentUser.name,
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.error),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false,
            ),
          ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.emerald),
        ),
        error: (e, stack) => Center(child: Text('Erro ao ler usuário: $e')),
        data: (users) {
          final liveUser = users.firstWhere(
            (u) => u.id == proponentUser.id,
            orElse: () => proponentUser,
          );

          return transactionsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.emerald),
            ),
            error: (e, stack) => Center(child: Text('Erro nas transações: $e')),
            data: (allTransactions) {
              // Filtra as transações para pegar apenas as desta startup
              final myInvestments = allTransactions
                  .where((t) => t.proponentId == liveUser.id)
                  .toList();
              final pendingProps = myInvestments
                  .where((t) => t.status == 'pending_proponent')
                  .toList();
              final acceptedProps = myInvestments
                  .where((t) => t.status == 'accepted')
                  .toList();
              final totalRaised = acceptedProps.fold(
                0.0,
                (sum, t) => sum + t.investmentValue,
              );

              // 1. Lógica de Agrupamento: Consolida investimentos do MESMO Shark
              final Map<String, Map<String, dynamic>> aggregatedSharks = {};

              for (var t in acceptedProps) {
                final key = t.sharkId; // Agrupa usando o ID único do Shark
                if (aggregatedSharks.containsKey(key)) {
                  // Se já existe investimento desse shark na startup, apenas soma
                  aggregatedSharks[key]!['totalValue'] += t.investmentValue;
                  aggregatedSharks[key]!['totalEquity'] += t.equityPercentage;
                } else {
                  // Se é o primeiro aporte deste shark, busca o nome real na lista de usuários
                  final sharkUser = users.firstWhere(
                    (u) => u.id == t.sharkId,
                    orElse: () => UserModel(
                      id: t.sharkId,
                      name: t.sharkId,
                      role: 'shark',
                    ),
                  );

                  aggregatedSharks[key] = {
                    'sharkName': sharkUser.name,
                    'totalValue': t.investmentValue,
                    'totalEquity': t.equityPercentage,
                  };
                }
              }
              // Converte o dicionário de volta para uma lista
              final sharkList = aggregatedSharks.values.toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Ideia: ${liveUser.ideaName ?? "Sem Nome"}',
                            style: const TextStyle(
                              color: AppColors.emerald,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.gold),
                          onPressed: () async {
                            final newName = await showDialog<String>(
                              context: context,
                              builder: (_) => EditIdeaDialog(
                                currentName: liveUser.ideaName ?? '',
                              ),
                            );
                            if (newName != null && newName.isNotEmpty) {
                              controller.updateIdeaName(liveUser.id, newName);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ValuationCard(
                      totalRaised: totalRaised,
                      totalEquity: liveUser.equityGiven ?? 0.0,
                    ),
                    const SizedBox(height: 32),

                    if (pendingProps.isNotEmpty) ...[
                      const Text(
                        'PROPOSTAS RECEBIDAS',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...pendingProps.map(
                        (t) => PendingProposalCard(
                          transaction: t,
                          liveUser: liveUser,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    const Text(
                      'INVESTIDORES',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    sharkList.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum acordo fechado ainda.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sharkList.length,
                            itemBuilder: (context, index) {
                              final item = sharkList[index];

                              // 2. Novo Card Consolidado com o Nome Real do Shark
                              return Card(
                                color: AppColors.cardDark,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.monetization_on,
                                    color: AppColors.emerald,
                                  ),
                                  title: Text(
                                    item['sharkName']
                                        .toString()
                                        .toUpperCase(), // Nome da pessoa em destaque
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  trailing: Text(
                                    '\$${item['totalValue'].toStringAsFixed(0)} (${item['totalEquity'].toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                      color: AppColors.emerald,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
