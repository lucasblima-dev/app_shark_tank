import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/shared_providers.dart';
import '../../../shared/domain/models/user_model.dart';
import 'user_form_dialog.dart';

class UsersListTab extends ConsumerWidget {
  const UsersListTab({super.key});

  // Função para deletar um usuário diretamente do Firestore
  void _deleteDocument(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: const Text(
          'Tem certeza que deseja apagar este usuário?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Apagar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
    }
  }

  // Função para abrir o formulário em modo de edição
  void _openEditModal(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => UserFormDialog(userToEdit: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutando a lista de usuários em tempo real através do provider
    final usersAsync = ref.watch(usersStreamProvider);

    return usersAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      ),
      error: (e, stack) => Center(
        child: Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
      ),
      data: (users) {
        // Separando os usuários por papel para a organização da lista
        final sharks = users.where((u) => u.role == 'shark').toList();
        final proponents = users.where((u) => u.role == 'proponent').toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader(
              context,
              title: 'INVESTIDORES (SHARKS)',
              icon: Icons.payments_outlined,
              color: AppColors.gold,
            ),
            ...sharks.map((shark) => _buildUserCard(context, shark)),

            const SizedBox(height: 32),

            _buildSectionHeader(
              context,
              title: 'STARTUPS (PROPONENTES)',
              icon: Icons.rocket_launch_outlined,
              color: AppColors.emerald,
            ),
            ...proponents.map((prop) => _buildUserCard(context, prop)),
          ],
        );
      },
    );
  }

  // Widget para os cabeçalhos das seções (Substitui os ExpansionTiles)
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          // ignore: deprecated_member_use
          Container(height: 1, width: 40, color: color.withOpacity(0.3)),
        ],
      ),
    );
  }

  // Widget para o card individual de cada usuário com design Premium
  Widget _buildUserCard(BuildContext context, UserModel user) {
    final bool isShark = user.role == 'shark';
    final Color accentColor = isShark ? AppColors.gold : AppColors.emerald;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ), // Destaque lateral colorido
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          user.name.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UID: ${user.id}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              if (isShark)
                _buildInfoRow(
                  Icons.account_balance_wallet_outlined,
                  'Disponível: \$${user.availableCapital?.toStringAsFixed(0)}',
                  AppColors.gold,
                )
              else
                _buildInfoRow(
                  Icons.lightbulb_outline,
                  'Ideia: ${user.ideaName}',
                  AppColors.emerald,
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: AppColors.textMuted),
              onPressed: () => _openEditModal(context, user),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.error,
              ),
              onPressed: () => _deleteDocument(context, user.id),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para criar as linhas de informações (Capital ou Ideia) com ícone
  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
