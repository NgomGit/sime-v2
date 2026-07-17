// features/profile/presentation/screens/edit_professional_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_status_dialog.dart';
import 'package:sime_v2/core/design_system/widgets/s_app_back_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_overlay_loader.dart';
import 'package:sime_v2/core/design_system/widgets/s_searchable_dropdown.dart';
import 'package:sime_v2/features/auth/domain/entities/reference_entity.dart';
import 'package:sime_v2/features/profile/presentation/providers/applicant_notifier.dart';
import 'package:sime_v2/features/profile/presentation/providers/profile_reference_notifier.dart';

class EditProfessionalProfileScreen extends ConsumerStatefulWidget {
  const EditProfessionalProfileScreen({super.key});

  @override
  ConsumerState<EditProfessionalProfileScreen> createState() =>
      _EditProfessionalProfileScreenState();
}

class _EditProfessionalProfileScreenState
    extends ConsumerState<EditProfessionalProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedEducationLevelId;
  int? _selectedFieldOfStudyId;
  String _selectedExperience = 'Choisir';
  int? _selectedLastDegreeId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final applicant = ref.read(applicantNotifierProvider).applicant;

    if (applicant != null) {
      _selectedEducationLevelId = applicant.educationLevel?.id;
      _selectedFieldOfStudyId = applicant.fieldStudy?.id;
      _selectedLastDegreeId = applicant.lastDegreeObtained?.id;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // ── Payload réseau : uniquement des types JSON-safe ──
    final Map<String, dynamic> fieldsToUpdate = {
      'educationLevelId': _selectedEducationLevelId,
      'fieldStudyId': _selectedFieldOfStudyId,
      'experience': _selectedExperience,
      'lastDegreeObtainedId': _selectedLastDegreeId,
    };

    // Le profil est rechargé automatiquement par le notifier après succès,
    // pas besoin de reconstruire un état "optimiste" ici.
    final success = await ref
        .read(applicantNotifierProvider.notifier)
        .updateProfileFields(fieldsToUpdate);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        AppStatusDialog.show(
          context,
          title: 'Profil mis à jour',
          message: 'Profil professionnel mis à jour avec succès',
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
    final refState = ref.watch(profileReferencesNotifierProvider);

    final currentLevelEntity = refState.educationLevels.firstWhere(
      (e) => e.id == _selectedEducationLevelId,
      orElse: () => const ReferenceEntity(id: 0, name: 'Sélectionner'),
    );

    final lastDegreeEntity = refState.educationLevels.firstWhere(
      (e) => e.id == _selectedLastDegreeId,
      orElse: () => const ReferenceEntity(id: 0, name: 'Sélectionner'),
    );

    final currentFieldEntity = refState.fieldsOfStudy.firstWhere(
      (f) => f.id == _selectedFieldOfStudyId,
      orElse: () => const ReferenceEntity(id: 0, name: 'Sélectionner'),
    );

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
          title: const Text('Profil professionnel',
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
                          'Aidez votre conseiller à mieux vous orienter',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: AppDimensions.sp24),

                        Row(
                          children: [
                            // Niveau d'étude
                            Expanded(
                              child: SSearchableDropdown<ReferenceEntity>(
                                label: "Niveau d'étude *",
                                pickerTitle: "Sélectionner un niveau d'étude",
                                value: currentLevelEntity.name,
                                options: refState.educationLevels,
                                currentValue: refState.educationLevels.any(
                                        (e) =>
                                            e.id == _selectedEducationLevelId)
                                    ? currentLevelEntity
                                    : null,
                                labelExtractor: (e) => e.name,
                                onSelected: (val) => setState(
                                    () => _selectedEducationLevelId = val.id),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sp12),
                            // Niveau d'étude

                            // // Expérience
                            // Expanded(
                            //   child: SSearchableDropdown<String>(
                            //     label: 'Expérience *',
                            //     pickerTitle: "Niveau d'expérience",
                            //     value: _selectedExperience,
                            //     options: const [
                            //       'Choisir',
                            //       'Débutant',
                            //       "3 ans d'expérience",
                            //       'Sénior'
                            //     ],
                            //     currentValue: _selectedExperience,
                            //     labelExtractor: (val) => val,
                            //     searchHint: 'Filtrer l\'expérience...',
                            //     onSelected: (val) =>
                            //         setState(() => _selectedExperience = val),
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        // Domaine d'activité
                        SSearchableDropdown<ReferenceEntity>(
                          label: 'Domaine de formation *',
                          pickerTitle: "Rechercher un domaine de formation",
                          searchHint: "Ex: Pêche, Services, Informatique...",
                          value: currentFieldEntity.name,
                          options: refState.fieldsOfStudy,
                          currentValue: refState.fieldsOfStudy
                                  .any((f) => f.id == _selectedFieldOfStudyId)
                              ? currentFieldEntity
                              : null,
                          labelExtractor: (f) => f.name,
                          onSelected: (val) =>
                              setState(() => _selectedFieldOfStudyId = val.id),
                        ),
                        const SizedBox(height: AppDimensions.sp14),
                        SSearchableDropdown<ReferenceEntity>(
                          label: "Dernier diplôme *",
                          pickerTitle: "Sélectionner un niveau d'étude",
                          value: lastDegreeEntity.name,
                          options: refState.educationLevels,
                          currentValue: refState.educationLevels
                                  .any((e) => e.id == _selectedLastDegreeId)
                              ? lastDegreeEntity
                              : null,
                          labelExtractor: (e) => e.name,
                          onSelected: (val) =>
                              setState(() => _selectedLastDegreeId = val.id),
                        ),

                        // // Dernier diplôme obtenu
                        // SField(xww
                        //   label: 'Dernier diplôme obtenu *',
                        //   hint: 'Ex: Licence en Informatique, BTS, etc.',
                        //   controller: TextEditingController(text: _selectedLastDegree)
                        //     ..selection = TextSelection.fromPosition(
                        //         TextPosition(offset: _selectedLastDegree.length)),
                        //   onChanged: (val) => _selectedLastDegree = val,
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.sp20,
                  AppDimensions.sp14,
                  AppDimensions.sp20,
                  AppDimensions.sp24,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SButton(
                        label: 'Enregistrer les modifications',
                        onPressed: _isLoading ? null : _saveProfile,
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
