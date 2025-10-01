# Guide de dépannage - Problèmes de cache Flutter Web

## Problème : Page blanche après la première visite

### Symptômes

- L'application fonctionne la première fois
- Les visites suivantes affichent une page blanche
- Obligation d'effacer l'historique pour que l'app fonctionne à nouveau

### Causes identifiées

1. **Service Worker** : Cache agressif des assets Flutter
2. **Cache navigateur** : Mise en cache des fichiers JS/Dart
3. **localStorage/sessionStorage** : Données corrompues
4. **Headers de cache** : Configuration serveur inadéquate

## Solutions mises en place

### 1. **Désactivation du Service Worker**

```javascript
// Dans web/index.html
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.getRegistrations().then(function (registrations) {
    for (let registration of registrations) {
      registration.unregister();
    }
  });
}
```

### 2. **Nettoyage automatique du cache**

```javascript
// Nettoyage localStorage et sessionStorage
window.addEventListener("beforeunload", function () {
  try {
    localStorage.clear();
    sessionStorage.clear();
  } catch (e) {
    console.log("Erreur lors du nettoyage du cache:", e);
  }
});
```

### 3. **Headers de cache désactivés**

```html
<!-- Dans web/index.html -->
<meta
  http-equiv="Cache-Control"
  content="no-cache, no-store, must-revalidate"
/>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
```

### 4. **Configuration Firebase Hosting**

```json
// Dans firebase.json
"headers": [
  {
    "source": "**",
    "headers": [
      {
        "key": "Cache-Control",
        "value": "no-cache, no-store, must-revalidate"
      }
    ]
  }
]
```

### 5. **Fichier .htaccess pour serveurs Apache**

```apache
# Désactiver le cache pour les fichiers Flutter
<FilesMatch "\.(js|dart\.js|wasm|json)$">
    Header set Cache-Control "no-cache, no-store, must-revalidate"
</FilesMatch>
```

## Actions à effectuer

### 1. **Redéployer l'application**

```bash
# Nettoyer le build
flutter clean

# Reconstruire
flutter build web

# Redéployer sur Firebase
firebase deploy --only hosting
```

### 2. **Tester la solution**

1. Ouvrir l'application dans un navigateur
2. Fermer l'onglet
3. Rouvrir l'application dans le même onglet
4. Vérifier que l'application se charge correctement

### 3. **Vérifier les outils de développement**

- Ouvrir F12 (Outils de développement)
- Aller dans l'onglet "Application" ou "Storage"
- Vérifier que localStorage et sessionStorage sont vides
- Vérifier qu'aucun service worker n'est actif

## Solutions alternatives si le problème persiste

### 1. **Versioning des assets**

```bash
# Ajouter un timestamp aux assets
flutter build web --dart-define=BUILD_TIMESTAMP=$(date +%s)
```

### 2. **Configuration Flutter Web**

```dart
// Dans lib/main.dart
import 'package:flutter/foundation.dart';

void main() {
  if (kIsWeb) {
    // Désactiver le cache pour le web
    FlutterWebRenderer.html;
  }
  runApp(MyApp());
}
```

### 3. **Nettoyage manuel du cache**

```javascript
// Script de nettoyage à ajouter temporairement
function clearAllCache() {
  // Nettoyer localStorage
  localStorage.clear();

  // Nettoyer sessionStorage
  sessionStorage.clear();

  // Nettoyer le cache du navigateur
  if ("caches" in window) {
    caches.keys().then(function (names) {
      for (let name of names) {
        caches.delete(name);
      }
    });
  }

  // Recharger la page
  window.location.reload(true);
}
```

## Monitoring et prévention

### 1. **Surveillance des erreurs**

```javascript
// Ajouter dans web/index.html
window.addEventListener("error", function (e) {
  console.error("Erreur JavaScript:", e.error);
  // Optionnel: envoyer les erreurs à un service de monitoring
});
```

### 2. **Tests de régression**

- Tester régulièrement la navigation
- Vérifier le comportement sur différents navigateurs
- Surveiller les logs de la console

### 3. **Configuration de production**

- Utiliser des CDN avec invalidation de cache
- Configurer des headers de cache appropriés
- Mettre en place un système de versioning

## Commandes utiles

```bash
# Nettoyer complètement le projet
flutter clean
rm -rf build/
rm -rf .dart_tool/

# Reconstruire avec cache désactivé
flutter build web --no-tree-shake-icons

# Déployer avec force
firebase deploy --only hosting --force

# Vérifier la configuration
firebase hosting:channel:list
```

## Contacts et support

- **Documentation Flutter Web** : https://docs.flutter.dev/web
- **Firebase Hosting** : https://firebase.google.com/docs/hosting
- **Problèmes de cache** : Vérifier les logs de la console navigateur

---

_Ce guide doit être mis à jour selon les nouvelles versions de Flutter et les bonnes pratiques._
