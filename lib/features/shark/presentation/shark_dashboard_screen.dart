import 'package:app_shark_tank/features/shared/presentation/widget/premium_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../../../../core/constants/app_colors.dart';
import '../../shared/domain/models/user_model.dart';
//import '../../shared//presentation/widget/premium_text_field.dart';
import '../../auth/presentation/login_screen.dart';
import 'controllers/investment_controller.dart';
import 'widgets/balance_card.dart';

class SharkDashboardScreen extends ConsumerStatefulWidget {
  final UserModel sharkUser;
  const SharkDashboardScreen({super.key, required this.sharkUser});

  @override
  ConsumerState<SharkDashboardScreen> createState() =>
      _SharkDashboardScreenState();
}

class _SharkDashboardScreenState extends ConsumerState<SharkDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  late ConfettiController _confettiController;
  final _proponentIdController = TextEditingController();
  final _ideaNameController = TextEditingController();
  final _valueController = TextEditingController();
  final _equityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _proponentIdController.dispose();
    _ideaNameController.dispose();
    _valueController.dispose();
    _equityController.dispose();
    super.dispose();
  }

  void _submitInvestment() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref
        .read(investmentControllerProvider.notifier)
        .makeInvestment(
          sharkId: widget.sharkUser.id,
          proponentId: _proponentIdController.text.trim(),
          ideaName: _ideaNameController.text.trim(),
          value: double.parse(_valueController.text),
          equity: double.parse(_equityController.text),
        );

    final state = ref.read(investmentControllerProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${state.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      _confettiController.play();
      _proponentIdController.clear();
      _ideaNameController.clear();
      _valueController.clear();
      _equityController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🤝 DEAL DONE!'),
          backgroundColor: AppColors.emerald,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(investmentControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Investidor: ${widget.sharkUser.name}',
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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BalanceCard(balance: widget.sharkUser.availableCapital ?? 0.0),
                const SizedBox(height: 40),
                const Text(
                  'NOVO APORTE',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      PremiumTextField(
                        controller: _proponentIdController,
                        label: 'ID do Proponente',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      PremiumTextField(
                        controller: _ideaNameController,
                        label: 'Nome da Ideia',
                        icon: Icons.lightbulb_outline,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PremiumTextField(
                              controller: _valueController,
                              label: 'Valor (\$)',
                              icon: Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PremiumTextField(
                              controller: _equityController,
                              label: 'Equity (%)',
                              icon: Icons.pie_chart_outline,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitInvestment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : const Text(
                                  'CONFIRMAR INVESTIMENTO',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            colors: const [AppColors.gold, AppColors.emerald, Colors.white],
          ),
        ],
      ),
    );
  }
}
