import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
import 'package:sime_v2/core/providers/scan_result_provider.dart';
import 'package:sime_v2/core/services/scanned_document.dart';

class StepOneForm extends ConsumerStatefulWidget {
  const StepOneForm({super.key, this.selectedGenre, this.onGenreChanged});

  final String? selectedGenre;
  final ValueChanged<String>? onGenreChanged;

  @override
  ConsumerState<StepOneForm> createState() => _StepOneFormState();
}

class _StepOneFormState extends ConsumerState<StepOneForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cinController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final result = ref.read(scanResultProvider);
      debugPrint('📄 Résultat du scan dans StepOneForm: $result');
      if (result != null) {
        _fillFormWithScan(result);
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cinController.dispose();
    _placeOfBirthController.dispose();
    super.dispose();
  }

  void _fillFormWithScan(ScannedDocument document) {
    if (document.firstName != null) {
      _firstNameController.text = document.firstName!;
    }
    if (document.lastName != null) {
      _lastNameController.text = document.lastName!;
    }
    if (document.nationalId != null) {
      _cinController.text = document.nationalId!;
    }
    if (document.placeOfBirth != null) {
      _placeOfBirthController.text = document.placeOfBirth!;
    }

    if (document.dateOfBirth != null) {
      setState(() {
        _selectedDate = document.dateOfBirth;
      });
    }

    if (document.sex != null) {
      final sexUpper = document.sex!.toUpperCase();
      if (sexUpper == 'M' || sexUpper == 'HOMME') {
        widget.onGenreChanged?.call('M');
      } else if (sexUpper == 'F' || sexUpper == 'FEMME') {
        widget.onGenreChanged?.call('F');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Informations personnelles',
              style: AppTextStyles.headingSmall,
            ),
            IconButton(
              icon: const Icon(
                Icons.document_scanner_outlined,
                color: AppColors.primary900,
              ),
              tooltip: 'Scanner la pièce d’identité',
              onPressed: () async {
                context.push(AppRoutes.identityScanner);
              },
            ),
          ],
        ),
        const Text(
          'Tous les champs * sont obligatoires',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppDimensions.sp24),

        Row(
          children: [
            Expanded(
              child: SField(
                controller: _firstNameController,
                label: 'Prénom *',
                hint: 'Mamadou',
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: SField(
                controller: _lastNameController,
                label: 'Nom *',
                hint: 'Aidara',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp14),

        // ─── SÉLECTEUR DE GENRE AMÉLIORÉ INTEGRÉ ───
        Text(
          'Genre *',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800),
        ),
        const SizedBox(height: AppDimensions.sp6),
        Row(
          children: [
            Expanded(
              child: _GenreSelectorTile(
                label: 'Homme',
                isSelected: widget.selectedGenre == 'M',
                onTap: () => widget.onGenreChanged?.call('M'),
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: _GenreSelectorTile(
                label: 'Femme',
                isSelected: widget.selectedGenre == 'F',
                onTap: () => widget.onGenreChanged?.call('F'),
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
                },
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: SField(
                controller: _placeOfBirthController,
                label: 'Lieu de naissance *',
                hint: 'Dakar',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp14),
        const SPhoneField(
          label: 'Numéro de téléphone *',
        ),
        const SizedBox(height: AppDimensions.sp14),
        SField(
          controller: _cinController,
          label: 'Numéro CIN',
          hint: '1234567890123',
          hint2: '13 caractères sans espaces',
        ),
        const SizedBox(height: AppDimensions.sp14),
        const Row(
          children: [
            Expanded(child: SDropdown(label: 'Région *', value: 'Dakar')),
            SizedBox(width: AppDimensions.sp12),
            Expanded(child: SDropdown(label: 'Département *', value: 'Dakar')),
          ],
        ),
        const SizedBox(height: AppDimensions.sp14),
        const SDropdown(label: 'Nationalité', value: '🇸🇳 Sénégalaise'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPOSANT : Genre Selector Tile (Background Blanc / Marron Secondary800)
// ─────────────────────────────────────────────────────────────────────────────
class _GenreSelectorTile extends StatelessWidget {
  const _GenreSelectorTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
            width: isSelected ? AppDimensions.borderMedium : AppDimensions.borderThin,
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