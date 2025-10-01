# Guide de Configuration Gmail pour Firebase Functions

## 🔧 Problème Actuel

Gmail nécessite un "mot de passe d'application" pour les applications tierces comme Firebase Functions. Le mot de passe normal ne fonctionne pas.

## ✅ Solution : Créer un Mot de Passe d'Application

### Étape 1 : Accéder aux Paramètres Google

1. Allez sur https://myaccount.google.com/
2. Cliquez sur **Sécurité**
3. Dans la section **Connexion à Google**, cliquez sur **Mots de passe d'application**

### Étape 2 : Activer l'Authentification à 2 Facteurs (si pas déjà fait)

1. Dans **Sécurité** → **Connexion à Google**
2. Activez **Validation en 2 étapes** si ce n'est pas déjà fait

### Étape 3 : Créer un Mot de Passe d'Application

1. Dans **Mots de passe d'application**
2. Sélectionnez **Application** : "Autre (nom personnalisé)"
3. Entrez le nom : "Terre en Vie"
4. Cliquez sur **Générer**
5. **Copiez le mot de passe généré** (16 caractères)

### Étape 4 : Mettre à Jour les Firebase Functions

1. Modifiez le fichier `functions/.env` :

```
EMAIL_PASSWORD=votre_mot_de_passe_d_application_ici
```

2. Redéployez les fonctions :

```bash
firebase deploy --only functions
```

## 🔍 Test de la Configuration

Testez avec curl :

```bash
curl -X POST https://sendemail-7mzwe64jha-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{"to":"votre_email@example.com","subject":"Test","body":"Test email"}'
```

## 📧 Vérification

- Vérifiez votre boîte de réception
- Vérifiez les logs dans Firebase Console → Functions → Logs

## 🚨 Important

- Le mot de passe d'application est différent du mot de passe de connexion
- Gardez ce mot de passe en sécurité
- Vous pouvez révoquer ce mot de passe à tout moment dans les paramètres Google

## 🔄 Alternative : SendGrid

Si Gmail pose problème, nous pouvons migrer vers SendGrid qui est plus adapté pour les applications web.
