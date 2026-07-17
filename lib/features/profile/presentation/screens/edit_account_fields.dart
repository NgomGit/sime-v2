// features/profile/presentation/screens/edit_account_fields.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
import 'package:sime_v2/core/design_system/widgets/app_status_dialog.dart';
import 'package:sime_v2/core/design_system/widgets/s_app_back_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_genre_tile.dart';
import 'package:sime_v2/core/design_system/widgets/s_overlay_loader.dart';
import 'package:sime_v2/features/profile/presentation/providers/applicant_notifier.dart';

/// Écran d'édition des champs "compte utilisateur" : prénom, nom, téléphone,
/// email, nom d'utilisateur et genre. Ces champs correspondent exactement au
/// payload envoyé par [ApplicantNotifier.updateUserAccountFields]
/// (PUT /auth/api/auth/me).
///
/// Les autres informations du profil candidat (état civil, adresse,
/// nationalité...) sont gérées séparément par `EditIdentityInformationsScreen`.
class EditAccountFieldsScreen extends ConsumerStatefulWidget {
  const EditAccountFieldsScreen({super.key});

  @override
  ConsumerState<EditAccountFieldsScreen> createState() =>
      _EditAccountFieldsScreenState();
}

class _EditAccountFieldsScreenState
    extends ConsumerState<EditAccountFieldsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;

  String _selectedSex = 'HOMME';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final applicant = ref.read(applicantNotifierProvider).applicant;

    _firstNameController =
        TextEditingController(text: applicant?.user?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: applicant?.user?.lastName ?? '');
    _phoneController = TextEditingController(
      text: applicant?.user?.phone,
    );
    _emailController =
        TextEditingController(text: applicant?.user?.email ?? '');
    _usernameController =
        TextEditingController(text: applicant?.user?.username ?? '');

    _selectedSex =
        (applicant?.user?.sex?.toUpperCase() == 'FEMME') ? 'FEMME' : 'HOMME';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, dynamic> editedFields = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'sex': _selectedSex,
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'username': _usernameController.text.trim(),
    };

    final success = await ref
        .read(applicantNotifierProvider.notifier)
        .updateUserAccountFields(editedFields);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        AppStatusDialog.show(
          context,
          title: 'Compte mis à jour',
          message: 'Informations de compte mises à jour avec succès',
          type: StatusDialogType.success,
          onConfirm: () => context.pop(),
        );
      } else {
        final errorMessage = ref.read(applicantNotifierProvider).errorMessage;
        AppStatusDialog.show(
          context,
          title: 'Mise à jour impossible',
          message: errorMessage ?? 'Erreur lors de la mise à jour',
          type: StatusDialogType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SOverlayLoader(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leadingWidth: 56,
          leading: AppBackButton(
            onPressed: () => context.pop(),
          ),
          title: const Text('Informations du compte',
              style: AppTextStyles.headingSmall),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Modifiez vos informations de compte',
                            style: AppTextStyles.bodySmall),
                        const SizedBox(height: AppDimensions.sp24),
                        Row(
                          children: [
                            Expanded(
                              child: SField(
                                label: 'Prénom *',
                                hint: 'Mamadou',
                                controller: _firstNameController,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sp12),
                            Expanded(
                              child: SField(
                                label: 'Nom *',
                                hint: 'Diallo',
                                controller: _lastNameController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sp14),
                        SPhoneField(
                          label: 'Numéro de téléphone *',
                          hint: '+221 77 123 45 67',
                          controller: _phoneController,
                        ),
                        const SizedBox(height: AppDimensions.sp14),
                        SField(
                          label: 'Email *',
                          hint: 'mamadou.diallo@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppDimensions.sp14),
                        SField(
                          label: "Nom d'utilisateur *",
                          hint: 'mamadou.diallo',
                          controller: _usernameController,
                        ),
                        const SizedBox(height: AppDimensions.sp18),
                        Text('Genre *',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.neutral800)),
                        const SizedBox(height: AppDimensions.sp6),
                        Row(
                          children: [
                            Expanded(
                              child: GenreTile(
                                label: 'Homme',
                                gender: GenreTileGender.male,
                                isSelected: _selectedSex == 'HOMME',
                                onTap: () =>
                                    setState(() => _selectedSex = 'HOMME'),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sp12),
                            Expanded(
                              child: GenreTile(
                                label: 'Femme',
                                gender: GenreTileGender.female,
                                isSelected: _selectedSex == 'FEMME',
                                onTap: () =>
                                    setState(() => _selectedSex = 'FEMME'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(AppDimensions.sp20,
                    AppDimensions.sp14, AppDimensions.sp20, AppDimensions.sp24),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SButton(
                        label: 'Enregistrer les modifications',
                        onPressed: _isLoading ? null : _saveAccount,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
