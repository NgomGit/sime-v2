import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';

// Modèle temporaire local pour illustrer la structure des données de notification
enum NotificationCategory { emploi, formation, financement, mobilite, systeme }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationCategory category;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory? _selectedFilter;

  // Données de démo synchronisées avec les piliers ANPEJ
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Candidature retenue',
      description: 'Votre profil a été retenu pour l\'offre de Développeur Mobile chez Volkeno. Vous recevrez bientôt une date d\'entretien.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      category: NotificationCategory.emploi,
    ),
    NotificationItem(
      id: '2',
      title: 'Nouvelle formation disponible',
      description: 'L\'ANPEJ en partenariat avec la 3FPT lance une session de certification en UI/UX Design. Inscrivez-vous vite !',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: NotificationCategory.formation,
    ),
    NotificationItem(
      id: '3',
      title: 'Mise à jour financement',
      description: 'Votre dossier de demande d\'incubation pour le projet KOK a été validé par le comité de sélection.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: NotificationCategory.financement,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Appel à la mobilité internationale',
      description: 'Nouvelles opportunités de stage et de migration professionnelle via le CSAEM pour le Canada.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      category: NotificationCategory.mobilite,
      isRead: true,
    ),
  ];

  // Extraction du style visuel précis de la notification selon son type d'accompagnement
  (Color bg, Color fg, IconData icon) _getCategoryStyle(NotificationCategory category) {
    return switch (category) {
      NotificationCategory.emploi => (
          AppColors.primary100,
          AppColors.primary400,
          Icons.work_history_outlined
        ),
      NotificationCategory.formation => (
          AppColors.bleuANPEJBg,
          AppColors.bleuANPEJ,
          Icons.school_outlined
        ),
      NotificationCategory.financement => (
          AppColors.accent100,
          AppColors.accent500,
          Icons.rocket_launch_outlined
        ),
      NotificationCategory.mobilite => (
          AppColors.violetANPEJBg,
          AppColors.violetANPEJ,
          Icons.flight_takeoff_outlined
        ),
      NotificationCategory.systeme => (
          AppColors.neutral50,
          AppColors.neutral600,
          Icons.notifications_outlined
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Filtrage des notifications
    final filteredNotifications = _selectedFilter == null
        ? _notifications
        : _notifications.where((n) => n.category == _selectedFilter).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text(
            'Notifications',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.neutral800),
          ),
          actions: [
            if (_notifications.any((n) => !n.isRead))
              TextButton(
                onPressed: () {
                  // Logique pour tout marquer comme lu
                },
                child: Text(
                  'Tout marquer comme lu',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary400),
                ),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border),
          ),
        ),
        body: Column(
          children: [
            // ─── Barre Horizontale de Filtres ────────────────────────────────
            _buildFilterBar(),
            const Divider(height: 1, color: AppColors.border),

            // ─── Liste des notifications ou état vide ────────────────────────
            Expanded(
              child: filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                      itemCount: filteredNotifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sp10),
                      itemBuilder: (context, index) {
                        final item = filteredNotifications[index];
                        return _buildNotificationCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de filtrage par pôle ANPEJ
  Widget _buildFilterBar() {
    final filters = [
      (label: 'Tout', value: null as NotificationCategory?),
      (label: 'Emploi', value: NotificationCategory.emploi),
      (label: 'Formation', value: NotificationCategory.formation),
      (label: 'Financement', value: NotificationCategory.financement),
      (label: 'Mobilité', value: NotificationCategory.mobilite),
    ];

    return Container(
      height: 56,
      color: AppColors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH, vertical: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter.value;

          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.sp8),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: isSelected,
              labelStyle: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.neutral600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              selectedColor: AppColors.secondary800, // Marron institutionnel pour la sélection générale
              backgroundColor: AppColors.neutral50,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                side: BorderSide(color: isSelected ? AppColors.secondary800 : AppColors.border),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter.value;
                });
              },
            ),
          );
        },
      ),
    );
  }

  // Tuile de Notification Thématique
  Widget _buildNotificationCard(NotificationItem item) {
    final (bg, fg, icon) = _getCategoryStyle(item.category);

    return SCard(
      // Si non lue, fond très légèrement teinté de la couleur thématique
      color: item.isRead ? AppColors.white : bg.withAlpha(15),
      borderColor: !item.isRead ? fg.withAlpha(90) : AppColors.border,
      padding: const EdgeInsets.all(AppDimensions.sp14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge d'icône coloré selon le pilier
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: fg, size: AppDimensions.iconMD),
          ),
          const SizedBox(width: AppDimensions.sp12),
          
          // Contenu textuel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.neutral800,
                          fontWeight: !item.isRead ? FontWeight.bold : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(item.timestamp),
                      style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sp4),
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: !item.isRead ? AppColors.neutral800 : AppColors.neutral600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Point d'inculcation "Non Lu"
          if (!item.isRead) ...[
            const SizedBox(width: AppDimensions.sp8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: fg, // Assorti au code couleur de la catégorie
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Vue si aucune notification n'est disponible
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.sp32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.neutral50,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.neutral400,
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.sp16),
            Text(
              'Aucune notification',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
            ),
            const SizedBox(height: AppDimensions.sp6),
            Text(
              _selectedFilter == null 
                  ? 'Vous êtes à jour ! Les alertes concernant vos candidatures et formations s\'afficheront ici.'
                  : 'Aucune alerte trouvée pour cette catégorie de services.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Formatage propre du temps (Ex: "Il y a 10 min" ou "12 mai")
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return DateFormat('dd MMM', 'fr').format(dateTime);
    }
  }
}