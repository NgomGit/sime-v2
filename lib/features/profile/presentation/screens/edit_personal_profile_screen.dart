// features/profile/presentation/screens/edit_personal_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_genre_tile.dart';
import 'package:sime_v2/core/design_system/widgets/s_overlay_loader.dart';
import 'package:sime_v2/core/design_system/widgets/s_searchable_dropdown.dart';
import 'package:sime_v2/features/profile/presentation/providers/applicant_notifier.dart';
import 'package:sime_v2/features/profile/presentation/providers/profile_reference_notifier.dart';

class EditPersonalProfileScreen extends ConsumerStatefulWidget {
  const EditPersonalProfileScreen({super.key});

  @override
  ConsumerState<EditPersonalProfileScreen> createState() => _EditPersonalProfileScreenState();
}

class _EditPersonalProfileScreenState extends ConsumerState<EditPersonalProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _placeOfBirthController;
  late final TextEditingController _cinController;
  late final TextEditingController _addressController;

  DateTime? _selectedDate;
  String _selectedSex = 'HOMME';
  int? _selectedRegionId;
  int? _selectedDepartmentId;
  int? _selectedNationalityId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final applicant = ref.read(applicantNotifierProvider).applicant;

    _firstNameController = TextEditingController(text: applicant?.user?.firstName ?? '');
    _lastNameController = TextEditingController(text: applicant?.user?.lastName ?? '');
    _phoneController = TextEditingController(text: applicant?.user?.phone.substring(3, applicant.user?.phone.length ?? 5) ?? '');
    _placeOfBirthController = TextEditingController(text: applicant?.placeBirth ?? '');
    _cinController = TextEditingController(text: applicant?.cni ?? '');
    _addressController = TextEditingController(text: applicant?.address ?? '');

    _selectedSex = (applicant?.user?.sex?.toUpperCase() == 'FEMME') ? 'FEMME' : 'HOMME';
    _selectedRegionId = applicant?.residRegion?.id;
    _selectedDepartmentId = applicant?.residDepartment?.id;
    _selectedNationalityId = applicant?.nationality?.id;

    if (applicant?.dateBirth != null && applicant!.dateBirth.isNotEmpty) {
      _selectedDate = DateTime.tryParse(applicant.dateBirth);
    }

    // Amorce des cascades géographiques si des données initiales existent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedRegionId != null && _selectedRegionId != 0) {
        ref.read(profileReferencesNotifierProvider.notifier).loadCascadeDepartments(_selectedRegionId!);
      }
      if (_selectedDepartmentId != null && _selectedDepartmentId != 0) {
        ref.read(profileReferencesNotifierProvider.notifier).loadCascadeMunicipalities(_selectedDepartmentId!);
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _placeOfBirthController.dispose();
    _cinController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Nettoie les libellés géographiques mal encodés (mojibake)
  String _cleanGeoName(String name) {
    return name.replaceAll('RanÃ©rou', 'Ranérou').replaceAll('KÃ©dougou', 'Kédougou');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, dynamic> fieldsToUpdate = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'sex': _selectedSex,
      'phone': _phoneController.text.trim(),
      'placeBirth': _placeOfBirthController.text.trim(),
      'dateBirth': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
      'residAddress': _addressController.text.trim(),
      'residRegionId': _selectedRegionId,
      'residDepartmentId': _selectedDepartmentId,
      'nationalityId': _selectedNationalityId,
    };

    final success = await ref.read(applicantNotifierProvider.notifier).updateProfileFields(fieldsToUpdate);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations personnelles mises à jour avec succès'),
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
    final hasSelectedRegion = _selectedRegionId != null && _selectedRegionId != 0;

    // Résolution des objets sélectionnés à partir des IDs stockés
    final selectedRegion = refState.regions.where((r) => r.id == _selectedRegionId).firstOrNull;
    final selectedDepartment = refState.departments.where((d) => d.id == _selectedDepartmentId).firstOrNull;
    final selectedNationality = refState.nationalities.where((n) => n.id == _selectedNationalityId).firstOrNull;

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
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back, size: AppDimensions.iconSM, color: AppColors.neutral800),
              ),
            ),
          ),
          title: const Text('Informations personnelles', style: AppTextStyles.headingSmall),
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
                        const Text('Modifiez vos informations officielles', style: AppTextStyles.bodySmall),
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

                        Text('Genre *', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
                        const SizedBox(height: AppDimensions.sp6),
                        Row(
                          children: [
                            Expanded(
                              child: GenreTile(
                                label: 'Homme',
                                isSelected: _selectedSex == 'HOMME',
                                onTap: () => setState(() => _selectedSex = 'HOMME'),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sp12),
                            Expanded(
                              child: GenreTile(
                                label: 'Femme',
                                isSelected: _selectedSex == 'FEMME',
                                onTap: () => setState(() => _selectedSex = 'FEMME'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SDateField(
                                label: 'Date de naissance *',
                                hint: '15/03/2000',
                                selectedDate: _selectedDate,
                                onDateSelected: (date) => setState(() => _selectedDate = date),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sp12),
                            Expanded(
                              child: SField(
                                label: 'Lieu de naissance *',
                                hint: 'Dakar',
                                controller: _placeOfBirthController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        Theme(
                          data: Theme.of(context).copyWith(disabledColor: AppColors.neutral100),
                          child: SField(
                            label: 'Numéro CIN (Non modifiable)',
                            hint: '1456199900268',
                            controller: _cinController,
                            readOnly: true,
                            enabled: false,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        SField(
                          label: 'Adresse de résidence *',
                          hint: 'Scat Urbam N° E55',
                          controller: _addressController,
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        // Région
                        SSearchableDropdown<dynamic>(
                          label: 'Région *',
                          pickerTitle: 'Sélectionner une région',
                          searchHint: 'Rechercher une région...',
                          value: selectedRegion != null ? _cleanGeoName(selectedRegion.name) : '',
                          currentValue: selectedRegion,
                          options: refState.regions,
                          labelExtractor: (region) => _cleanGeoName(region.name),
                          onSelected: (region) {
                            setState(() {
                              _selectedRegionId = region.id;
                              _selectedDepartmentId = null;
                            });
                            ref.read(profileReferencesNotifierProvider.notifier).loadCascadeDepartments(region.id);
                          },
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        // Département (dépend de la région)
                        SSearchableDropdown<dynamic>(
                          label: 'Département *',
                          pickerTitle: 'Sélectionner un département',
                          searchHint: 'Rechercher un département...',
                          enabled: hasSelectedRegion,
                          disabledHint: 'Choisir une région d\'abord',
                          value: selectedDepartment != null ? _cleanGeoName(selectedDepartment.name) : '',
                          currentValue: selectedDepartment,
                          options: refState.departments,
                          labelExtractor: (dept) => _cleanGeoName(dept.name),
                          onSelected: (dept) => setState(() => _selectedDepartmentId = dept.id),
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        // Nationalité
                        SSearchableDropdown<dynamic>(
                          label: 'Nationalité *',
                          pickerTitle: 'Sélectionner une nationalité',
                          searchHint: 'Rechercher une nationalité...',
                          value: selectedNationality != null ? selectedNationality.name : '',
                          currentValue: selectedNationality,
                          options: refState.nationalities,
                          labelExtractor: (nationality) => nationality.name,
                          onSelected: (nationality) => setState(() => _selectedNationalityId = nationality.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(AppDimensions.sp20, AppDimensions.sp14, AppDimensions.sp20, AppDimensions.sp24),
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