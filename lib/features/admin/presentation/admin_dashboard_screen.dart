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
        // Fundo escuro seguindo a paleta do projeto
        backgroundColor: AppColors.backgroundDark,

        // Botão para adicionar novos Sharks ou Proponentes
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
          // 1. Título com tipografia Premium Business
          title: const Text(
            'PAINEL ADMIN',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 18,
              color: AppColors.textWhite,
            ),
          ),
          centerTitle: true,

          // 2. Ajuste de cores da AppBar para integração total com o fundo
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,

          // Botão de Logout
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: AppColors.error),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              ),
            ),
          ],

          // 3. TabBar com indicador customizado e minimalista
          bottom: const TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.0, color: AppColors.emerald),
              insets: EdgeInsets.symmetric(
                horizontal: 50,
              ), // Indicador mais curto e elegante
            ),
            labelColor: AppColors.emerald,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              fontSize: 12,
            ),
            tabs: [
              Tab(icon: Icon(Icons.people_outline), text: 'PARTICIPANTES'),
              Tab(
                icon: Icon(Icons.analytics_outlined),
                text: 'CENTRAL DE APORTES',
              ),
            ],
          ),
        ),

        // Exibição das abas de conteúdo
        body: const TabBarView(
          children: [UsersListTab(), TransactionsLogTab()],
        ),
      ),
    );
  }
}
