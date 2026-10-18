import 'package:flutter/material.dart';

import 'actions.dart';
import 'data.dart';
import 'store.dart';

class CarteArtisan extends StatelessWidget {
  final Artisan artisan;

  const CarteArtisan({super.key, required this.artisan});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final favori = store.estFavori(artisan);
        return Card(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                onTap: () => afficherFicheArtisan(context, artisan),
                leading: CircleAvatar(
                  backgroundColor: bleuMarine,
                  child: Icon(iconeCategorie(artisan.categorie), color: or),
                ),
                title: Text(
                  artisan.nom,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text([
                  artisan.metier,
                  if (artisan.ville.isNotEmpty) artisan.ville,
                  '+226 ${artisan.telephoneAffiche}',
                ].join('\n')),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: favori ? 'Retirer des favoris' : 'Ajouter aux favoris',
                  icon: Icon(favori ? Icons.star : Icons.star_border,
                      color: favori ? or : Colors.grey),
                  onPressed: () => store.basculerFavori(artisan),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: bleuMarine,
                        ),
                        onPressed: () => appeler(context, artisan.telephone),
                        icon: const Icon(Icons.call),
                        label: const Text('Appeler'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                        ),
                        onPressed: () => ouvrirWhatsApp(context, artisan),
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> afficherFicheArtisan(BuildContext context, Artisan a) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final favori = store.estFavori(a);
          return ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: bleuMarine,
                  child: Icon(iconeCategorie(a.categorie), color: or),
                ),
                title: Text(a.nom,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('${a.metier} · ${a.categorie}'
                    '${a.ville.isNotEmpty ? ' · ${a.ville}' : ''}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.call, color: bleuMarine),
                title: Text('Appeler +226 ${a.telephoneAffiche}'),
                onTap: () => appeler(context, a.telephone),
              ),
              ListTile(
                leading: const Icon(Icons.sms, color: bleuMarine),
                title: const Text('Envoyer un SMS'),
                onTap: () => envoyerSms(context, a),
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
                title: const Text('Écrire sur WhatsApp'),
                onTap: () => ouvrirWhatsApp(context, a),
              ),
              ListTile(
                leading: const Icon(Icons.my_location, color: Color(0xFF25D366)),
                title: const Text('Envoyer ma position GPS (WhatsApp)'),
                subtitle: const Text('L’artisan reçoit un lien Google Maps'),
                onTap: () async {
                  final p = await obtenirPosition(context);
                  if (p == null || !context.mounted) return;
                  await ouvrirWhatsApp(context, a,
                      texte: '${messageContact(a)}\nMa position : '
                          '${lienPosition(p)}');
                },
              ),
              ListTile(
                leading: Icon(favori ? Icons.star : Icons.star_border,
                    color: or),
                title: Text(
                    favori ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                onTap: () => store.basculerFavori(a),
              ),
              if (a.ajouteParUtilisateur)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Supprimer cet artisan'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await store.supprimer(a);
                  },
                ),
            ],
          );
        },
      ),
    ),
  );
}

class ListeArtisans extends StatelessWidget {
  final List<Artisan> artisans;
  final String messageVide;

  const ListeArtisans({
    super.key,
    required this.artisans,
    this.messageVide = 'Aucun artisan enregistré pour le moment.',
  });

  @override
  Widget build(BuildContext context) {
    if (artisans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              Text(messageVide, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: artisans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => CarteArtisan(artisan: artisans[i]),
    );
  }
}
