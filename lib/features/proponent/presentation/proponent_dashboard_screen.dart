import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../shared/domain/models/user_model.dart';
import '../../shared/data/shared_providers.dart';
import '../../auth/presentation/login_screen.dart';
import 'widgets/valuation_card.dart';

class ProponentDashboardScreen extends ConsumerWidget {
  final UserModel proponentUser;

  const ProponentDashboardScreen({super.key, required this.proponentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          proponentUser.name,
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
      body: transactionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.emerald),
        ),
        error: (e, stack) => Center(child: Text('Erro: $e')),
        data: (allTransactions) {
          final myInvestments = allTransactions
              .where((t) => t.proponentId == proponentUser.id)
              .toList();
          final totalRaised = myInvestments.fold(
            0.0,
            (sum, t) => sum + t.investmentValue,
          );
          final totalEquity = myInvestments.fold(
            0.0,
            (sum, t) => sum + t.equityPercentage,
          );

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValuationCard(
                  totalRaised: totalRaised,
                  totalEquity: totalEquity,
                ),
                const SizedBox(height: 40),
                const Text(
                  'MEUS SHARKS',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: myInvestments.isEmpty
                      ? const Center(
                          child: Text(
                            'Aguardando propostas...',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          itemCount: myInvestments.length,
                          itemBuilder: (context, index) {
                            final t = myInvestments[index];
                            return Card(
                              color: AppColors.cardDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.handshake,
                                  color: AppColors.gold,
                                ),
                                title: Text(
                                  'Shark ID: ${t.sharkId}',
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Projeto: ${t.ideaName}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${t.investmentValue.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: AppColors.emerald,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${t.equityPercentage}%',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
