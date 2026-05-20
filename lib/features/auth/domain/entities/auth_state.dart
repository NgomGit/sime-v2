import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.numeroDossier,
    this.email,
    this.isAuthenticated = true,
  });

  final String id;
  final String prenom;
  final String nom;
  final String telephone;
  final String numeroDossier;
  final String? email;
  final bool isAuthenticated;

  static const AuthUser unauthenticated = AuthUser(
    id: '',
    prenom: '',
    nom: '',
    telephone: '',
    numeroDossier: '',
    isAuthenticated: false,
  );

  String get fullName => '$prenom $nom';
  String get initials {
    final p = prenom.isNotEmpty ? prenom[0] : '';
    final n = nom.isNotEmpty ? nom[0] : '';
    return '$p$n'.toUpperCase();
  }

  @override
  List<Object?> get props => [id, prenom, nom, telephone, numeroDossier, email, isAuthenticated];
}
