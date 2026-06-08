import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/features/profile/presentation/providers/user_profile_provider.dart';

class EditPersonalProfileScreen extends ConsumerStatefulWidget {
  const EditPersonalProfileScreen({super.key});

  @override
  ConsumerState<EditPersonalProfileScreen> createState() => _EditPersonalProfileScreenState();
}

class _EditPersonalProfileScreenState extends ConsumerState<EditPersonalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _cinController;
  late final TextEditingController _locationController;
  
  String _selectedNationality = '🇸🇳 Sénégalaise';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider).value;
    
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _birthDateController = TextEditingController(text: profile?.birthDate ?? '');
    _cinController = TextEditingController(text: profile?.cin ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    
    if (profile != null && profile.nationality.isNotEmpty) {
      _selectedNationality = profile.nationality;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _cinController.dispose();
    _locationController.dispose();
    super.dispose();
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
      await ref.read(profileNotifierProvider.notifier).updatePersonalProfile(
        fullName: _nameController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        cin: _cinController.text.trim(),
        nationality: _selectedNationality,
        location: _locationController.text.trim(),
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations personnelles mises à jour'),
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
                      const Text(
                        'Modifiez vos informations',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppDimensions.sp24),
                      
                      SField(
                        label: 'Nom complet *',
                        hint: 'Mamadou Aidara',
                        controller: _nameController,
                      ),
                      const SizedBox(height: AppDimensions.sp14),
                      
                      Row(
                        children: [
                          Expanded(
                            child: SField(
                              label: 'Date de naissance *',
                              hint: '15/03/2000',
                              controller: _birthDateController,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sp12),
                          Expanded(
                            child: SField(
                              label: 'Numéro CIN *',
                              hint: '1234567890123',
                              controller: _cinController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sp14),
                      
                      SField(
                        label: 'Adresse *',
                        hint: 'Dakar, Sénégal',
                        controller: _locationController,
                      ),
                      const SizedBox(height: AppDimensions.sp14),
                      
                      GestureDetector(
                        onTap: () {
                          _showDropdownPicker(
                            title: 'Nationalité',
                            options: const [
                              '🇸🇳 Sénégalaise',
                              '🇲🇱 Malienne',
                              '🇬🇳 Guinéenne',
                              '🇨🇮 Ivoirienne',
                            ],
                            currentValue: _selectedNationality,
                            onSelected: (newValue) {
                              setState(() => _selectedNationality = newValue);
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: SDropdown(
                            label: 'Nationalité',
                            value: _selectedNationality,
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