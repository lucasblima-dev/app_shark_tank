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
import './widgets/accepted_card_shark.dart';

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
                      'MEUS SHARKS',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    acceptedProps.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum acordo fechado ainda.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: acceptedProps.length,
                            itemBuilder: (context, index) {
                              return AcceptedSharkCard(
                                transaction: acceptedProps[index],
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
