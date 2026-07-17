// features/profile/presentation/screens/edit_identity_document.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
import 'package:sime_v2/core/design_system/widgets/app_status_dialog.dart';
import 'package:sime_v2/core/design_system/widgets/s_app_back_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_overlay_loader.dart';
import 'package:sime_v2/core/utils/file_utils.dart';
import 'package:sime_v2/features/profile/domain/entities/applicant_entity.dart';
import 'package:sime_v2/features/profile/presentation/providers/applicant_notifier.dart';

/// Écran dédié à la pièce d'identité du candidat (CNI ou Passeport) : type
/// de document, numéro, et scans recto/verso.
///
/// Reprend le pattern déjà éprouvé de l'étape 2 de l'inscription
/// (`step_two_form.dart`) plutôt que d'inventer un nouveau composant
/// d'upload : sélecteur de type, puis cartes recto/verso avec le même
/// bottom sheet caméra/galerie.
///
/// Mettre à jour sa pièce d'identité implique de fournir à nouveau les
/// scans (recto/verso), même si seul le numéro change : l'API ne renvoie
/// pas de moyen de "garder les fichiers existants tels quels" pour ce
/// PATCH (voir [ApplicantNotifier.updateProfileFields]), donc republier
/// l'intégralité du document à chaque modification est le choix le plus
/// sûr — c'est aussi exactement ce que fait déjà l'inscription.
class EditIdentityDocumentScreen extends ConsumerStatefulWidget {
  const EditIdentityDocumentScreen({super.key});

  @override
  ConsumerState<EditIdentityDocumentScreen> createState() =>
      _EditIdentityDocumentScreenState();
}

class _EditIdentityDocumentScreenState
    extends ConsumerState<EditIdentityDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberController;

  String _documentType = 'CNI';
  String? _rectoPath;
  String? _versoPath;

  /// Document actuellement enregistré côté serveur, s'il existe — affiché à
  /// titre de rappel ("Document actuel") tant que l'utilisateur n'a pas
  /// commencé à en téléverser un nouveau.
  ApplicantIdentityEntity? _existingIdentity;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final applicant = ref.read(applicantNotifierProvider).applicant;
    _existingIdentity = applicant?.identities.isNotEmpty == true
        ? applicant!.identities.first
        : null;

    _documentType = _existingIdentity?.isPassport == true ? 'PASSPORT' : 'CNI';
    _numberController =
        TextEditingController(text: _existingIdentity?.value ?? '');
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  bool get _isCni => _documentType == 'CNI';

  /// Url du scan existant à afficher en aperçu pour le côté demandé, tant
  /// qu'aucun nouveau fichier n'a été choisi.
  String? _existingUrlFor({required bool isRecto}) {
    final urls = _existingIdentity?.fileUrls ?? const [];
    final index = isRecto ? 0 : 1;
    return index < urls.length ? urls[index] : null;
  }

  Future<void> _pickImage(ImageSource source, {required bool isRecto}) async {
    Navigator.pop(context);
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (pickedFile == null) return;
      setState(() {
        if (isRecto) {
          _rectoPath = pickedFile.path;
        } else {
          _versoPath = pickedFile.path;
        }
      });
    } catch (_) {}
  }

  void _showPickOptions({required bool isRecto}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.sp20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRecto
                      ? 'Ajouter le RECTO du document'
                      : 'Ajouter le VERSO du document',
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold, color: AppColors.neutral800),
                ),
                const SizedBox(height: AppDimensions.sp16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.secondary600),
                  title: const Text('Prendre une photo',
                      style: AppTextStyles.bodyMedium),
                  onTap: () => _pickImage(ImageSource.camera, isRecto: isRecto),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: AppColors.secondary600),
                  title: const Text('Choisir depuis la galerie',
                      style: AppTextStyles.bodyMedium),
                  onTap: () =>
                      _pickImage(ImageSource.gallery, isRecto: isRecto),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onDocumentTypeChanged(String? value) {
    if (value == null) return;
    setState(() {
      _documentType = value;
      // Le verso n'a de sens que pour la CNI : on l'efface si on bascule
      // vers un passeport pour éviter d'envoyer un fichier orphelin.
      if (value == 'PASSPORT') _versoPath = null;
    });
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;

    final missingRecto = _rectoPath == null;
    final missingVerso = _isCni && _versoPath == null;
    if (missingRecto || missingVerso) {
      AppStatusDialog.show(
        context,
        title: 'Scans manquants',
        message: _isCni
            ? 'Merci d\'ajouter le recto et le verso de votre CNI avant d\'enregistrer.'
            : 'Merci d\'ajouter la page principale de votre passeport avant d\'enregistrer.',
        type: StatusDialogType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    final files = <String>[
      await fileToBase64(_rectoPath!),
      if (_isCni) await fileToBase64(_versoPath!),
    ];

    final Map<String, dynamic> fieldsToUpdate = {
      'identities': [
        {
          'type': _documentType,
          'value': _numberController.text.trim().replaceAll(' ', ''),
          'files': files,
        },
      ],
    };

    final success = await ref
        .read(applicantNotifierProvider.notifier)
        .updateProfileFields(fieldsToUpdate);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        AppStatusDialog.show(
          context,
          title: 'Pièce d\'identité mise à jour',
          message: 'Votre document a été enregistré avec succès',
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
          title: const Text('Pièce d\'identité',
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
                          'Type, numéro et scans de votre document officiel.',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: AppDimensions.sp8),
                        const Text(
                          'La mise à jour remplace entièrement le document actuellement enregistré : merci de fournir à nouveau les scans, même pour une simple correction du numéro.',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppDimensions.sp24),
                        Text('Type de document *',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.neutral800)),
                        const SizedBox(height: AppDimensions.sp6),
                        DropdownButtonFormField<String>(
                          value: _documentType,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.neutral50,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.sp12, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMD),
                              borderSide: const BorderSide(
                                  color: AppColors.border,
                                  width: AppDimensions.borderThin),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMD),
                              borderSide: const BorderSide(
                                  color: AppColors.secondary600,
                                  width: AppDimensions.borderMedium),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'CNI',
                                child: Text('Carte Nationale d\'Identité (CNI)',
                                    style: TextStyle(fontSize: 14))),
                            DropdownMenuItem(
                                value: 'PASSPORT',
                                child: Text('Passeport',
                                    style: TextStyle(fontSize: 14))),
                          ],
                          onChanged: _onDocumentTypeChanged,
                        ),
                        const SizedBox(height: AppDimensions.sp14),
                        SField(
                          label: 'Numéro de la pièce *',
                          hint: '1456199900268',
                          controller: _numberController,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Champ requis'
                                  : null,
                        ),
                        const SizedBox(height: AppDimensions.sp24),
                        if (_isCni) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _DocumentUploadCard(
                                  label: 'Recto de la CNI *',
                                  filePath: _rectoPath,
                                  existingUrl: _existingUrlFor(isRecto: true),
                                  onTap: () => _showPickOptions(isRecto: true),
                                  onDelete: () =>
                                      setState(() => _rectoPath = null),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.sp12),
                              Expanded(
                                child: _DocumentUploadCard(
                                  label: 'Verso de la CNI *',
                                  filePath: _versoPath,
                                  existingUrl: _existingUrlFor(isRecto: false),
                                  onTap: () => _showPickOptions(isRecto: false),
                                  onDelete: () =>
                                      setState(() => _versoPath = null),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _DocumentUploadCard(
                            label: 'Page principale du Passeport *',
                            filePath: _rectoPath,
                            existingUrl: _existingUrlFor(isRecto: true),
                            onTap: () => _showPickOptions(isRecto: true),
                            onDelete: () => setState(() => _rectoPath = null),
                          ),
                        ],
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
                        label: 'Enregistrer la pièce d\'identité',
                        onPressed: _isLoading ? null : _saveDocument,
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

/// Carte d'upload recto/verso : affiche le nouveau fichier local choisi, à
/// défaut l'aperçu réseau du document déjà enregistré, à défaut un état
/// vide invitant à ajouter un scan.
class _DocumentUploadCard extends StatelessWidget {
  final String label;
  final String? filePath;
  final String? existingUrl;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DocumentUploadCard({
    required this.label,
    required this.filePath,
    required this.existingUrl,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasNewFile = filePath != null;
    final hasExistingFile = !hasNewFile && existingUrl != null;
    final hasPreview = hasNewFile || hasExistingFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.sp24, horizontal: AppDimensions.sp12),
            decoration: BoxDecoration(
              color: hasNewFile
                  ? AppColors.primary50.withValues(alpha: 0.3)
                  : AppColors.neutral50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                color: hasNewFile ? AppColors.primary600 : AppColors.neutral300,
                width: hasNewFile ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                if (hasPreview) ...[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: hasNewFile
                              ? AppColors.primary600
                              : AppColors.neutral300,
                          width: 2),
                      image: DecorationImage(
                        image: hasNewFile
                            ? FileImage(File(filePath!)) as ImageProvider
                            : NetworkImage(existingUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp10),
                  Text(
                    hasNewFile ? filePath!.split('/').last : 'Document actuel',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.neutral500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasNewFile)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    Text(
                      'Toucher pour remplacer',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary600, fontSize: 10),
                    ),
                ] else ...[
                  const Icon(Icons.cloud_upload_outlined,
                      size: 36, color: AppColors.neutral400),
                  const SizedBox(height: AppDimensions.sp8),
                  const Text(
                    'Ajouter',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w500),
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
