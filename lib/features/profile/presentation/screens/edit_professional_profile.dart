import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/features/profile/presentation/providers/user_profile_provider.dart';

class EditProfessionalProfileScreen extends ConsumerStatefulWidget {
  const EditProfessionalProfileScreen({super.key});

  @override
  ConsumerState<EditProfessionalProfileScreen> createState() => _EditProfessionalProfileScreenState();
}

class _EditProfessionalProfileScreenState extends ConsumerState<EditProfessionalProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedStudyLevel = 'Supérieur';
  String _selectedDomain = 'Numérique & IT';
  String _selectedExperience = 'Choisir';
  String _selectedLastDegree = 'Licence';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider).value;

    if (profile != null) {
      _selectedStudyLevel = profile.studyLevel.isNotEmpty ? profile.studyLevel : 'Supérieur';
      _selectedDomain = profile.domain.isNotEmpty ? profile.domain : 'Numérique & IT';
      _selectedExperience = profile.experience.isNotEmpty ? profile.experience : 'Choisir';
      _selectedLastDegree = profile.lastDegree.isNotEmpty ? profile.lastDegree : 'Licence';
    }
  }

  /// Ouvre un sélecteur moderne sous forme de BottomSheet pour les choix déroulants.
  void _showDropdownPicker({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.sp16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.sp20, 
                    AppDimensions.sp16, 
                    AppDimensions.sp20, 
                    AppDimensions.sp10,
                  ),
                  child: Text(title, style: AppTextStyles.headingSmall),
                ),
                const Divider(color: AppColors.neutral100),
                ...options.map((option) {
                  final isCurrent = option == currentValue;
                  return ListTile(
                    title: Text(option, style: AppTextStyles.labelMedium),
                    trailing: isCurrent 
                        ? const Icon(Icons.check, color: AppColors.primary900, size: 20)
                        : null,
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(profileNotifierProvider.notifier).updateProfessionalProfile(
        studyLevel: _selectedStudyLevel,
        domain: _selectedDomain,
        experience: _selectedExperience,
        lastDegree: _selectedLastDegree,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil professionnel mis à jour'),
            backgroundColor: AppColors.primary900,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showDropdownPicker(
                                  title: "Niveau d'étude",
                                  options: const ['Supérieur', 'Master 2', 'Secondaire', 'Doctorat'],
                                  currentValue: _selectedStudyLevel,
                                  onSelected: (val) => setState(() => _selectedStudyLevel = val),
                                );
                              },
                              child: AbsorbPointer(
                                child: SDropdown(
                                  label: "Niveau d'étude *",
                                  value: _selectedStudyLevel,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sp12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showDropdownPicker(
                                  title: 'Expérience',
                                  options: const ['Choisir', 'Débutant', "3 ans d'expérience", 'Sénior'],
                                  currentValue: _selectedExperience,
                                  onSelected: (val) => setState(() => _selectedExperience = val),
                                );
                              },
                              child: AbsorbPointer(
                                child: SDropdown(
                                  label: 'Expérience *',
                                  value: _selectedExperience,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sp14),
                      
                      GestureDetector(
                        onTap: () {
                          _showDropdownPicker(
                            title: 'Domaine de formation',
                            options: const ['Numérique & IT', 'Informatique', 'Gestion de projet', 'Ingénierie Logicielle'],
                            currentValue: _selectedDomain,
                            onSelected: (val) => setState(() => _selectedDomain = val),
                          );
                        },
                        child: AbsorbPointer(
                          child: SDropdown(
                            label: 'Domaine de formation',
                            value: _selectedDomain,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sp14),
                      
                      GestureDetector(
                        onTap: () {
                          _showDropdownPicker(
                            title: 'Dernier diplôme obtenu',
                            options: const ['Licence', 'Master en Informatique', 'Doctorat', 'Autre'],
                            currentValue: _selectedLastDegree,
                            onSelected: (val) => setState(() => _selectedLastDegree = val),
                          );
                        },
                        child: AbsorbPointer(
                          child: SDropdown(
                            label: 'Dernier diplôme obtenu',
                            value: _selectedLastDegree,
                          ),
                        ),
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
                      onPressed: _isLoading ? () {} : _saveProfile,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}