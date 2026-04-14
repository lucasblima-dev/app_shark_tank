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
                ? 'Participante cadastrado com sucesso!'
                : 'Cadastro atualizado com sucesso!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.userToEdit != null;

    return AlertDialog(
      backgroundColor: AppColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      title: Text(
        isEditing ? 'EDITAR PARTICIPANTE' : 'NOVO PARTICIPANTE',
        style: const TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          fontSize: 16,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditing) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'TIPO DE CONTA',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  isExpanded: true, // Fundamental para evitar quebra de layout
                  dropdownColor: AppColors.backgroundDark,
                  // A cor da seta agora muda dinamicamente para combinar com o tipo selecionado
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _role == 'shark'
                        ? AppColors.gold
                        : AppColors.emerald,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  // O selectedItemBuilder garante que quando o botão está fechado, o layout fique limpo
                  selectedItemBuilder: (BuildContext context) {
                    return [
                      const Text(
                        'INVESTIDOR (SHARK)',
                        style: TextStyle(
                          color: AppColors.gold,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow
                            .ellipsis, // Corta o texto se a tela for muito pequena
                      ),
                      const Text(
                        'STARTUP (PROPONENTE)',
                        style: TextStyle(
                          color: AppColors.emerald,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ];
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'shark',
                      child: Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            color: AppColors.gold,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'INVESTIDOR (SHARK)',
                              style: TextStyle(
                                color: AppColors.gold,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'proponent',
                      child: Row(
                        children: [
                          Icon(
                            Icons.rocket_launch_outlined,
                            color: AppColors.emerald,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'STARTUP (PROPONENTE)',
                              style: TextStyle(
                                color: AppColors.emerald,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _role = val!),
                ),
                const SizedBox(height: 20),
              ],

              PremiumTextField(
                controller: _idController,
                label: 'ID Único (Login)',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                controller: _nameController,
                label: 'Nome Completo',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Campos dinâmicos dependendo da escolha
              if (_role == 'shark')
                PremiumTextField(
                  controller: _capitalController,
                  label: 'Capital Inicial (\$)',
                  icon: Icons.account_balance_wallet_outlined,
                  isNumber: true,
                ),
              if (_role == 'proponent')
                PremiumTextField(
                  controller: _ideaController,
                  label: 'Nome da Startup',
                  icon: Icons.domain,
                ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 24, bottom: 24, top: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CANCELAR',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _saveUser,
          child: Text(
            isEditing ? 'ATUALIZAR' : 'CADASTRAR',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
