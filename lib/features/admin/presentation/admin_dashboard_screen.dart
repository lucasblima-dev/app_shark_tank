import 'package:app_shark_tank/features/admin/presentation/widgets/users_list_tab.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/login_screen.dart';
import 'widgets/transactions_log_tab.dart';
import 'widgets/user_form_dialog.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.black,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const UserFormDialog(),
            );
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text(
            'Painel do Admin',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: AppColors.error),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.emerald,
            labelColor: AppColors.emerald,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Participantes'),
              Tab(icon: Icon(Icons.list_alt), text: 'Log Global'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [UsersListTab(), TransactionsLogTab()],
        ),
      ),
    );
  }
}
