import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_artisan/main.dart';
import 'package:sos_artisan/store.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.charger();
  });

  Future<void> demarrer(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SosArtisanApp());
  }

  testWidgets('Catégorie Électricité affiche Alpha Belem', (tester) async {
    await demarrer(tester);
    await tester.tap(find.text('Électricité'));
    await tester.pumpAndSettle();
    expect(find.text('Alpha Belem'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
  });

  testWidgets('Recherche sans accents', (tester) async {
    await demarrer(tester);
    await tester.tap(find.text('Rechercher un artisan ou un métier…'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'macon');
    await tester.pumpAndSettle();
    expect(find.text('Aziz Belem'), findsOneWidget);
    expect(find.text('Alpha Belem'), findsNothing);
  });

  testWidgets('Favori puis page Mes favoris', (tester) async {
    await demarrer(tester);
    await tester.tap(find.text('Soudure'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();
    expect(store.favoris.single.nom, 'Alexandre Kougoussi');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mes favoris'));
    await tester.pumpAndSettle();
    expect(find.text('Alexandre Kougoussi'), findsOneWidget);
  });

  testWidgets('Ajouter un plombier', (tester) async {
    await demarrer(tester);
    await tester.tap(find.text('Plomberie'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucun artisan enregistré'), findsOneWidget);
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nom complet'), 'Issa Sawadogo');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Téléphone'), '70 11 22 33');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Issa Sawadogo'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('artisans_ajoutes'), hasLength(1));
  });
}
