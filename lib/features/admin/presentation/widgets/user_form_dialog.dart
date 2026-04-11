import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/domain/models/user_model.dart';
import '../../../shared/presentation/widget/premium_text_field.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? userToEdit;

  const UserFormDialog({super.key, this.userToEdit});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _role;

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _capitalController = TextEditingController();
  final _ideaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche os dados se for edição
    _role = widget.userToEdit?.role ?? 'shark';
    if (widget.userToEdit != null) {
      _idController.text = widget.userToEdit!.id;
      _nameController.text = widget.userToEdit!.name;
      if (_role == 'shark') {
        _capitalController.text =
            widget.userToEdit!.availableCapital?.toString() ?? '';
      } else if (_role == 'proponent') {
        _ideaController.text = widget.userToEdit!.ideaName ?? '';
      }
    }
  }

  void _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_idController.text.trim());

    final userData = {
      'name': _nameController.text.trim(),
      'role': _role,
      if (_role == 'shark')
        'availableCapital': double.parse(_capitalController.text),
      if (_role == 'shark')
        'reservedCapital': widget.userToEdit?.reservedCapital ?? 0.0,
      if (_role == 'proponent') 'ideaName': _ideaController.text.trim(),
      if (_role == 'proponent')
        'equityGiven': widget.userToEdit?.equityGiven ?? 0.0,
    };

    await docRef.set(userData, SetOptions(merge: true));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.userToEdit == null
                ? 'Usuário criado!'
                : 'Usuário atualizado!',
          ),
          backgroundColor: AppColors.emerald,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.userToEdit != null;

    return AlertDialog(
      backgroundColor: AppColors.backgroundLight,
      title: Text(
        isEditing ? 'Editar Participante' : 'Novo Participante',
        style: const TextStyle(color: AppColors.textWhite),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Só permite escolher o papel se for criação
              if (!isEditing)
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  dropdownColor: AppColors.cardDark,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Usuário',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'shark',
                      child: Text('🦈 Shark (Investidor)'),
                    ),
                    DropdownMenuItem(
                      value: 'proponent',
                      child: Text('💡 Proponente (Startup)'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _role = val!),
                ),
              const SizedBox(height: 16),
              PremiumTextField(
                controller: _idController,
                label: 'ID Único (Login)',
                icon: Icons.badge,
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                controller: _nameController,
                label: 'Nome Completo',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Campos dinâmicos dependendo da escolha
              if (_role == 'shark')
                PremiumTextField(
                  controller: _capitalController,
                  label: 'Capital Inicial (\$)',
                  icon: Icons.attach_money,
                  isNumber: true,
                ),
              if (_role == 'proponent')
                PremiumTextField(
                  controller: _ideaController,
                  label: 'Nome da Ideia/Startup',
                  icon: Icons.lightbulb_outline,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            foregroundColor: Colors.black,
          ),
          onPressed: _saveUser,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
