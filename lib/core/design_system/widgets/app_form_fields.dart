// ─── Shared field widgets ─────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/utils/country_token.dart';


class SField extends StatelessWidget {
  const SField({
    super.key,
    required this.label,
    required this.hint,
    this.hint2,
    this.isValid = false,
    this.isPhone = false,
    this.keyboardType = TextInputType.text,
  });
  final String label, hint;
  final String? hint2;
  final bool isValid, isPhone;
  final TextInputType ? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        TextFormField(
          initialValue: isValid ? hint : null,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: isValid
                ? const Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: AppDimensions.iconSM)
                : null,
            prefixText: isPhone ? '🇸🇳 +221 ' : null,
          ),
        ),
        if (hint2 != null) ...[
          const SizedBox(height: AppDimensions.sp4),
          Text(hint2!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}

class SDropdown extends StatelessWidget {
  const SDropdown({super.key, required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800)),
        const SizedBox(height: AppDimensions.sp6),
        Container(
          height: AppDimensions.inputHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp14),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.neutral800)),
              const Icon(Icons.expand_more,
                  color: AppColors.neutral400, size: AppDimensions.iconSM),
            ],
          ),
        ),
      ],
    );
  }
}

class SPhoneField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onPhoneNumberChanged;
  final bool isValid;

  const SPhoneField({
    super.key,
    required this.label,
    this.controller,
    this.onPhoneNumberChanged,
    this.isValid = false,
  });

  @override
  State<SPhoneField> createState() => _SPhoneFieldState();
}

class _SPhoneFieldState extends State<SPhoneField> {
  // Defaults to Senegal natively matching SIME V2 requirements
  CountryToken _selectedCountry = supportedCountries[0];
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppDimensions.sp20, AppDimensions.sp16, AppDimensions.sp20, AppDimensions.sp10),
                  child: Text('Sélectionnez un pays', style: AppTextStyles.headingSmall),
                ),
                const Divider(color: AppColors.neutral100),
                ...supportedCountries.map((country) {
                  final isCurrent = country.code == _selectedCountry.code;
                  return ListTile(
                    leading: Text(country.flag, style: const TextStyle(fontSize: 20)),
                    title: Text(country.name, style: AppTextStyles.labelMedium),
                    trailing: Text(
                      country.code, 
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isCurrent ? AppColors.primary900 : AppColors.neutral400,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedCountry = country);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label, 
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800),
        ),
        const SizedBox(height: AppDimensions.sp6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          decoration: BoxDecoration(
            color: _isFocused ? AppColors.white : AppColors.neutral50,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(
              color: widget.isValid 
                  ? Colors.green 
                  : _isFocused 
                      ? AppColors.primary900 
                      : AppColors.border,
              width: _isFocused ? AppDimensions.borderMedium : AppDimensions.borderThin,
            ),
          ),
          child: Row(
            children: [
              // ── Country Selector Prefix Button ─────────────────────────────
              GestureDetector(
                onTap: _showCountryPicker,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp12),
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: AppColors.border, width: AppDimensions.borderThin)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedCountry.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: AppDimensions.sp6),
                      Text(_selectedCountry.code, style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutral800)),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, color: AppColors.neutral400, size: 18),
                    ],
                  ),
                ),
              ),

              // ── Phone Input Text Field Field ────────────────────────────────
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral800),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (widget.onPhoneNumberChanged != null) {
                      // Returns standard E.164 composite data format (e.g., +221774567890)
                      widget.onPhoneNumberChanged!('${_selectedCountry.code}$value');
                    }
                  },
                  decoration: InputDecoration(
                    hintText: _selectedCountry.maskHint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral300),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    isDense: true,
                    suffixIcon: widget.isValid 
                        ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}