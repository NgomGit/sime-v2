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
import 'package:sime_v2/core/services/scanned_document.dart'; // Utile pour formater la date de naissance

class StepOneForm extends ConsumerStatefulWidget {
  const StepOneForm({super.key, this.selectedGenre, this.onGenreChanged});

  final String? selectedGenre;
  final ValueChanged<String>? onGenreChanged;

  @override
  ConsumerState<StepOneForm> createState() => _StepOneFormState();
}

class _StepOneFormState extends ConsumerState<StepOneForm> {
  // 1. Déclaration des contrôleurs pour l'auto-remplissage
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _cinController = TextEditingController();
  final _placeOfBirthController = TextEditingController();

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
    // Toujours libérer les contrôleurs
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _cinController.dispose();
    _placeOfBirthController.dispose();
    super.dispose();
  }

  // 2. Fonction qui applique les données du scan aux contrôleurs
  void _fillFormWithScan(ScannedDocument document) {
    if (document.firstName != null) {
      _firstNameController.text = document.firstName!;
    }
    if (document.lastName != null) {
      _lastNameController.text = document.lastName!;
    }
    if (document.nationalId != null) _cinController.text = document.nationalId!;
    if (document.placeOfBirth != null) {
      // Applique le lieu de naissance
      // _placeOfBirthController.text = document.placeOfBirth!;
    }

    if (document.placeOfBirth != null) {
      // Applique le lieu de naissance
      _placeOfBirthController.text = document.placeOfBirth!;
    }

    if (document.dateOfBirth != null) {
      // Formate la date en JJ/MM/AAAA pour correspondre au hint
      _dobController.text =
          DateFormat('dd/MM/yyyy').format(document.dateOfBirth!);
    }

    if (document.sex != null) {
      // Adapte le genre si besoin (Ex: "M" -> "Homme", "F" -> "Femme")
      if (document.sex == 'M' || document.sex?.toLowerCase() == 'homme') {
        widget.onGenreChanged?.call('Homme');
      } else if (document.sex == 'F' ||
          document.sex?.toLowerCase() == 'femme') {
        widget.onGenreChanged?.call('Femme');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3. Titre + Icône de Scan à droite
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Informations personnelles',
              style: AppTextStyles.headingSmall,
            ),
            IconButton(
              icon: const Icon(
                Icons
                    .document_scanner_outlined, // Ou Icons.camera_alt_outlined selon votre design
                color: AppColors.primary900,
              ),
              tooltip: 'Scanner la pièce d’identité',
              onPressed: () async {
                // Déclenchez ici la navigation vers votre écran de scan de votre choix
                // Navigator.push(...);
                context.push(AppRoutes.identityScanner);
                // Exemple avec go_router

                // Une fois le scan terminé, on récupère le résultat du provider
                // final scanResult = ref.read(scanResultProvider);
                // if (scanResult != null && !scanResult.isEmpty) {
                //   _fillFormWithScan(scanResult);

                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //         content: Text('Formulaire auto-rempli avec succès !')),
                //   );
                // }
              },
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sp4),
        const Text('Tous les champs * sont obligatoires',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: AppDimensions.sp24),

        // 4. Passage des contrôleurs aux composants SField
        Row(children: [
          Expanded(
            child: SField(
              controller: _firstNameController, // <-- Ajouté
              label: 'Prénom *',
              hint: 'Mamadou',
            ),
          ),
          const SizedBox(width: AppDimensions.sp12),
          Expanded(
            child: SField(
              controller: _lastNameController, // <-- Ajouté
              label: 'Nom *',
              hint: 'Aidara',
            ),
          ),
        ]),
        const SizedBox(height: AppDimensions.sp14),

        Text('Genre *',
            style:
                AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        Row(
            children: ['Homme', 'Femme'].map((g) {
          final sel = widget.selectedGenre ==
              g; // Notez l'utilisation de widget.selectedGenre
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onGenreChanged?.call(g),
              child: Container(
                margin: EdgeInsets.only(right: g == 'Homme' ? 8 : 0),
                height: 46,
                decoration: BoxDecoration(
                  color: sel ? AppColors.white : AppColors.neutral50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: sel ? AppColors.primary900 : AppColors.border,
                    width: sel
                        ? AppDimensions.borderMedium
                        : AppDimensions.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  g,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: sel ? AppColors.primary900 : AppColors.neutral400,
                  ),
                ),
              ),
            ),
          );
        }).toList()),
        const SizedBox(height: AppDimensions.sp14),
        Row(children: [
          Expanded(
              child: SField(
                  controller: _dobController, // <-- Ajouté
                  label: 'Date de naissance *',
                  hint: '15/03/2000',
                  isValid: true)),
          const SizedBox(width: AppDimensions.sp12),
          Expanded(
              child: SField(
                  controller: _placeOfBirthController,
                  label: 'Lieu de naissance *',
                  hint: 'Dakar')),
        ]),
        const SizedBox(height: AppDimensions.sp14),
        const SPhoneField(
          label: 'Numéro de téléphone *',
        ),
        const SizedBox(height: AppDimensions.sp14),
        SField(
            controller: _cinController, // <-- Ajouté
            label: 'Numéro CIN',
            hint: '1234567890123',
            hint2: '13 caractères sans espaces'),
        const SizedBox(height: AppDimensions.sp14),
        const Row(children: [
          Expanded(child: SDropdown(label: 'Région *', value: 'Dakar')),
          SizedBox(width: AppDimensions.sp12),
          Expanded(child: SDropdown(label: 'Département *', value: 'Dakar')),
        ]),
        const SizedBox(height: AppDimensions.sp14),
        const SDropdown(label: 'Nationalité', value: '🇸🇳 Sénégalaise'),
      ],
    );
  }
}
