# Blog mobile (Flutter + Parse)

Application mobile de blog reliée au serveur Parse fourni par RightCom : inscription et connexion, fil d'articles paginé, détail avec commentaires, création et suppression d'article, likes.

## Pourquoi Flutter

La consigne demandait React Native avec Expo et le SDK JavaScript de Parse. Je suis développeur Flutter : j'ai préféré rendre un travail dans la technologie que je maîtrise et que je pourrai défendre en entretien. L'application utilise donc le paquet officiel `parse_server_sdk_flutter` (version 10.7.0), qui offre les mêmes fonctions que le SDK JavaScript (requêtes, sessions, fonctions serveur, LiveQuery).

## Prérequis

- Flutter 3.41 (Dart 3.11 ou plus).
- Node.js (testé avec la version 24) pour le serveur fourni.
- Xcode et un simulateur iOS, ou un émulateur Android.

## Lancement

1. Serveur Parse fourni (dossier `dev-server` livré avec la consigne) :

   ```bash
   cd dev-server && npm install && npm start
   ```

   Il écoute sur `http://localhost:1337/parse` (identifiant d'application `blog-app`). Les données sont remises à zéro à chaque redémarrage.

2. Application :

   ```bash
   flutter pub get && flutter run
   ```

   C'est l'équivalent de `npm install && npx expo start` demandé dans la consigne.

**Plateformes testées : simulateur iPhone 17 Pro (iOS 26.2) et téléphone Android physique (Samsung A17, branché en USB).**

## Adresse du serveur

Le fichier `lib/core/config/parse_config.dart` construit l'adresse du serveur :

- port `1337`, chemin `/parse`, identifiant d'application `blog-app` ;
- hôte par défaut `localhost` (simulateur iOS) ;
- hôte `10.0.2.2` automatiquement quand l'application tourne sur Android (émulateur) ;
- hôte forcé par la variable de compilation `PARSE_HOST`, par exemple pour un téléphone physique avec l'adresse IP locale du Mac :

  ```bash
  flutter run --dart-define=PARSE_HOST=192.168.1.20
  ```

Le même fichier initialise le SDK : adresse `http://<hôte>:1337/parse`, adresse LiveQuery `ws://<hôte>:1337/parse`, envoi automatique du jeton de session et stockage persistant (`CoreStoreSharedPreferences`) pour garder la session après un redémarrage.

## Comptes de test

| Utilisateur | Mot de passe |
|---|---|
| `alice` | `Password123!` |
| `bob` | `Password123!` |
| `carol` | `Password123!` |

## Fonctionnalités

| N° | Fonction | État |
|---|---|---|
| F1 | Authentification | Fait : inscription, connexion, déconnexion, session conservée au redémarrage, erreurs du serveur affichées en français. |
| F2 | Fil | Fait : plus récents d'abord, 10 par page, défilement infini, tirer pour rafraîchir. Titre, auteur, date, extrait, likes, commentaires. |
| F3 | Détail | Fait : article complet et commentaires du plus ancien au plus récent (auteur, date, texte), jusqu'à 100 commentaires. |
| F4 | Écriture | Fait : création si connecté avec la même validation que le serveur (titre 3 à 120, contenu 1 à 5000, texte nettoyé). Suppression par l'auteur avec boîte de confirmation. |
| F5 | Commentaire | Fait : champ toujours visible au-dessus du clavier, commentaire ajouté sans recharger l'écran, compteur mis à jour. |
| F6 | Like | Fait : bouton sur le fil et le détail, état « j'ai liké » chargé par une requête `Like` pour l'utilisateur courant et les articles affichés. Un visiteur est renvoyé vers la connexion. |
| F7 | Bases de l'expérience | Fait : états chargement, vide et erreur, boutons désactivés pendant les requêtes, plateformes testées indiquées dans ce README. |

| Bonus | État |
|---|---|
| Like optimiste | Fait : l'interface change tout de suite, retour arrière en cas d'erreur. |
| Tests de widgets | Fait : fil, détail, création et suppression, parcours de connexion. |
| Modifier son article | Pas fait. |
| Supprimer son commentaire | Pas fait. |
| Commentaires en temps réel (LiveQuery) | Fait : dans le détail, un commentaire ajouté ou supprimé par un autre utilisateur apparaît ou disparaît sans action, compteur compris. Pas de doublon avec son propre commentaire. Abonnement coupé à la fermeture de l'écran. |

## Choix techniques

- **Couches** :
  - `lib/core/` : thème (charte RightCom), routeur, erreurs, configuration Parse ;
  - `lib/data/models/` : modèles immuables ;
  - `lib/data/providers/` : seuls fichiers qui appellent le SDK Parse, ils lèvent une exception en cas d'échec ;
  - `lib/data/repositories/` : renvoient `Either<Failure, T>` (paquet `dartz`), l'interface ne voit jamais une exception ;
  - `lib/features/<fonction>/` : `cubit/` (logique et état) et `view/` (écrans) ;
  - `lib/shared/widgets/` : composants communs (boutons, champs, bandeau d'erreur, squelette de chargement).
- **Erreurs typées** : `ValidationFailure` (code 142), `NotFoundFailure` (101), `SessionFailure` (209, l'utilisateur est déconnecté), `NetworkFailure`, `UnknownFailure`, chacune avec un message lisible en français.
- **Gestion d'état** : Cubit avec `flutter_bloc`. L'état des likes est partagé entre le fil et le détail.
- **Navigation** : `go_router`.
- **Injection** : `RepositoryProvider` et `BlocProvider` construits dans `lib/app.dart`, sans singleton global hors du SDK Parse. Les tests remplacent les providers par des faux.
- **Session persistante** : stockage `CoreStoreSharedPreferences`, session vérifiée au démarrage auprès du serveur.
- **Likes** : la fonction serveur `toggleLike` bascule le like ; une requête `Like` filtrée sur l'utilisateur courant et les articles affichés (`whereContainedIn`) indique ce que j'ai liké.
- **Temps réel** : le provider des commentaires s'abonne avec `LiveQuery().client.subscribe` aux commentaires de l'article (événements création et suppression) et expose un `Stream`. Le cubit du détail l'écoute, ignore un commentaire déjà affiché (même `objectId`) et coupe l'abonnement (`unSubscribe`) à sa fermeture.
- **Dates** : `intl`, affichage relatif en français.

## Tests

```bash
flutter test
```

Les tests couvrent les cubits, le dépôt d'authentification, la traduction des erreurs Parse, le format des dates et les écrans principaux (tests de widgets avec des providers simulés, sans serveur).

## Améliorations possibles

- Modifier son article et supprimer son commentaire.
- Pagination des commentaires au-delà de 100.
- Cache local pour consulter le fil hors ligne.
- Tests d'intégration contre le serveur fourni.
