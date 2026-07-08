// ─── Shared field widgets ─────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Requis pour formater la date affichée
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/utils/country_token.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SField
// ─────────────────────────────────────────────────────────────────────────────
/// Champ texte standard avec background blanc. Focus ring = marron [secondary800].
/// Icône de validation = vert ANPEJ [success].
class SField extends StatelessWidget {
  const SField({
    super.key,
    required this.label,
    required this.hint,
    this.hint2,
    this.isValid = false,
    this.isPhone = false,
    this.keyboardType = TextInputType.text,
    this.controller,
  });
 
  final String label, hint;
  final String? hint2;
  final bool isValid, isPhone;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800),
        ),
        const SizedBox(height: AppDimensions.sp6),
        TextFormField(
          controller: controller,
          initialValue: controller != null ? null : (isValid ? hint : null),
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral800),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white, // Background blanc appliqué
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.neutral400),
            suffixIcon: isValid
                ? const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: AppDimensions.iconSM,
                  )
                : null,
            prefixText: isPhone ? '🇸🇳 +221 ' : null,
            prefixStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.neutral800),
          ),
        ),
        if (hint2 != null) ...[
          const SizedBox(height: AppDimensions.sp4),
          Text(
            hint2!,
            style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
          ),
        ],
      ],
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// SDropdown
// ─────────────────────────────────────────────────────────────────────────────
/// Dropdown statique avec background blanc. Chevron neutre [neutral400].
class SDropdown extends StatelessWidget {
  const SDropdown({super.key, required this.label, required this.value});
 
  final String label, value;
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800),
        ),
        const SizedBox(height: AppDimensions.sp6),
        Container(
          height: AppDimensions.inputHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp14),
          decoration: BoxDecoration(
            color: AppColors.white, // Passé de neutral50 à blanc
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.neutral800),
              ),
              const Icon(
                Icons.expand_more,
                color: AppColors.neutral400,
                size: AppDimensions.iconSM,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// SPhoneField
// ─────────────────────────────────────────────────────────────────────────────
/// Champ téléphone avec sélecteur de pays et background blanc constant.
class SPhoneField extends StatefulWidget {
  const SPhoneField({
    super.key,
    required this.label,
    this.controller,
    this.onPhoneNumberChanged,
    this.isValid = false,
  });
 
  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onPhoneNumberChanged;
  final bool isValid;
 
  @override
  State<SPhoneField> createState() => _SPhoneFieldState();
}
 
class _SPhoneFieldState extends State<SPhoneField> {
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      builder: (context) => SafeArea(
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
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.sp20, AppDimensions.sp16,
                  AppDimensions.sp20, AppDimensions.sp10,
                ),
                child: Text(
                  'Sélectionnez un pays',
                  style: AppTextStyles.headingSmall,
                ),
              ),
              const Divider(color: AppColors.neutral100),
              ...supportedCountries.map((country) {
                final isCurrent = country.code == _selectedCountry.code;
                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  title: Text(country.name, style: AppTextStyles.labelMedium),
                  trailing: Text(
                    country.code,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isCurrent
                          ? AppColors.secondary800
                          : AppColors.neutral400,
                      fontWeight: isCurrent
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  tileColor: isCurrent
                      ? AppColors.secondary100
                      : Colors.transparent,
                  onTap: () {
                    setState(() => _selectedCountry = country);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isValid
        ? AppColors.success
        : _isFocused
            ? AppColors.secondary800
            : AppColors.border;
 
    final borderWidth = _isFocused || widget.isValid
        ? AppDimensions.borderMedium
        : AppDimensions.borderThin;
 
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
            color: AppColors.white, // Toujours blanc pour la cohérence visuelle
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _showCountryPicker,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sp12,
                  ),
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: AppColors.border,
                        width: AppDimensions.borderThin,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountry.flag,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: AppDimensions.sp6),
                      Text(
                        _selectedCountry.code,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.neutral800),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.neutral400,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.neutral800),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    widget.onPhoneNumberChanged
                        ?.call('${_selectedCountry.code}$value');
                  },
                  decoration: InputDecoration(
                    hintText: _selectedCountry.maskHint,
                    hintStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.neutral400),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sp14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    isDense: true,
                    suffixIcon: widget.isValid
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 18,
                          )
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

// ─────────────────────────────────────────────────────────────────────────────
// SDateField
// ─────────────────────────────────────────────────────────────────────────────
/// Champ de sélection de date avec background blanc et sélecteur natif.
class SDateField extends StatelessWidget {
  const SDateField({
    super.key,
    required this.label,
    required this.hint,
    this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  final String label, hint;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate, lastDate;

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedDate != null;
    final formattedDate = hasValue 
        ? DateFormat('dd/MM/yyyy').format(selectedDate!) 
        : hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800),
        ),
        const SizedBox(height: AppDimensions.sp6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1930),
              lastDate: lastDate ?? DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.secondary800, // Marron institutionnel
                      onPrimary: AppColors.white,
                      onSurface: AppColors.neutral800,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) onDateSelected(picked);
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: Container(
            height: AppDimensions.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: hasValue ? AppColors.neutral800 : AppColors.neutral400,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.neutral400,
                  size: AppDimensions.iconSM,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}