import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/data/shared_providers.dart';
import '../../../shared/domain/models/user_model.dart';
import 'user_form_dialog.dart';

class UsersListTab extends ConsumerWidget {
  const UsersListTab({super.key});

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

  void _openEditModal(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => UserFormDialog(userToEdit: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);

    return usersAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      ),
      error: (e, stack) => Center(
        child: Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
      ),
      data: (users) {
        final sharks = users.where((u) => u.role == 'shark').toList();
        final proponents = users.where((u) => u.role == 'proponent').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sessão Sharks
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent), // Remove linha feia
              child: ExpansionTile(
                initiallyExpanded: true,
                collapsedBackgroundColor: AppColors.cardDark,
                backgroundColor: AppColors.cardDark,
                iconColor: AppColors.gold,
                collapsedIconColor: AppColors.gold,
                title: const Text(
                  '🦈 Sharks (Investidores)',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: sharks
                    .map((shark) => _buildUserCard(context, shark))
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Sessão Proponentes
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                collapsedBackgroundColor: AppColors.cardDark,
                backgroundColor: AppColors.cardDark,
                iconColor: AppColors.emerald,
                collapsedIconColor: AppColors.emerald,
                title: const Text(
                  '💡 Proponentes (Startups)',
                  style: TextStyle(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: proponents
                    .map((prop) => _buildUserCard(context, prop))
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        user.name,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID: ${user.id}',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          if (user.role == 'shark')
            Text(
              'Disponível: \$${user.availableCapital?.toStringAsFixed(0)} | Congelado: \$${user.reservedCapital?.toStringAsFixed(0)}',
              style: const TextStyle(color: AppColors.gold, fontSize: 12),
            ),
          if (user.role == 'proponent')
            Text(
              'Ideia: ${user.ideaName} | Equity Cedido: ${user.equityGiven}%',
              style: const TextStyle(color: AppColors.emerald, fontSize: 12),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textMuted, size: 20),
            onPressed: () => _openEditModal(context, user),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () => _deleteDocument(context, user.id),
          ),
        ],
      ),
    );
  }
}
