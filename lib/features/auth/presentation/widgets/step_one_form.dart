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

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(registrationNotifierProvider);
    final notifier = ref.read(registrationNotifierProvider.notifier);

    // Détermination de l'activation du dropdown département
    final hasSelectedRegion = formState.residRegionId != 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Informations personnelles',
                style: AppTextStyles.headingSmall),
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined,
                  color: AppColors.primary900),
              tooltip: 'Scanner la pièce d’identité',
              onPressed: () => context.push(AppRoutes.identityScanner),
            ),
          ],
        ),
        const Text('Tous les champs * sont obligatoires',
            style: AppTextStyles.bodySmall),
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
        Text('Genre *',
            style:
                AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        Row(
          children: [
            Expanded(
              child: _GenreTile(
                label: 'Homme',
                isSelected: formState.sex == 'HOMME',
                onTap: () => notifier.updateField(sex: 'HOMME'),
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: _GenreTile(
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
                  notifier.updateField(
                      dateBirth: DateFormat('yyyy-MM-dd').format(date));
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

        // ─── BLOC RÉGIONS & DÉPARTEMENTS EN CASCADE ───
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown des Régions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Région *',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.neutral800)),
                  const SizedBox(height: AppDimensions.sp6),
                  DropdownButtonFormField<int>(
                    isExpanded: true, // 👈 Empêche l'overflow à droite
                    value: formState.regions
                            .any((r) => r.id == formState.residRegionId)
                        ? formState.residRegionId
                        : null,
                    hint: const Text('Sélectionner',
                        style: TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                    decoration: _buildDropdownDecoration(),
                    items: formState.regions.map((region) {
                      return DropdownMenuItem<int>(
                        value: region.id,
                        child: Text(
                          region.name,
                          style: const TextStyle(fontSize: 13),
                          overflow:
                              TextOverflow.ellipsis, // 👈 Tronque proprement
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) notifier.onRegionChanged(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),

            // Dropdown des Départements
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Département *',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.neutral800)),
                  const SizedBox(height: AppDimensions.sp6),
                  DropdownButtonFormField<int>(
                    isExpanded: true, // 👈 Empêche l'overflow à droite
                    value: formState.departments.any((d) =>
                            d.id == formState.residDepartmentId &&
                            (d.region?.id == formState.residRegionId ||
                                formState.residRegionId == 0))
                        ? formState.residDepartmentId
                        : null,
                    hint: const Text('Sélectionner',
                        style: TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                    disabledHint: const Text('Choisir région',
                        style: TextStyle(
                            color: AppColors.neutral400, fontSize: 13)),
                    decoration:
                        _buildDropdownDecoration(isEnabled: hasSelectedRegion),
                    // Côté client : On filtre pour s'assurer qu'aucun département parasite d'une autre région ne s'affiche
                    items: hasSelectedRegion
                        ? formState.departments
                            .where((dept) =>
                                dept.region?.id ==
                                formState
                                    .residRegionId) // 👈 Sécurité de filtrage local
                            .map((dept) {
                            return DropdownMenuItem<int>(
                              value: dept.id,
                              child: Text(
                                // Optionnel : correction à la volée des caractères cassés si nécessaire, ex: .replaceAll('RanÃ©rou', 'Ranérou')
                                dept.name
                                    .replaceAll('RanÃ©rou', 'Ranérou')
                                    .replaceAll('KÃ©dougou', 'Kédougou'),
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList()
                        : null,
                    onChanged: hasSelectedRegion
                        ? (value) {
                            if (value != null) {
                              notifier.onDepartmentChanged(value);
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp14),

        // ─── DROPDOWN NATIONALITÉS ───
        Text('Nationalité *',
            style:
                AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        DropdownButtonFormField<int>(
          initialValue: formState.nationalities
                  .any((n) => n.id == formState.nationalityId)
              ? formState.nationalityId
              : null,
          hint: const Text('Sélectionner votre nationalité',
              style: TextStyle(fontSize: 14)),
          decoration: _buildDropdownDecoration(),
          items: formState.nationalities.map((nationality) {
            return DropdownMenuItem<int>(
              value: nationality.id,
              child:
                  Text(nationality.name, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) notifier.updateField(nationalityId: value);
          },
        ),
      ],
    );
  }

  /// Décoration unifiée calquée sur tes tokens graphiques ANPEJ
  InputDecoration _buildDropdownDecoration({bool isEnabled = true}) {
    return InputDecoration(
      filled: true,
      isDense: true, // 👈 Force un layout compact et propre
      fillColor: isEnabled ? AppColors.neutral50 : AppColors.neutral100,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sp12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(
            color: AppColors.border, width: AppDimensions.borderThin),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(
            color: AppColors.secondary600, width: AppDimensions.borderMedium),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(
            color: AppColors.border, width: AppDimensions.borderThin),
      ),
    );
  }
}

class _GenreTile extends StatelessWidget {
  const _GenreTile(
      {required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: AppDimensions.inputHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary800 : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.secondary800 : AppColors.border,
            width: isSelected
                ? AppDimensions.borderMedium
                : AppDimensions.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.neutral600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
