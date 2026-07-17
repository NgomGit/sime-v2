// features/profile/presentation/screens/edit_identity_informations.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

/// Écran d'édition des informations d'identité du candidat : date/lieu de
/// naissance, adresse, région/département/commune de résidence et
/// nationalité.
///
/// Ces champs correspondent au payload envoyé par
/// [ApplicantNotifier.updateProfileFields] (PATCH
/// /applicant/api/applicants/me/{id}). Les champs "compte utilisateur"
/// (prénom, nom, téléphone, genre) sont gérés séparément par
/// `EditAccountFieldsScreen`, et la pièce d'identité (type, numéro, scans
/// recto/verso) par `EditIdentityDocumentScreen`.
class EditIdentityInformationsScreen extends ConsumerStatefulWidget {
  const EditIdentityInformationsScreen({super.key});

  @override
  ConsumerState<EditIdentityInformationsScreen> createState() =>
      _EditIdentityInformationsScreenState();
}

class _EditIdentityInformationsScreenState
    extends ConsumerState<EditIdentityInformationsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _placeOfBirthController;
  late final TextEditingController _addressController;

  DateTime? _selectedDate;
  int? _selectedRegionId;
  int? _selectedDepartmentId;
  int? _selectedMunicipalityId;
  int? _selectedNationalityId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final applicant = ref.read(applicantNotifierProvider).applicant;

    _placeOfBirthController =
        TextEditingController(text: applicant?.placeBirth ?? '');
    _addressController = TextEditingController(text: applicant?.address ?? '');

    _selectedRegionId = applicant?.residRegion?.id;
    _selectedDepartmentId = applicant?.residDepartment?.id;
    _selectedMunicipalityId = applicant?.residMunicipality?.id;
    _selectedNationalityId = applicant?.nationality?.id;

    if (applicant?.dateBirth != null && applicant!.dateBirth.isNotEmpty) {
      _selectedDate = DateTime.tryParse(applicant.dateBirth);
    }

    // Amorce des cascades géographiques si des données initiales existent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedRegionId != null && _selectedRegionId != 0) {
        ref
            .read(profileReferencesNotifierProvider.notifier)
            .loadCascadeDepartments(_selectedRegionId!);
      }
      if (_selectedDepartmentId != null && _selectedDepartmentId != 0) {
        ref
            .read(profileReferencesNotifierProvider.notifier)
            .loadCascadeMunicipalities(_selectedDepartmentId!);
      }
    });
  }

  @override
  void dispose() {
    _placeOfBirthController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Nettoie les libellés géographiques mal encodés (mojibake)
  String _cleanGeoName(String name) {
    return name
        .replaceAll('RanÃ©rou', 'Ranérou')
        .replaceAll('KÃ©dougou', 'Kédougou');
  }

  Future<void> _saveIdentity() async {
    final applicant = ref.read(applicantNotifierProvider).applicant;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, dynamic> fieldsToUpdate = {
      'placeBirth': _placeOfBirthController.text.trim(),
      'dateBirth': _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null,
      'residAddress': _addressController.text.trim(),
      'regionId': _selectedRegionId,
      'departmentId': _selectedDepartmentId,
      'municipalityId': _selectedMunicipalityId,
      'nationalityId': _selectedNationalityId,
      'identities': applicant?.identities ?? [],
    };

    final success = await ref
        .read(applicantNotifierProvider.notifier)
        .updateProfileFields(fieldsToUpdate);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        AppStatusDialog.show(
          context,
          title: 'Identité mise à jour',
          message: 'Informations d\'identité mises à jour avec succès',
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
    final hasSelectedRegion =
        _selectedRegionId != null && _selectedRegionId != 0;
    final hasSelectedDepartment =
        _selectedDepartmentId != null && _selectedDepartmentId != 0;

    // Résolution des objets sélectionnés à partir des IDs stockés
    final selectedRegion =
        refState.regions.where((r) => r.id == _selectedRegionId).firstOrNull;
    final selectedDepartment = refState.departments
        .where((d) => d.id == _selectedDepartmentId)
        .firstOrNull;
    final selectedMunicipality = refState.municipalities
        .where((m) => m.id == _selectedMunicipalityId)
        .firstOrNull;
    final selectedNationality = refState.nationalities
        .where((n) => n.id == _selectedNationalityId)
        .firstOrNull;

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
          title: const Text('Informations d\'identité',
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
                        const Text('Modifiez vos informations officielles',
                            style: AppTextStyles.bodySmall),
                        const SizedBox(height: AppDimensions.sp24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SDateField(
                                label: 'Date de naissance *',
                                hint: '15/03/2000',
                                selectedDate: _selectedDate,
                                onDateSelected: (date) =>
                                    setState(() => _selectedDate = date),
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

                        // _IdentityDocumentBanner(
                        //   onTap: () => context.push(AppRoutes.editIdentityDocument),
                        // ),
                        // const SizedBox(height: AppDimensions.sp14),

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
                          value: selectedRegion != null
                              ? _cleanGeoName(selectedRegion.name)
                              : '',
                          currentValue: selectedRegion,
                          options: refState.regions,
                          labelExtractor: (region) =>
                              _cleanGeoName(region.name),
                          onSelected: (region) {
                            setState(() {
                              _selectedRegionId = region.id;
                              _selectedDepartmentId = null;
                            });
                            ref
                                .read(
                                    profileReferencesNotifierProvider.notifier)
                                .loadCascadeDepartments(region.id);
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
                          value: selectedDepartment != null
                              ? _cleanGeoName(selectedDepartment.name)
                              : '',
                          currentValue: selectedDepartment,
                          options: refState.departments,
                          labelExtractor: (dept) => _cleanGeoName(dept.name),
                          onSelected: (dept) {
                            setState(() {
                              _selectedDepartmentId = dept.id;
                              _selectedMunicipalityId = null;
                            });
                            ref
                                .read(
                                    profileReferencesNotifierProvider.notifier)
                                .loadCascadeMunicipalities(dept.id);
                          },
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        // Commune (dépend du département)
                        SSearchableDropdown<dynamic>(
                          label: 'Commune *',
                          pickerTitle: 'Sélectionner une commune',
                          searchHint: 'Rechercher une commune...',
                          enabled: hasSelectedDepartment,
                          disabledHint: 'Choisir un département d\'abord',
                          value: selectedMunicipality != null
                              ? _cleanGeoName(selectedMunicipality.name)
                              : '',
                          currentValue: selectedMunicipality,
                          options: refState.municipalities,
                          labelExtractor: (municipality) =>
                              _cleanGeoName(municipality.name),
                          onSelected: (municipality) => setState(
                              () => _selectedMunicipalityId = municipality.id),
                        ),
                        const SizedBox(height: AppDimensions.sp14),

                        // Nationalité
                        SSearchableDropdown<dynamic>(
                          label: 'Nationalité *',
                          pickerTitle: 'Sélectionner une nationalité',
                          searchHint: 'Rechercher une nationalité...',
                          value: selectedNationality != null
                              ? selectedNationality.name
                              : '',
                          currentValue: selectedNationality,
                          options: refState.nationalities,
                          labelExtractor: (nationality) => nationality.name,
                          onSelected: (nationality) => setState(
                              () => _selectedNationalityId = nationality.id),
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
                        onPressed: _isLoading ? null : _saveIdentity,
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

/// Bandeau invitant à gérer la pièce d'identité (CNI/Passeport) sur son
/// écran dédié plutôt qu'ici. Évite d'afficher un champ CNI "figé" qui prête
/// à confusion sur ce qui est réellement modifiable depuis cet écran.
class _IdentityDocumentBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _IdentityDocumentBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sp14,
          vertical: AppDimensions.sp12,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondary100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.badge_outlined,
                  size: AppDimensions.iconSM, color: AppColors.secondary600),
            ),
            const SizedBox(width: AppDimensions.sp10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.neutral600),
                  children: [
                    const TextSpan(
                        text: 'CNI et documents désormais gérés dans '),
                    TextSpan(
                      text: 'Pièce d\'identité',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondary600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: AppDimensions.iconSM, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }
}
