// core/design_system/widgets/s_searchable_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';

class SSearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String value;
  final String searchHint;
  final String pickerTitle;
  final List<T> options;
  final T? currentValue;
  final String Function(T) labelExtractor;
  final ValueChanged<T> onSelected;
  final IconData? leadingIcon;

  final bool enabled;
  final String? disabledHint;

  const SSearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.pickerTitle,
    required this.options,
    required this.currentValue,
    required this.labelExtractor,
    required this.onSelected,
    this.searchHint = 'Rechercher...',
    this.leadingIcon,
    this.enabled = true,
    this.disabledHint,
  });

  @override
  State<SSearchableDropdown<T>> createState() => _SSearchableDropdownState<T>();
}

class _SSearchableDropdownState<T> extends State<SSearchableDropdown<T>> {
  bool _isFocusedVisual = false; // simule l'état "focus" au moment du tap

  Future<void> _showSearchModal(BuildContext context) async {
    HapticFeedback.selectionClick();
    setState(() => _isFocusedVisual = true);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _SearchModalContent<T>(
          title: widget.pickerTitle,
          searchHint: widget.searchHint,
          options: widget.options,
          currentValue: widget.currentValue,
          labelExtractor: widget.labelExtractor,
          onSelected: widget.onSelected,
        );
      },
    );

    if (mounted) setState(() => _isFocusedVisual = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value.isNotEmpty;
    final isEnabled = widget.enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral800),
          ),
          const SizedBox(height: AppDimensions.sp6),
        ],
        GestureDetector(
          onTap: isEnabled ? () => _showSearchModal(context) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            height: AppDimensions.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp16),
            decoration: BoxDecoration(
              // Même fond que SField : blanc, désactivé = neutral50
              color: !isEnabled ? AppColors.neutral50 : AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                // Même logique de bordure que SField : fine et neutre,
                // léger accent uniquement pendant l'ouverture du picker.
                color: !isEnabled
                    ? AppColors.border
                    : _isFocusedVisual
                        ? AppColors.secondary800
                        : AppColors.border,
                width: _isFocusedVisual ? AppDimensions.borderMedium : AppDimensions.borderThin,
              ),
            ),
            child: Row(
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: AppDimensions.iconSM,
                    color: !isEnabled ? AppColors.neutral300 : AppColors.neutral400,
                  ),
                  const SizedBox(width: AppDimensions.sp10),
                ],
                Expanded(
                  child: Text(
                    !isEnabled && widget.disabledHint != null
                        ? widget.disabledHint!
                        : hasValue
                            ? widget.value
                            : 'Sélectionner',
                    style: AppTextStyles.bodyMedium.copyWith(
                      // Même traitement que SField : texte saisi = neutral800,
                      // placeholder = neutral400. Pas de fontWeight boosté.
                      color: !isEnabled
                          ? AppColors.neutral400
                          : hasValue
                              ? AppColors.neutral800
                              : AppColors.neutral400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.sp8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: !isEnabled ? AppColors.neutral300 : AppColors.neutral400,
                  size: AppDimensions.iconMD,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Contenu interne du BottomSheet gérant l'état de la recherche locale
class _SearchModalContent<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<T> options;
  final T? currentValue;
  final String Function(T) labelExtractor;
  final ValueChanged<T> onSelected;

  const _SearchModalContent({
    required this.title,
    required this.searchHint,
    required this.options,
    required this.currentValue,
    required this.labelExtractor,
    required this.onSelected,
  });

  @override
  State<_SearchModalContent<T>> createState() => _SearchModalContentState<T>();
}

class _SearchModalContentState<T> extends State<_SearchModalContent<T>> {
  late List<T> _filteredOptions;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _hasQuery = false;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _hasQuery = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options.where((option) {
          final label = widget.labelExtractor(option).toLowerCase();
          return label.contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  void _selectOption(T option) {
    HapticFeedback.selectionClick();
    widget.onSelected(option);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée de glissement
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppDimensions.sp10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // En-tête avec titre + bouton fermer
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.sp20,
                  AppDimensions.sp16,
                  AppDimensions.sp12,
                  AppDimensions.sp4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.title, style: AppTextStyles.headingSmall),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neutral50,
                          ),
                          child: const Icon(Icons.close_rounded, size: 18, color: AppColors.neutral600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Barre de recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp20, vertical: AppDimensions.sp8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral800),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral400),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.neutral500, size: 20),
                    suffixIcon: _hasQuery
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded, size: 18, color: AppColors.neutral400),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.neutral50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      borderSide: const BorderSide(color: AppColors.neutral200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      borderSide: const BorderSide(color: AppColors.neutral200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      borderSide: const BorderSide(color: AppColors.secondary800, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Compteur de résultats
              if (_hasQuery)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.sp20,
                    right: AppDimensions.sp20,
                    top: AppDimensions.sp4,
                    bottom: AppDimensions.sp4,
                  ),
                  child: Text(
                    '${_filteredOptions.length} résultat${_filteredOptions.length > 1 ? 's' : ''}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
                  ),
                ),

              const Divider(color: AppColors.neutral100, height: AppDimensions.sp16),

              // Liste des résultats
              Flexible(
                child: _filteredOptions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppDimensions.sp32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.neutral50,
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 28,
                                color: AppColors.neutral300,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.sp12),
                            Text(
                              'Aucun résultat trouvé',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.neutral600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.sp4),
                            Text(
                              'Essayez avec un autre mot-clé',
                              style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: AppDimensions.sp16),
                        itemCount: _filteredOptions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 2),
                        itemBuilder: (context, index) {
                          final option = _filteredOptions[index];
                          final isCurrent = option == widget.currentValue;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp12),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => _selectOption(option),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.sp12,
                                    vertical: AppDimensions.sp12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrent ? AppColors.neutral50 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.labelExtractor(option),
                                          style: AppTextStyles.labelMedium.copyWith(
                                            color: isCurrent ? AppColors.secondary800 : AppColors.neutral800,
                                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      AnimatedScale(
                                        scale: isCurrent ? 1.0 : 0.0,
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOutBack,
                                        child: const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.secondary800,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}