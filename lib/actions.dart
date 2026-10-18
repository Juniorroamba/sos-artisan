import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data.dart';

Future<void> _ouvrir(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Impossible d’ouvrir cette application.')),
    );
  }
}

Future<void> appeler(BuildContext context, String telephone) =>
    _ouvrir(context, Uri(scheme: 'tel', path: '+226$telephone'));

Future<void> envoyerSms(BuildContext context, Artisan a) => _ouvrir(
      context,
      Uri(
        scheme: 'sms',
        path: '+226${a.telephone}',
        queryParameters: {'body': messageContact(a)},
      ),
    );

Future<void> ouvrirWhatsApp(BuildContext context, Artisan a, {String? texte}) =>
    _ouvrir(
      context,
      Uri.https('wa.me', '/${a.telephoneInternational}',
          {'text': texte ?? messageContact(a)}),
    );

Future<void> envoyerEmail(BuildContext context, String email) =>
    _ouvrir(context, Uri(scheme: 'mailto', path: email));

String messageContact(Artisan a) =>
    'Bonjour ${a.nom}, je vous contacte via SOS ARTISAN pour un besoin en '
    '${a.metier.toLowerCase()}.';

Future<void> ouvrirCarte(BuildContext context, String recherche,
        {Position? position}) =>
    _ouvrir(
      context,
      position == null
          ? Uri.https('www.google.com', '/maps/search/',
              {'api': '1', 'query': recherche})
          : Uri.parse('https://www.google.com/maps/search/'
              '${Uri.encodeComponent(recherche)}/'
              '@${position.latitude},${position.longitude},14z'),
    );

String lienPosition(Position p) =>
    'https://www.google.com/maps?q=${p.latitude},${p.longitude}';

/// Retourne la position actuelle, ou `null` avec un message à l'utilisateur.
Future<Position?> obtenirPosition(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  void info(String m) => messenger.showSnackBar(SnackBar(content: Text(m)));

  if (!await Geolocator.isLocationServiceEnabled()) {
    info('Activez la localisation (GPS) de votre appareil.');
    return null;
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    info('Autorisation de localisation refusée.');
    return null;
  }
  if (permission == LocationPermission.deniedForever) {
    info('Localisation bloquée : autorisez-la dans les paramètres.');
    return null;
  }
  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
  } catch (_) {
    final derniere = await Geolocator.getLastKnownPosition();
    if (derniere != null) return derniere;
    info('Position introuvable. Réessayez à l’extérieur.');
    return null;
  }
}
