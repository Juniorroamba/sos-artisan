import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

class ArtisanStore extends ChangeNotifier {
  static const _cleFavoris = 'favoris';
  static const _cleArtisans = 'artisans_ajoutes';

  SharedPreferences? _prefs;
  final Set<String> _favoris = {};
  final List<Artisan> _ajoutes = [];

  Future<void> charger() async {
    _prefs = await SharedPreferences.getInstance();
    _favoris
      ..clear()
      ..addAll(_prefs!.getStringList(_cleFavoris) ?? const []);
    _ajoutes
      ..clear()
      ..addAll((_prefs!.getStringList(_cleArtisans) ?? const [])
          .map((s) => Artisan.fromJson(jsonDecode(s) as Map<String, dynamic>)));
    notifyListeners();
  }

  List<Artisan> get tous => [...artisansInitiaux, ..._ajoutes];

  List<Artisan> get favoris =>
      tous.where((a) => _favoris.contains(a.id)).toList();

  bool estFavori(Artisan a) => _favoris.contains(a.id);

  List<Artisan> parCategorie(String categorie) =>
      tous.where((a) => a.categorie == categorie).toList();

  List<Artisan> rechercher(String requete) {
    final q = normaliser(requete.trim());
    if (q.isEmpty) return tous;
    return tous.where((a) {
      final texte = normaliser(
          '${a.nom} ${a.metier} ${a.categorie} ${a.ville} ${a.telephone}');
      return q.split(RegExp(r'\s+')).every(texte.contains);
    }).toList();
  }

  Future<void> basculerFavori(Artisan a) async {
    if (!_favoris.remove(a.id)) _favoris.add(a.id);
    notifyListeners();
    await _prefs?.setStringList(_cleFavoris, _favoris.toList());
  }

  Future<void> ajouter(Artisan a) async {
    _ajoutes.add(a);
    notifyListeners();
    await _sauverAjoutes();
  }

  Future<void> supprimer(Artisan a) async {
    _ajoutes.removeWhere((x) => x.id == a.id);
    _favoris.remove(a.id);
    notifyListeners();
    await _sauverAjoutes();
    await _prefs?.setStringList(_cleFavoris, _favoris.toList());
  }

  Future<void> _sauverAjoutes() async {
    await _prefs?.setStringList(
        _cleArtisans, _ajoutes.map((a) => jsonEncode(a.toJson())).toList());
  }
}

String normaliser(String s) {
  const accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e',
    'ë': 'e', 'î': 'i', 'ï': 'i', 'ô': 'o', 'ö': 'o', 'ù': 'u', 'û': 'u',
    'ü': 'u', 'ÿ': 'y',
  };
  final bas = s.toLowerCase();
  final buffer = StringBuffer();
  for (final ch in bas.split('')) {
    buffer.write(accents[ch] ?? ch);
  }
  return buffer.toString();
}

final ArtisanStore store = ArtisanStore();
