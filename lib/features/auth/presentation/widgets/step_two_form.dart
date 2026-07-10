// features/auth/presentation/widgets/step_two_form.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

import '../providers/registration_provider.dart';

class StepTwoForm extends ConsumerWidget {
  const StepTwoForm({super.key});

  /// Méthode pour afficher les options de capture/sélection
  void _showPickOptions(BuildContext context, WidgetRef ref, {required bool isRecto}) {
    final notifier = ref.read(registrationNotifierProvider.notifier);
    final picker = ImagePicker();

    Future<void> pickImage(ImageSource source) async {
      Navigator.pop(context);
      try {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 80, 
          maxWidth: 1920,
        );

        if (pickedFile != null) {
          if (isRecto) {
            notifier.updateRecto(pickedFile.path);
          } else {
            notifier.updateVerso(pickedFile.path);
          }
        }
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.sp20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRecto ? 'Ajouter le RECTO du document' : 'Ajouter le VERSO du document',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutral800),
                ),
                const SizedBox(height: AppDimensions.sp16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.secondary600),
                  title: const Text('Prendre une photo', style: AppTextStyles.bodyMedium),
                  onTap: () => pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.secondary600),
                  title: const Text('Choisir depuis la galerie', style: AppTextStyles.bodyMedium),
                  onTap: () => pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(registrationNotifierProvider);
    final notifier = ref.read(registrationNotifierProvider.notifier);

    final isCni = formState.documentType == 'CNI';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pièce justificative', style: AppTextStyles.headingSmall),
        const SizedBox(height: AppDimensions.sp4),
        const Text('Veuillez fournir un document d\'identité valide.', style: AppTextStyles.bodySmall),
        const SizedBox(height: AppDimensions.sp24),

        // Menu de sélection du type de document
        Text('Type de document *', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        DropdownButtonFormField<String>(
          value: formState.documentType.isNotEmpty ? formState.documentType : 'CNI',
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.border, width: AppDimensions.borderThin),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.secondary600, width: AppDimensions.borderMedium),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'CNI', child: Text('Carte Nationale d\'Identité (CNI)', style: TextStyle(fontSize: 14))),
            DropdownMenuItem(value: 'PASSPORT', child: Text('Passeport', style: TextStyle(fontSize: 14))),
          ],
          onChanged: (val) {
            if (val != null) notifier.changeDocumentType(val);
          },
        ),
        const SizedBox(height: AppDimensions.sp24),

        // Affichage dynamique en fonction du type sélectionné
        if (isCni) ...[
          Row(
            children: [
              Expanded(
                child: _UploadCard(
                  label: 'Recto de la CNI *',
                  filePath: formState.documentPathRecto,
                  onTap: () => _showPickOptions(context, ref, isRecto: true),
                  onDelete: () => notifier.updateRecto(null),
                ),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                child: _UploadCard(
                  label: 'Verso de la CNI *',
                  filePath: formState.documentPathVerso,
                  onTap: () => _showPickOptions(context, ref, isRecto: false),
                  onDelete: () => notifier.updateVerso(null),
                ),
              ),
            ],
          ),
        ] else ...[
          _UploadCard(
            label: 'Page principale du Passeport *',
            filePath: formState.documentPathRecto,
            onTap: () => _showPickOptions(context, ref, isRecto: true),
            onDelete: () => notifier.updateRecto(null),
          ),
        ],
      ],
    );
  }
}

/// Widget interne réutilisable pour le conteneur d'upload
class _UploadCard extends StatelessWidget {
  final String label;
  final String? filePath;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _UploadCard({
    required this.label,
    required this.filePath,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFile = filePath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.sp24, horizontal: AppDimensions.sp12),
            decoration: BoxDecoration(
              color: hasFile ? AppColors.primary50.withValues(alpha: 0.3) : AppColors.neutral50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                color: hasFile ? AppColors.primary600 : AppColors.neutral300,
                width: hasFile ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                if (hasFile) ...[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary600, width: 2),
                      image: DecorationImage(
                        image: FileImage(File(filePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp10),
                  Text(
                    filePath!.split('/').last,
                    style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ] else ...[
                  const Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.neutral400),
                  const SizedBox(height: AppDimensions.sp8),
                  const Text(
                    'Ajouter',
                    style: TextStyle(fontSize: 13, color: AppColors.neutral600, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}