// features/profile/presentation/screens/edit_personal_situation.dart
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
import 'package:sime_v2/core/design_system/widgets/s_overlay_loader.dart';
import 'package:sime_v2/core/design_system/widgets/s_searchable_dropdown.dart';
import 'package:sime_v2/features/profile/presentation/providers/applicant_notifier.dart';
import 'package:sime_v2/features/profile/presentation/providers/profile_reference_notifier.dart';

/// Écran d'édition de la « Situation personnelle » du candidat : statut
/// matrimonial, nombre d'enfants et type de handicap.
///
/// Séparé de `EditIdentityInformationsScreen` (état civil/résidence) pour une
/// édition ciblée. Envoie un PATCH partiel via
/// [ApplicantNotifier.updateProfileFields] ; les pièces d'identité sont
/// automatiquement préservées côté notifier (voir `_withPreservedIdentities`).
class EditPersonalSituationScreen extends ConsumerStatefulWidget {
  const EditPersonalSituationScreen({super.key});

  @override
  ConsumerState<EditPersonalSituationScreen> createState() =>
      _EditPersonalSituationScreenState();
}

class _EditPersonalSituationScreenState
    extends ConsumerState<EditPersonalSituationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nbChildrenController;

  int? _selectedMaritalStatusId;
  int? _selectedDisabilityTypeId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final applicant = ref.read(applicantNotifierProvider).applicant;

    _nbChildrenController = TextEditingController(
        text: applicant?.nbChildren != null ? '${applicant!.nbChildren}' : '');
    _selectedMaritalStatusId = applicant?.maritalStatus?.id;
    _selectedDisabilityTypeId = applicant?.disabilityType?.id;
  }

  @override
  void dispose() {
    _nbChildrenController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final nbChildrenText = _nbChildrenController.text.trim();
    final Map<String, dynamic> fieldsToUpdate = {
      if (_selectedMaritalStatusId != null)
        'maritalStatusId': _selectedMaritalStatusId,
      if (_selectedDisabilityTypeId != null)
        'disabilityTypeId': _selectedDisabilityTypeId,
      if (nbChildrenText.isNotEmpty)
        'nbChildren': int.tryParse(nbChildrenText) ?? 0,
    };

    final success = await ref
        .read(applicantNotifierProvider.notifier)
        .updateProfileFields(fieldsToUpdate);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppStatusDialog.show(
        context,
        title: 'Situation mise à jour',
        message: 'Votre situation personnelle a été mise à jour avec succès.',
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

  @override
  Widget build(BuildContext context) {
    final refState = ref.watch(profileReferencesNotifierProvider);

    final selectedMaritalStatus = refState.maritalStatuses
        .where((m) => m.id == _selectedMaritalStatusId)
        .firstOrNull;
    final selectedDisabilityType = refState.disabilityTypes
        .where((d) => d.id == _selectedDisabilityTypeId)
        .firstOrNull;

    return SOverlayLoader(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leadingWidth: 56,
          leading: AppBackButton(onPressed: () => context.pop()),
          title: const Text('Situation personnelle',
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
                        const Text(
                            'Renseignez votre situation familiale et de handicap',
                            style: AppTextStyles.bodySmall),
                        const SizedBox(height: AppDimensions.sp24),

                        // Statut matrimonial
                        SSearchableDropdown<dynamic>(
                          label: 'Statut matrimonial',
                          pickerTitle: 'Sélectionner un statut',
                          searchHint: 'Rechercher...',
                          leadingIcon: Icons.favorite_border_rounded,
                          value: selectedMaritalStatus != null
                              ? selectedMaritalStatus.name
                              : '',
                          currentValue: selectedMaritalStatus,
                          options: refState.maritalStatuses,
                          labelExtractor: (status) => status.name,
                          onSelected: (status) => setState(
                              () => _selectedMaritalStatusId = status.id),
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        // Nombre d'enfants
                        SField(
                          label: 'Nombre d\'enfants',
                          hint: '0',
                          controller: _nbChildrenController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        // Type de handicap
                        SSearchableDropdown<dynamic>(
                          label: 'Type de handicap',
                          pickerTitle: 'Sélectionner un type',
                          searchHint: 'Rechercher...',
                          leadingIcon: Icons.accessible_rounded,
                          value: selectedDisabilityType != null
                              ? selectedDisabilityType.name
                              : '',
                          currentValue: selectedDisabilityType,
                          options: refState.disabilityTypes,
                          labelExtractor: (type) => type.name,
                          onSelected: (type) => setState(
                              () => _selectedDisabilityTypeId = type.id),
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
                        onPressed: _isLoading ? null : _save,
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
