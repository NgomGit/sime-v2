// features/auth/presentation/widgets/step_one_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
import 'package:sime_v2/core/design_system/widgets/s_genre_tile.dart';
import 'package:sime_v2/core/design_system/widgets/s_searchable_dropdown.dart';
import 'package:sime_v2/core/providers/scan_result_provider.dart';
import 'package:sime_v2/core/services/scanned_document.dart';
import '../providers/registration_provider.dart';

class StepOneForm extends ConsumerStatefulWidget {
  const StepOneForm({super.key});

  @override
  ConsumerState<StepOneForm> createState() => _StepOneFormState();
}

class _StepOneFormState extends ConsumerState<StepOneForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cinController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final cached = ref.read(registrationNotifierProvider);
    _firstNameController.text = cached.firstName;
    _lastNameController.text = cached.lastName;
    _cinController.text = cached.cni;
    _placeOfBirthController.text = cached.placeBirth;
    _addressController.text = cached.residAddress;
    if (cached.dateBirth != null) {
      _selectedDate = DateTime.tryParse(cached.dateBirth!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final result = ref.read(scanResultProvider);
      if (result != null) _fillFormWithScan(result);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cinController.dispose();
    _placeOfBirthController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _fillFormWithScan(ScannedDocument document) {
    if (document.firstName != null) {
      _firstNameController.text = document.firstName!;
    }
    if (document.lastName != null) {
      _lastNameController.text = document.lastName!;
    }
    if (document.nationalId != null) _cinController.text = document.nationalId!;
    if (document.placeOfBirth != null) {
      _placeOfBirthController.text = document.placeOfBirth!;
    }
    if (document.dateOfBirth != null) {
      setState(() => _selectedDate = document.dateOfBirth);
    }

    String resolvedSex = 'HOMME';
    if (document.sex != null) {
      final sexUpper = document.sex!.toUpperCase();
      if (sexUpper == 'F' || sexUpper == 'FEMME' || sexUpper == 'FEMININ') {
        resolvedSex = 'FEMME';
      }
    }

    ref.read(registrationNotifierProvider.notifier).updateField(
          firstName: document.firstName,
          lastName: document.lastName,
          cni: document.nationalId,
          placeBirth: document.placeOfBirth,
          dateBirth: document.dateOfBirth != null
              ? DateFormat('yyyy-MM-dd').format(document.dateOfBirth!)
              : null,
          sex: resolvedSex,
        );
  }

  /// Nettoie les libellés géographiques mal encodés (mojibake)
  String _cleanGeoName(String name) {
    return name.replaceAll('RanÃ©rou', 'Ranérou').replaceAll('KÃ©dougou', 'Kédougou');
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(registrationNotifierProvider);
    final notifier = ref.read(registrationNotifierProvider.notifier);

    final hasSelectedRegion = formState.residRegionId != 0;

    // Résolution des objets sélectionnés à partir des IDs stockés dans le state
    final selectedRegion = formState.regions
        .where((r) => r.id == formState.residRegionId)
        .firstOrNull;

    // Départements filtrés pour la région active, comme dans la logique d'origine
    final filteredDepartments = hasSelectedRegion
        ? formState.departments.where((dept) => dept.region?.id == formState.residRegionId).toList()
        : <dynamic>[];

    final selectedDepartment = filteredDepartments
        .where((d) => d.id == formState.residDepartmentId)
        .firstOrNull;

    final selectedNationality = formState.nationalities
        .where((n) => n.id == formState.nationalityId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Informations personnelles', style: AppTextStyles.headingSmall),
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined, color: AppColors.primary900),
              tooltip: 'Scanner la pièce d’identité',
              onPressed: () => context.push(AppRoutes.identityScanner),
            ),
          ],
        ),
        const Text('Tous les champs * sont obligatoires', style: AppTextStyles.bodySmall),
        const SizedBox(height: AppDimensions.sp24),
        Row(
          children: [
            Expanded(
              child: SField(
                controller: _firstNameController,
                label: 'Prénom *',
                hint: 'Mamadou',
                onChanged: (val) => notifier.updateField(firstName: val),
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: SField(
                controller: _lastNameController,
                label: 'Nom *',
                hint: 'Diallo',
                onChanged: (val) => notifier.updateField(lastName: val),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp14),
        Text('Genre *', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        Row(
          children: [
            Expanded(
              child: GenreTile(
                label: 'Homme',
                isSelected: formState.sex == 'HOMME',
                onTap: () => notifier.updateField(sex: 'HOMME'),
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: GenreTile(
                label: 'Femme',
                isSelected: formState.sex == 'FEMME',
                onTap: () => notifier.updateField(sex: 'FEMME'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp14),
        Row(
          children: [
            Expanded(
              child: SDateField(
                label: 'Date de naissance *',
                hint: '15/03/2000',
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                  notifier.updateField(dateBirth: DateFormat('yyyy-MM-dd').format(date));
                },
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: SField(
                controller: _placeOfBirthController,
                label: 'Lieu de naissance *',
                hint: 'Dakar',
                onChanged: (val) => notifier.updateField(placeBirth: val),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp14),
        SField(
          controller: _cinController,
          label: 'Numéro CIN *',
          hint: '1456199900268',
          onChanged: (val) => notifier.updateField(cni: val),
        ),
        const SizedBox(height: AppDimensions.sp14),
        SField(
          controller: _addressController,
          label: 'Adresse de résidence *',
          hint: 'Senegal Dakar Scat urbam N° E55',
          onChanged: (val) => notifier.updateField(residAddress: val),
        ),
        const SizedBox(height: AppDimensions.sp14),

        // ─── RÉGION ───
        SSearchableDropdown<dynamic>(
          label: 'Région *',
          pickerTitle: 'Sélectionner une région',
          searchHint: 'Rechercher une région...',
          leadingIcon: Icons.map_outlined,
          value: selectedRegion != null ? _cleanGeoName(selectedRegion.name) : '',
          currentValue: selectedRegion,
          options: formState.regions,
          labelExtractor: (region) => _cleanGeoName(region.name),
          onSelected: (region) => notifier.onRegionChanged(region.id),
        ),
        const SizedBox(height: AppDimensions.sp14),

        // ─── DÉPARTEMENT (dépend de la région) ───
        SSearchableDropdown<dynamic>(
          label: 'Département *',
          pickerTitle: 'Sélectionner un département',
          searchHint: 'Rechercher un département...',
          leadingIcon: Icons.location_city_outlined,
          enabled: hasSelectedRegion,
          disabledHint: 'Choisir une région d\'abord',
          value: selectedDepartment != null ? _cleanGeoName(selectedDepartment.name) : '',
          currentValue: selectedDepartment,
          options: filteredDepartments,
          labelExtractor: (dept) => _cleanGeoName(dept.name),
          onSelected: (dept) => notifier.onDepartmentChanged(dept.id),
        ),
        const SizedBox(height: AppDimensions.sp14),

        // ─── NATIONALITÉ ───
        SSearchableDropdown<dynamic>(
          label: 'Nationalité *',
          pickerTitle: 'Sélectionner une nationalité',
          searchHint: 'Rechercher une nationalité...',
          leadingIcon: Icons.flag_outlined,
          value: selectedNationality != null ? selectedNationality.name : '',
          currentValue: selectedNationality,
          options: formState.nationalities,
          labelExtractor: (nationality) => nationality.name,
          onSelected: (nationality) => notifier.updateField(nationalityId: nationality.id),
        ),
      ],
    );
  }
}