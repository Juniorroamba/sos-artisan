import 'package:flutter/material.dart';

import 'data.dart';
import 'pages.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await store.charger();
  } catch (e) {
    debugPrint('Chargement des données locales impossible : $e');
  }
  runApp(const SosArtisanApp());
}

class SosArtisanApp extends StatelessWidget {
  const SosArtisanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS ARTISAN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: bleuMarine,
          primary: bleuMarine,
          secondary: or,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: bleuMarine,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const AccueilPage(),
    );
  }
}

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  void _ouvrir(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SOS ARTISAN',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Mes favoris',
            icon: const Icon(Icons.star),
            onPressed: () => _ouvrir(context, const FavorisPage()),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: bleuMarine),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.handyman, color: or, size: 42),
                  SizedBox(height: 8),
                  Text(
                    'SOS ARTISAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Un artisan qualifié, à portée de main.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Accueil'),
              onTap: () => Navigator.pop(context),
            ),
            for (final (icone, titre, page) in [
              (Icons.people_outline, 'Tous les artisans', const ArtisansPage()),
              (Icons.category_outlined, 'Métiers', const CategoriesPage()),
              (Icons.near_me_outlined, 'Près de moi', const ProcheDeMoiPage()),
              (Icons.star_outline, 'Mes favoris', const FavorisPage()),
              (Icons.person_add_alt, 'Ajouter un artisan',
                  const AjouterArtisanPage()),
              (Icons.info_outline, 'À propos', const AProposPage()),
            ])
              ListTile(
                leading: Icon(icone),
                title: Text(titre),
                onTap: () {
                  Navigator.pop(context);
                  _ouvrir(context, page);
                },
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: bleuMarine,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.handyman, color: or, size: 42),
                  SizedBox(height: 12),
                  Text(
                    'Besoin d’un professionnel ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Trouvez un artisan pour vos travaux, réparations et dépannages.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              onTap: () => _ouvrir(context, const ArtisansPage()),
              decoration: InputDecoration(
                hintText: 'Rechercher un artisan ou un métier…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BoutonRapide(
                    icone: Icons.near_me,
                    texte: 'Près de moi',
                    onTap: () => _ouvrir(context, const ProcheDeMoiPage()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BoutonRapide(
                    icone: Icons.person_add,
                    texte: 'Ajouter',
                    onTap: () => _ouvrir(context, const AjouterArtisanPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Que recherchez-vous ?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (context, index) {
                final c = categories[index];
                return Card(
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () =>
                        _ouvrir(context, ArtisansPage(categorie: c.nom)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(c.icone, color: bleuMarine, size: 28),
                          const SizedBox(height: 7),
                          Text(
                            c.nom,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: or,
                  foregroundColor: bleuMarine,
                ),
                icon: const Icon(Icons.people),
                label: const Text(
                  'Voir tous les artisans',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _ouvrir(context, const ArtisansPage()),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Architecte créateur — $createurNom',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Text(
              'Contact : +226 73 24 61 44 / +226 65 41 45 10',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Text(
              createurEmail,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutonRapide extends StatelessWidget {
  final IconData icone;
  final String texte;
  final VoidCallback onTap;

  const _BoutonRapide({
    required this.icone,
    required this.texte,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: bleuMarine),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  texte,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
