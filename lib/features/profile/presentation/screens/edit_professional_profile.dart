// features/profile/presentation/screens/edit_professional_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
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
  String _selectedLastDegree = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final applicant = ref.read(applicantNotifierProvider).applicant;

    if (applicant != null) {
      _selectedEducationLevelId = applicant.educationLevel?.id;
      _selectedFieldOfStudyId = applicant.fieldStudy?.id;
      _selectedLastDegree = applicant.lastDegreeObtained?.id.toString() ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final refState = ref.read(profileReferencesNotifierProvider);

    final targetEducationLevel = refState.educationLevels.firstWhere(
      (e) => e.id == _selectedEducationLevelId,
      orElse: () => ReferenceEntity(id: _selectedEducationLevelId ?? 0, name: ''),
    );

    final targetFieldStudy = refState.fieldsOfStudy.firstWhere(
      (f) => f.id == _selectedFieldOfStudyId,
      orElse: () => ReferenceEntity(id: _selectedFieldOfStudyId ?? 0, name: ''),
    );

    // ── Payload réseau : uniquement des types JSON-safe ──
    final Map<String, dynamic> fieldsToUpdate = {
      'educationLevelId': _selectedEducationLevelId,
      'fieldStudyId': _selectedFieldOfStudyId,
      'experience': _selectedExperience,
      'lastDegreeObtained': _selectedLastDegree.trim(),
    };

    final success = await ref.read(applicantNotifierProvider.notifier).updateProfileFields(
          fieldsToUpdate,
          optimisticEducationLevel: targetEducationLevel,
          optimisticFieldStudy: targetFieldStudy,
        );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil professionnel mis à jour'),
            backgroundColor: AppColors.primary900,
          ),
        );
      } else {
        final errorMessage = ref.read(applicantNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Erreur lors de la mise à jour'),
            backgroundColor: AppColors.error,
          ),
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
          leading: Padding(
            padding: const EdgeInsets.only(left: AppDimensions.sp16),
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back,
                  size: AppDimensions.iconSM,
                  color: AppColors.neutral800,
                ),
              ),
            ),
          ),
          title: const Text('Profil professionnel', style: AppTextStyles.headingSmall),
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
                                        (e) => e.id == _selectedEducationLevelId)
                                    ? currentLevelEntity
                                    : null,
                                labelExtractor: (e) => e.name,
                                onSelected: (val) => setState(
                                    () => _selectedEducationLevelId = val.id),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sp12),

                            // Expérience
                            Expanded(
                              child: SSearchableDropdown<String>(
                                label: 'Expérience *',
                                pickerTitle: "Niveau d'expérience",
                                value: _selectedExperience,
                                options: const [
                                  'Choisir',
                                  'Débutant',
                                  "3 ans d'expérience",
                                  'Sénior'
                                ],
                                currentValue: _selectedExperience,
                                labelExtractor: (val) => val,
                                searchHint: 'Filtrer l\'expérience...',
                                onSelected: (val) =>
                                    setState(() => _selectedExperience = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        // Domaine d'activité
                        SSearchableDropdown<ReferenceEntity>(
                          label: 'Domaine de formation *',
                          pickerTitle: "Rechercher un domaine d'activité",
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

                        // Dernier diplôme obtenu
                        SField(
                          label: 'Dernier diplôme obtenu *',
                          hint: 'Ex: Licence en Informatique, BTS, etc.',
                          controller: TextEditingController(text: _selectedLastDegree)
                            ..selection = TextSelection.fromPosition(
                                TextPosition(offset: _selectedLastDegree.length)),
                          onChanged: (val) => _selectedLastDegree = val,
                        ),
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