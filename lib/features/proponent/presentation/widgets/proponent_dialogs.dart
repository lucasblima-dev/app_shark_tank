import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/presentation/widget/premium_text_field.dart';

class EditIdeaDialog extends StatelessWidget {
  final String currentName;
  EditIdeaDialog({super.key, required this.currentName});

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = currentName;
    return AlertDialog(
      backgroundColor: AppColors.backgroundLight,
      title: const Text(
        'Mudar Nome da Ideia',
        style: TextStyle(color: AppColors.textWhite),
      ),
      content: PremiumTextField(
        controller: _controller,
        label: 'Novo Nome',
        icon: Icons.edit,
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
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class CounterOfferDialog extends StatelessWidget {
  final double originalValue;
  final double originalEquity;
  CounterOfferDialog({
    super.key,
    required this.originalValue,
    required this.originalEquity,
  });

  final _valController = TextEditingController();
  final _eqController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _valController.text = originalValue.toString();
    _eqController.text = originalEquity.toString();

    return AlertDialog(
      backgroundColor: AppColors.backgroundLight,
      title: const Text(
        'Fazer Contraproposta',
        style: TextStyle(color: AppColors.textWhite),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PremiumTextField(
            controller: _valController,
            label: 'Novo Valor (\$)',
            icon: Icons.attach_money,
            isNumber: true,
          ),
          const SizedBox(height: 16),
          PremiumTextField(
            controller: _eqController,
            label: 'Novo Equity (%)',
            icon: Icons.pie_chart,
            isNumber: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.black,
          ),
          onPressed: () => Navigator.pop(context, {
            'val': double.parse(_valController.text),
            'eq': double.parse(_eqController.text),
          }),
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
