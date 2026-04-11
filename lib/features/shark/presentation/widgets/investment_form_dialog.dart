import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/domain/models/user_model.dart';
import '../../../shared/presentation/widget/premium_text_field.dart';
import '../controllers/investment_controller.dart';

class InvestmentFormDialog extends ConsumerStatefulWidget {
  final UserModel liveShark;
  final UserModel proponent;

  const InvestmentFormDialog({
    super.key,
    required this.liveShark,
    required this.proponent,
  });

  @override
  ConsumerState<InvestmentFormDialog> createState() =>
      _InvestmentFormDialogState();
}

class _InvestmentFormDialogState extends ConsumerState<InvestmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late ConfettiController _confettiController;
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
    _valueController.dispose();
    _equityController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref
        .read(investmentControllerProvider.notifier)
        .makeInvestment(
          sharkId: widget.liveShark.id,
          proponentId: widget.proponent.id,
          ideaName: widget.proponent.ideaName ?? 'Sem Nome',
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
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(investmentControllerProvider).isLoading;
    final maxEquity = 49.0 - (widget.proponent.equityGiven ?? 0.0);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlertDialog(
          backgroundColor: AppColors.backgroundLight,
          title: Text(
            'Propor a ${widget.proponent.ideaName}',
            style: const TextStyle(
              color: AppColors.emerald,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Equity Disponível: ${maxEquity.toStringAsFixed(1)}%',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: _valueController,
                  label: 'Sua Oferta (\$)',
                  icon: Icons.attach_money,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _equityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppColors.textWhite),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Obrigatório';
                    final val = double.tryParse(value);
                    if (val == null) return 'Inválido';
                    if (val > maxEquity) {
                      return 'Máximo permitido é $maxEquity%';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Porcentagem (%)',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(
                      Icons.pie_chart,
                      color: AppColors.gold,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.black,
              ),
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  : const Text('Fazer Oferta'),
            ),
          ],
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: pi / 2,
          colors: const [AppColors.gold, AppColors.emerald],
        ),
      ],
    );
  }
}
