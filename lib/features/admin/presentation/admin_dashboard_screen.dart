import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/shared_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Painel Administrativo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              border: Border(
                bottom: BorderSide(color: Color(0xFFD4AF37), width: 2),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log de Investimentos',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                Icon(Icons.monitor_heart, color: Color(0xFF00BFA5)),
              ],
            ),
          ),

          Expanded(
            child: transactionsAsyncValue.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
              ),

              error: (error, stack) =>
                  Center(child: Text('Erro ao carregar log: $error')),

              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma transação registrada ainda.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: const Color(0xFF2A2A2A),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(
                            0xFFD4AF37,
                          ).withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.attach_money,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        title: Text(
                          '${t.ideaName} (${t.equityPercentage}%)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Shark: ${t.sharkId} | Proponente: ${t.proponentId}',
                        ),
                        trailing: Text(
                          '\$${t.investmentValue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF00BFA5),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
