import 'package:flutter/material.dart';

/// SIME V2 — Tokens couleurs ANPEJ
///
/// Charte graphique officielle ANPEJ (valeurs CMJN converties en sRGB) :
///   • Vert   C50 M2  J100 N0  → primary400   #80C241
///   • Marron C43 M57 J92  N55 → secondary600 #735618
///   • Jaune  C1  M35 J85  N0  → accent500    #FAA634
///   • Bleu   C76 M22 J0   N0  → bleuANPEJ    #2195D2
///   • Violet C42 M100 J5  N1  → violetANPEJ  #9C1D76
abstract final class AppColors {
  AppColors._();

  // ── VERT ANPEJ (Couleur Positive / Emploi / Succès) ──────────────────────
  // Utilisé pour : bouton "Postuler", barres de progression, switches ON,
  // badges de succès, liens texte, icônes de validation
  static const Color primary900 = Color(0xFF1B330B); // Vert très sombre (textes sur fond vert)
  static const Color primary800 = Color(0xFF335E17); // Vert sombre
  static const Color primary600 = Color(0xFF599429); // Vert moyen
  static const Color primary400 = Color(0xFF80C241); // ★ VERT CHARTE EXACT (C50 M2 J100 N0)
  static const Color primary100 = Color(0xFFEFF7E8); // Fond vert doux (chips, containers)
  static const Color primary50  = Color(0xFFF7FBF3); // Fond vert très doux

  // ── MARRON ANPEJ (Couleur Institutionnelle / Primaire UI) ────────────────
  // Utilisé pour : CTA principaux, AppBar (onboarding), FAB, chips actifs,
  // focus ring, indicateur tab, bottom nav active, snackbar fond
  static const Color secondary900 = Color(0xFF2C1A05); // Marron très sombre (dark mode surface)
  static const Color secondary800 =  Color(0xFF543E0F);
  // Color(0xFF335E17); Vert sombre (dark mode accents) - à réserver pour éléments secondaires en dark mode
  // Color(0xFF543E0F); Maron sombre (dark mode accents) - à réserver pour éléments secondaires en dark mode
   // Marron foncé (CTA primary)
  static const Color secondary600 = Color(0xFF735618); // ★ MARRON CHARTE EXACT (C43 M57 J92 N55)
  static const Color secondary400 = Color(0xFF9E7A31); // Marron clair (hover states)
  static const Color secondary100 = Color(0xFFF6F0E4); // Fond marron doux (containers)
  static const Color secondary50  = Color(0xFFFBF8F2); // Fond marron très doux

  // ── JAUNE ANPEJ (Accent / Urgence / Notifications) ───────────────────────
  // Utilisé pour : badges délai (J-3), highlights, notifications, warnings,
  // icône dossier "En traitement" sur le dashboard
  static const Color accent900 = Color(0xFF945503); // Jaune très sombre (texte sur fond jaune)
  static const Color accent800 = Color(0xFFC77A14); // Jaune sombre
  static const Color accent500 = Color(0xFFFAA634); // ★ JAUNE CHARTE EXACT (C1 M35 J85 N0)
  static const Color accent100 = Color(0xFFFFF4E3); // Fond jaune doux (containers warning)
  static const Color accent50  = Color(0xFFFFFAF0); // Fond jaune très doux

  // ── BLEU ANPEJ (Service : Formation / Financement) ───────────────────────
  // Utilisé pour : icône/badge du service Formation (3FPT, FORCEN),
  // icône/badge du service Financement (incubation), chip "GRATUIT"
  static const Color bleuANPEJ    = Color(0xFF2195D2); // ★ BLEU CHARTE EXACT (C76 M22 J0 N0)
  static const Color bleuANPEJBg  = Color(0xFFE3F3FD); // Fond bleu doux
  static const Color bleuANPEJDark = Color(0xFF1167A0); // Bleu foncé (texte sur fond bleu)

  // ── VIOLET ANPEJ (Service : Mobilité Internationale / Migration) ─────────
  // Utilisé pour : icône/badge du service Mobilité (CSAEM, migration pro),
  // tags de statut migration
  static const Color violetANPEJ     = Color(0xFF9C1D76); // ★ VIOLET CHARTE EXACT (C42 M100 J5 N1)
  static const Color violetANPEJBg   = Color(0xFFF8E6F3); // Fond violet doux
  static const Color violetANPEJDark = Color(0xFF6B1050); // Violet foncé (texte sur fond violet)

  // ── NEUTRES CHAUDS ───────────────────────────────────────────────────────
  // Légèrement teintés chaud (accord chromatique avec marron et vert)
  // Utilisé pour : textes corps, placeholders, bordures, fonds de cards
  static const Color neutral800 = Color(0xFF1F1E1C); // Texte principal
  static const Color neutral600 = Color(0xFF4A4844); // Texte secondaire fort
  static const Color neutral500 = Color(0xFF66635E); // Texte secondaire
  static const Color neutral400 = Color(0xFF918E88); // Texte tertiaire / icônes inactives
  static const Color neutral300 = Color(0xFFB3B0A8); // Placeholder / hint
  static const Color neutral200 = Color(0xFFD6D4CC); // Bordures légères / séparateurs
  static const Color neutral100 = Color(0xFFEFEFEA); // Fond désactivé / track progress
  static const Color neutral50  = Color(0xFFF9F9F6); // Fond input / surface légère

  // ── ÉTATS SYSTÈME ────────────────────────────────────────────────────────
  static const Color error      = Color(0xFFD32F2F); // Rouge erreur standard
  static const Color errorBg    = Color(0xFFFFEBEE); // Fond erreur

  // Les états success/warning/info sont indexés sur les couleurs ANPEJ :
  static const Color success    = Color(0xFF80C241); // = primary400 (vert ANPEJ)
  static const Color successBg  = Color(0xFFEFF7E8); // = primary100
  static const Color warning    = Color(0xFFFAA634); // = accent500 (jaune ANPEJ)
  static const Color warningBg  = Color(0xFFFFF4E3); // = accent100
  static const Color info       = Color(0xFF2195D2); // = bleuANPEJ
  static const Color infoBg     = Color(0xFFE3F3FD); // = bleuANPEJBg

  // ── SURFACES & STRUCTURES ────────────────────────────────────────────────
  static const Color white      = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9F9F6); // Fond global (neutre50 chaud)
  static const Color surface    = Color(0xFFFFFFFF); // Cards, AppBar, BottomNav
  static const Color border     = Color(0xFFEFEFEA); // Bordures standard (neutre100)

  // ── MODE SOMBRE ──────────────────────────────────────────────────────────
  // Base "Forêt profonde" : vert-marron très sombre, accents lumineux ANPEJ
  static const Color darkSurface        = Color(0xFF0F170A); // Fond principal (vert forêt)
  static const Color darkSurfaceCard    = Color(0xFF1A2412); // Surface cards en dark
  static const Color darkBorder         = Color(0x1AFFFFFF); // Bordure 10% blanc
  static const Color darkTextPrimary    = Color(0xFFFFFFFF); // Texte principal
  static const Color darkTextSecondary  = Color(0x99FFFFFF); // Texte secondaire 60%
  static const Color darkTextHint       = Color(0x40FFFFFF); // Placeholder 25%
}