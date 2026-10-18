# SOS ARTISAN

Un artisan qualifié, à portée de main. Application Flutter (Android + Web) pour trouver et contacter des artisans au Burkina Faso.

## Utiliser l'application

- **Android** : téléchargez `sos-artisan.apk` depuis la [dernière version](https://github.com/Juniorroamba/sos-artisan/releases/latest), puis ouvrez le fichier sur votre téléphone (autorisez « Installer des applications inconnues » si demandé).
- **Web** (tout appareil, sans installation) : https://juniorroamba.github.io/sos-artisan/

## Fonctionnalités

- Recherche par nom, métier, ville ou numéro (sans tenir compte des accents)
- 11 catégories de métiers avec le nombre d'artisans par catégorie
- Appel direct, SMS et WhatsApp en un geste
- Envoi de sa position GPS à l'artisan par WhatsApp (lien Google Maps)
- « Près de moi » : localisation GPS et recherche du métier voulu autour de soi sur Google Maps
- Favoris (étoile) enregistrés sur l'appareil
- Ajout d'artisans depuis l'application (enregistrés sur l'appareil, suppression possible)

## Limites actuelles

Les données ajoutées (favoris, nouveaux artisans) restent sur l'appareil : il n'y a pas encore de serveur partagé, de comptes utilisateurs, de messagerie en ligne ni de paiement mobile.

## Développement

```bash
flutter pub get
flutter run            # téléphone ou émulateur
flutter run -d chrome  # web
flutter test
flutter build apk --release
flutter build web --release --base-href /sos-artisan/
```

Signature Android : placez un fichier `android/key.properties` (non versionné) contenant `storePassword`, `keyPassword`, `keyAlias` et `storeFile`. Sans ce fichier, l'APK est signé avec la clé de débogage.

Code source : `lib/main.dart` (accueil), `lib/pages.dart` (écrans), `lib/widgets.dart` (fiche artisan), `lib/store.dart` (données locales), `lib/actions.dart` (appel, WhatsApp, GPS), `lib/data.dart` (liste des artisans et catégories).

## Créateur

Wendlasida Acture Junior Roamba — +226 73 24 61 44 / +226 65 41 45 10 — Juniorroamba5@gmail.com
