import 'package:flutter/material.dart';

const Color bleuMarine = Color(0xFF0B1F3A);
const Color or = Color(0xFFF2B705);

class Artisan {
  final String id;
  final String nom;
  final String metier;
  final String categorie;
  final String telephone;
  final String ville;
  final bool ajouteParUtilisateur;

  const Artisan({
    required this.id,
    required this.nom,
    required this.metier,
    required this.categorie,
    required this.telephone,
    this.ville = '',
    this.ajouteParUtilisateur = false,
  });

  String get telephoneInternational => '226$telephone';

  String get telephoneAffiche {
    if (telephone.length != 8) return telephone;
    return '${telephone.substring(0, 2)} ${telephone.substring(2, 4)} '
        '${telephone.substring(4, 6)} ${telephone.substring(6, 8)}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'metier': metier,
        'categorie': categorie,
        'telephone': telephone,
        'ville': ville,
      };

  factory Artisan.fromJson(Map<String, dynamic> json) => Artisan(
        id: json['id'] as String,
        nom: json['nom'] as String,
        metier: json['metier'] as String,
        categorie: json['categorie'] as String,
        telephone: json['telephone'] as String,
        ville: (json['ville'] as String?) ?? '',
        ajouteParUtilisateur: true,
      );
}

class Categorie {
  final String nom;
  final IconData icone;

  const Categorie(this.nom, this.icone);
}

const List<Categorie> categories = [
  Categorie('Maçonnerie', Icons.foundation),
  Categorie('Électricité', Icons.electrical_services),
  Categorie('Plomberie', Icons.plumbing),
  Categorie('Menuiserie', Icons.carpenter),
  Categorie('Carrelage', Icons.grid_view),
  Categorie('Soudure', Icons.local_fire_department),
  Categorie('Mécanique', Icons.car_repair),
  Categorie('Réparation téléphone', Icons.phone_android),
  Categorie('Architecture', Icons.architecture),
  Categorie('Transport', Icons.local_shipping),
  Categorie('Commerce', Icons.storefront),
];

IconData iconeCategorie(String nom) => categories
    .firstWhere((c) => c.nom == nom,
        orElse: () => const Categorie('', Icons.handyman))
    .icone;

const List<Artisan> artisansInitiaux = [
  Artisan(id: 'a1', nom: 'Taïb Ouedraogo', metier: 'Garagiste', categorie: 'Mécanique', telephone: '70250497'),
  Artisan(id: 'a2', nom: 'Aziz Belem', metier: 'Maçon', categorie: 'Maçonnerie', telephone: '74131248'),
  Artisan(id: 'a3', nom: 'Cherif Zongo', metier: 'Réparation téléphone', categorie: 'Réparation téléphone', telephone: '65607722'),
  Artisan(id: 'a4', nom: 'Alexandre Kougoussi', metier: 'Soudeur', categorie: 'Soudure', telephone: '69658407'),
  Artisan(id: 'a5', nom: 'Ousman Bagayan', metier: 'Carreleur', categorie: 'Carrelage', telephone: '56035849'),
  Artisan(id: 'a6', nom: 'Denis Ouedraogo', metier: 'Architecte', categorie: 'Architecture', telephone: '74776011'),
  Artisan(id: 'a7', nom: 'Yacouba Palogo', metier: 'Mécanicien hydraulique', categorie: 'Mécanique', telephone: '66371334'),
  Artisan(id: 'a8', nom: 'Yacouba Ilboudo', metier: 'Charpentier', categorie: 'Menuiserie', telephone: '66287057'),
  Artisan(id: 'a9', nom: 'Alpha Belem', metier: 'Électricien', categorie: 'Électricité', telephone: '56230598'),
  Artisan(id: 'a10', nom: 'Fathao Koanda', metier: 'Commerce majoritaire', categorie: 'Commerce', telephone: '56085464'),
];

const String createurNom = 'Wendlasida Acture Junior Roamba';
const List<String> createurTelephones = ['73246144', '65414510'];
const String createurEmail = 'Juniorroamba5@gmail.com';
