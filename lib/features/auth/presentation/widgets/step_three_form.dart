// features/auth/presentation/widgets/step_two_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_form_fields.dart';
import '../providers/registration_provider.dart';

class StepThreeForm extends ConsumerStatefulWidget {
  const StepThreeForm({super.key});

  @override
  ConsumerState<StepThreeForm> createState() => _StepThreeFormState();
}

class _StepThreeFormState extends ConsumerState<StepThreeForm> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cached = ref.read(registrationNotifierProvider);
    _phoneController.text = cached.phone;
    _emailController.text = cached.email;
    _usernameController.text = cached.username;
    _passwordController.text = cached.password;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(registrationNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Création de compte', style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp4),
        Text('Identifiants de connexion requis pour accéder à la plateforme', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
        const SizedBox(height: AppDimensions.sp24),
        SPhoneField(
          controller: _phoneController,
          label: 'Numéro de téléphone *',
          hint: '+221775462058',
          onPhoneNumberChanged: (val) => notifier.updateField(phone: val),
        ),
        const SizedBox(height: AppDimensions.sp14),
        SField(
          controller: _emailController,
          label: 'Adresse Email *',
          hint: 'mamadou.diallo@email.com',
          onChanged: (val) => notifier.updateField(email: val),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppDimensions.sp14),
        SField(
          controller: _usernameController,
          label: 'Nom d\'utilisateur *',
          hint: 'mamadou.diallo',
          onChanged: (val) => notifier.updateField(username: val),
        ),
        const SizedBox(height: AppDimensions.sp14),
        SField(
          controller: _passwordController,
          label: 'Mot de passe *',
          hint: '••••••••••••',
          obscureText: true,
          onChanged: (val) => notifier.updateField(password: val),
        ),
      ],
    );
  }
}