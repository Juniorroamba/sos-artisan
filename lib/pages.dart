import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'actions.dart';
import 'data.dart';
import 'store.dart';
import 'widgets.dart';

class ArtisansPage extends StatefulWidget {
  final String? categorie;
  final String rechercheInitiale;

  const ArtisansPage({super.key, this.categorie, this.rechercheInitiale = ''});

  @override
  State<ArtisansPage> createState() => _ArtisansPageState();
}

class _ArtisansPageState extends State<ArtisansPage> {
  late final TextEditingController _controleur =
      TextEditingController(text: widget.rechercheInitiale);

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categorie = widget.categorie;
    return Scaffold(
      appBar: AppBar(title: Text(categorie ?? 'Tous les artisans')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: or,
        foregroundColor: bleuMarine,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AjouterArtisanPage(categorie: categorie),
          ),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _controleur,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher un nom, un métier, une ville…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controleur.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(_controleur.clear),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (categorie != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: OutlinedButton.icon(
                onPressed: () => _chercherSurCarte(context, categorie),
                icon: const Icon(Icons.map_outlined),
                label: Text('Chercher « $categorie » près de moi sur la carte'),
              ),
            ),
          Expanded(
            child: ListenableBuilder(
              listenable: store,
              builder: (context, _) {
                var liste = store.rechercher(_controleur.text);
                if (categorie != null) {
                  liste = liste.where((a) => a.categorie == categorie).toList();
                }
                return ListeArtisans(
                  artisans: liste,
                  messageVide: categorie == null
                      ? 'Aucun artisan ne correspond à votre recherche.'
                      : 'Aucun artisan enregistré pour « $categorie » pour '
                          'le moment.\nAjoutez-en un avec le bouton « Ajouter » '
                          'ou cherchez sur la carte.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _chercherSurCarte(BuildContext context, String categorie) async {
  final p = await obtenirPosition(context);
  if (!context.mounted) return;
  await ouvrirCarte(context, categorie, position: p);
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nos métiers')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final c = categories[index];
            final nombre = store.parCategorie(c.nom).length;
            return Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(c.icone, color: bleuMarine),
                title: Text(c.nom),
                subtitle: Text(nombre == 0
                    ? 'Aucun artisan pour le moment'
                    : '$nombre artisan${nombre > 1 ? 's' : ''}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtisansPage(categorie: c.nom),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FavorisPage extends StatelessWidget {
  const FavorisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListeArtisans(
          artisans: store.favoris,
          messageVide: 'Aucun favori.\nTouchez l’étoile d’un artisan pour '
              'l’ajouter ici.',
        ),
      ),
    );
  }
}

class AjouterArtisanPage extends StatefulWidget {
  final String? categorie;

  const AjouterArtisanPage({super.key, this.categorie});

  @override
  State<AjouterArtisanPage> createState() => _AjouterArtisanPageState();
}

class _AjouterArtisanPageState extends State<AjouterArtisanPage> {
  final _formulaire = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _metier = TextEditingController();
  final _telephone = TextEditingController();
  final _ville = TextEditingController();
  late String? _categorie = widget.categorie;

  @override
  void dispose() {
    for (final c in [_nom, _metier, _telephone, _ville]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final telephone = _telephone.text.replaceAll(RegExp(r'\D'), '');
    await store.ajouter(Artisan(
      id: 'u${DateTime.now().microsecondsSinceEpoch}',
      nom: _nom.text.trim(),
      metier: _metier.text.trim().isEmpty ? _categorie! : _metier.text.trim(),
      categorie: _categorie!,
      telephone: telephone.length == 11 && telephone.startsWith('226')
          ? telephone.substring(3)
          : telephone,
      ville: _ville.text.trim(),
      ajouteParUtilisateur: true,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_nom.text.trim()} a été ajouté.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String label, IconData icone, {String? aide}) =>
        InputDecoration(
          labelText: label,
          helperText: aide,
          prefixIcon: Icon(icone),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un artisan')),
      body: Form(
        key: _formulaire,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nom,
              textCapitalization: TextCapitalization.words,
              decoration: deco('Nom complet', Icons.person),
              validator: (v) =>
                  (v ?? '').trim().length < 3 ? 'Entrez le nom complet' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categorie,
              isExpanded: true,
              decoration: deco('Catégorie', Icons.category),
              items: [
                for (final c in categories)
                  DropdownMenuItem(value: c.nom, child: Text(c.nom)),
              ],
              onChanged: (v) => setState(() => _categorie = v),
              validator: (v) => v == null ? 'Choisissez une catégorie' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _metier,
              textCapitalization: TextCapitalization.sentences,
              decoration: deco('Métier précis (facultatif)', Icons.work,
                  aide: 'Ex. : Plombier, Vulcanisateur…'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telephone,
              keyboardType: TextInputType.phone,
              decoration: deco('Téléphone', Icons.phone,
                  aide: '8 chiffres, ex. : 70 25 04 97'),
              validator: (v) {
                final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                final ok = d.length == 8 ||
                    (d.length == 11 && d.startsWith('226'));
                return ok ? null : 'Numéro burkinabè à 8 chiffres attendu';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ville,
              textCapitalization: TextCapitalization.words,
              decoration: deco('Ville / quartier (facultatif)',
                  Icons.location_city),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: or,
                  foregroundColor: bleuMarine,
                ),
                onPressed: _enregistrer,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'L’artisan est enregistré sur cet appareil.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ProcheDeMoiPage extends StatefulWidget {
  const ProcheDeMoiPage({super.key});

  @override
  State<ProcheDeMoiPage> createState() => _ProcheDeMoiPageState();
}

class _ProcheDeMoiPageState extends State<ProcheDeMoiPage> {
  Position? _position;
  bool _chargement = false;

  Future<void> _localiser() async {
    setState(() => _chargement = true);
    final p = await obtenirPosition(context);
    if (!mounted) return;
    setState(() {
      _position = p ?? _position;
      _chargement = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _localiser());
  }

  @override
  Widget build(BuildContext context) {
    final p = _position;
    return Scaffold(
      appBar: AppBar(title: const Text('Près de moi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            child: ListTile(
              leading: _chargement
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(p == null ? Icons.location_off : Icons.my_location,
                      color: bleuMarine),
              title: Text(p == null
                  ? (_chargement
                      ? 'Localisation en cours…'
                      : 'Position inconnue')
                  : 'Votre position'),
              subtitle: p == null
                  ? null
                  : Text('${p.latitude.toStringAsFixed(5)}, '
                      '${p.longitude.toStringAsFixed(5)} '
                      '(± ${p.accuracy.round()} m)'),
              trailing: IconButton(
                tooltip: 'Actualiser',
                icon: const Icon(Icons.refresh),
                onPressed: _chargement ? null : _localiser,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Trouver un professionnel autour de moi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final c in categories)
            Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(c.icone, color: bleuMarine),
                title: Text(c.nom),
                trailing: const Icon(Icons.map_outlined),
                onTap: () => ouvrirCarte(context, c.nom, position: p),
              ),
            ),
        ],
      ),
    );
  }
}

class AProposPage extends StatelessWidget {
  const AProposPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.handyman, color: or, size: 64),
          const SizedBox(height: 8),
          const Text(
            'SOS ARTISAN',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: bleuMarine),
          ),
          const Text(
            'Un artisan qualifié, à portée de main.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const ListTile(
            leading: Icon(Icons.person, color: bleuMarine),
            title: Text('Architecte créateur'),
            subtitle: Text(createurNom),
          ),
          for (final t in createurTelephones)
            ListTile(
              leading: const Icon(Icons.call, color: bleuMarine),
              title: Text('+226 ${t.substring(0, 2)} ${t.substring(2, 4)} '
                  '${t.substring(4, 6)} ${t.substring(6)}'),
              onTap: () => appeler(context, t),
            ),
          ListTile(
            leading: const Icon(Icons.email, color: bleuMarine),
            title: const Text(createurEmail),
            onTap: () => envoyerEmail(context, createurEmail),
          ),
        ],
      ),
    );
  }
}
