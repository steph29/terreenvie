# 🔧 Configuration Email pour Firebase Functions

## ⚠️ Problème actuel

Les emails partent encore de l'ancienne adresse `communication.terreenvie@gmail.com` car les Firebase Functions déployées utilisent encore l'ancienne configuration.

## ✅ Solution : Utiliser les secrets Firebase

Firebase Functions v2 ne charge pas automatiquement le fichier `.env` lors du déploiement. Le code a été modifié pour utiliser les **secrets Firebase**.

### 1. Créer les secrets Firebase

```bash
# Créer le secret pour l'email
echo -n "benevole@terreenvie.com" | firebase functions:secrets:set EMAIL_USER

# Créer le secret pour le mot de passe (remplacez par votre vrai mot de passe)
echo -n "VOTRE_MOT_DE_PASSE_APPLICATION" | firebase functions:secrets:set EMAIL_PASSWORD
```

**Important :** Remplacez `VOTRE_MOT_DE_PASSE_APPLICATION` par le mot de passe d'application Gmail pour `benevole@terreenvie.com`.

### 2. Le code a déjà été modifié

Le fichier `functions/index.js` a été mis à jour pour utiliser les secrets Firebase. Il utilise automatiquement :

- Les secrets Firebase en production
- Le fichier `.env` en local (émulateur)

### 3. Redéployer les fonctions

```bash
firebase deploy --only functions
```

**Note :** Si vous obtenez une erreur concernant `nodejs20`, vous devrez peut-être mettre à jour votre Firebase CLI ou modifier la configuration.

## 🔄 Alternative : Variables d'environnement (moins sécurisé)

Si vous préférez utiliser les variables d'environnement classiques :

```bash
firebase functions:config:set email.user="benevole@terreenvie.com"
firebase functions:config:set email.password="vEyFKHqd@vRZas34F0*uj"
firebase deploy --only functions
```

Puis modifier `functions/index.js` pour utiliser :

```javascript
const functions = require("firebase-functions");
const emailUser = functions.config().email?.user || "benevole@terreenvie.com";
const emailPassword = functions.config().email?.password || "";
```

## 📝 Vérification

Après le déploiement, vérifiez que les emails partent bien de `benevole@terreenvie.com` en envoyant un email de test.
