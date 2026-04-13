import 'package:app_shark_tank/features/shared/data/shared_providers.dart';
import 'package:app_shark_tank/features/shared/domain/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../auth/presentation/login_screen.dart';
import 'widgets/balance_card.dart';
import 'widgets/proponent_showcase_card.dart';
import 'widgets/shark_counter_offer_card.dart';
// Removemos a importação do AcceptedSharkCard antigo, pois criaremos uma visão customizada aqui.

class SharkDashboardScreen extends ConsumerWidget {
  final UserModel sharkUser;

  const SharkDashboardScreen({super.key, required this.sharkUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutando provedores
    final usersAsync = ref.watch(usersStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Investidor: ${sharkUser.name}',
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
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, stack) => Center(child: Text('Erro: $e')),
        data: (users) {
          final liveShark = users.firstWhere(
            (u) => u.id == sharkUser.id,
            orElse: () => sharkUser,
          );
          final proponents = users.where((u) => u.role == 'proponent').toList();

          return transactionsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
            error: (e, stack) => Center(child: Text('Erro: $e')),
            data: (transactions) {
              final myTransactions = transactions
                  .where((t) => t.sharkId == liveShark.id)
                  .toList();
              final counterOffers = myTransactions
                  .where((t) => t.status == 'counter_offered')
                  .toList();
              final acceptedDeals = myTransactions
                  .where((t) => t.status == 'accepted')
                  .toList();

              // 1. Lógica de Agrupamento: Consolida investimentos da MESMA Startup
              final Map<String, Map<String, dynamic>> aggregatedPortfolio = {};

              for (var t in acceptedDeals) {
                final key = t.ideaName; // Agrupa pelo nome da Startup
                if (aggregatedPortfolio.containsKey(key)) {
                  // Se já investiu antes, apenas soma o valor e o equity
                  aggregatedPortfolio[key]!['totalValue'] += t.investmentValue;
                  aggregatedPortfolio[key]!['totalEquity'] +=
                      t.equityPercentage;
                } else {
                  // Se é o primeiro investimento nessa Startup, cria a entrada
                  aggregatedPortfolio[key] = {
                    'ideaName': t.ideaName,
                    'totalValue': t.investmentValue,
                    'totalEquity': t.equityPercentage,
                  };
                }
              }
              // Transforma o mapa agrupado de volta em uma lista para o ListView
              final portfolioList = aggregatedPortfolio.values.toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BalanceCard(
                      balance: liveShark.availableCapital ?? 0.0,
                      reserved: liveShark.reservedCapital ?? 0.0,
                    ),
                    const SizedBox(height: 32),

                    if (counterOffers.isNotEmpty) ...[
                      const Text(
                        'CAIXA DE ENTRADA',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...counterOffers.map(
                        (t) => SharkCounterOfferCard(transaction: t),
                      ),
                      const SizedBox(height: 32),
                    ],

                    const Text(
                      'VITRINE DE STARTUPS',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: proponents.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhuma startup no palco.',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: proponents.length,
                              itemBuilder: (context, index) {
                                return ProponentShowcaseCard(
                                  proponent: proponents[index],
                                  liveShark: liveShark,
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 40),

                    const Text(
                      'MEU PORTFÓLIO',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    portfolioList.isEmpty
                        ? const Center(
                            child: Text(
                              'Você ainda não fechou negócios.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: portfolioList.length,
                            itemBuilder: (context, index) {
                              final item = portfolioList[index];

                              // 2. Novo Card Consolidado (Substitui o AcceptedSharkCard)
                              return Card(
                                color: AppColors.cardDark,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.rocket_launch,
                                    color: AppColors.emerald,
                                  ),
                                  title: Text(
                                    item['ideaName']
                                        .toString()
                                        .toUpperCase(), // Nome da Startup
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
