# Terre en Vie - Application de Gestion des Bénévoles

## 🎯 Description

Application Flutter pour la gestion des bénévoles de l'association Terre en Vie. Permet l'inscription aux créneaux, la gestion des postes, et l'analyse des données de participation.

## ✨ Fonctionnalités Principales

### 📊 Analytics et Visualisation

- **Graphe Radar Interactif** : Affichage du taux de remplissage par poste et créneau horaire
- **Sélecteur de jours** : Lundi à Dimanche avec jour actuel par défaut
- **Slider horaire** : Filtrage par créneau de temps
- **Calculs en temps réel** : Pourcentages de remplissage dynamiques

### 📄 Génération de PDF Professionnels

- **PDF "Ki ké où?"** : Liste des bénévoles par poste et jour sélectionnés
- **PDF "Télécharger la liste des entrées"** : Liste complète des bénévoles
- **Logo Terre en Vie** intégré dans tous les PDF
- **Format professionnel** avec en-têtes et tableaux structurés
- **Support Unicode complet** avec polices Times Roman

### 🔔 Système de Notifications

- **Notifications personnalisées** avec templates variables
- **Envoi individuel** et général aux bénévoles
- **Interface admin** pour la gestion des notifications
- **Templates prédéfinis** pour les messages courants

### 👥 Gestion des Utilisateurs

- **Inscription/Connexion** avec Firebase Authentication
- **Profils bénévoles** avec informations personnelles
- **Gestion des créneaux** : inscription/désinscription
- **Interface responsive** pour mobile et web

### 🛠️ Administration

- **Gestion des postes** : création, modification, suppression
- **Gestion des horaires** : configuration des créneaux
- **Tableau de bord** avec statistiques
- **Export de données** en PDF

## 🚀 Installation

### Prérequis

- Flutter SDK (version 3.0 ou supérieure)
- Dart SDK
- Firebase project configuré

### Étapes d'installation

1. **Cloner le repository**

```bash
git clone https://github.com/steph29/terreenvie.git
cd terreenvie
```

2. **Installer les dépendances**

```bash
flutter pub get
```

3. **Configurer Firebase**

   - Ajouter `google-services.json` (Android)
   - Ajouter `GoogleService-Info.plist` (iOS)
   - Configurer les règles Firestore

4. **Lancer l'application**

```bash
flutter run
```

## 📱 Plateformes Supportées

- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11+)
- ✅ **Desktop** (Windows, macOS, Linux)

## 🏗️ Architecture

### Structure des Données Firebase

#### Collection `users`

```json
{
  "uid": "string",
  "nom": "string",
  "prenom": "string",
  "email": "string",
  "tel": "string",
  "fcmToken": "string"
}
```

#### Collection `pos_hor`

```json
{
  "poste": "string",
  "desc": "string",
  "hor": [
    {
      "debut": "09h00",
      "fin": "12h00",
      "nbBen": 6,
      "tot": 6,
      "check": false
    }
  ]
}
```

#### Collection `pos_ben`

```json
{
  "ben_id": "string",
  "createdAt": "timestamp",
  "pos_id": [
    {
      "poste": "string",
      "jour": "string",
      "debut": "string",
      "fin": "string",
      "posteID": "string"
    }
  ]
}
```

## 🔧 Technologies Utilisées

- **Frontend** : Flutter 3.x
- **Backend** : Firebase (Firestore, Authentication, Cloud Messaging)
- **PDF** : syncfusion_flutter_pdf, printing
- **Graphiques** : fl_chart
- **État** : Provider, GetX
- **Notifications** : firebase_messaging

## 📊 Fonctionnalités Avancées

### Graphe Radar

- Affichage du taux de remplissage par poste
- Filtrage par jour et créneau horaire
- Calculs automatiques des pourcentages
- Gestion d'erreur robuste

### Génération PDF

- Templates professionnels
- Intégration du logo Terre en Vie
- Tableaux structurés avec en-têtes
- Support multilingue (Unicode)

### Notifications

- Templates personnalisables
- Variables dynamiques (nom, créneaux, etc.)
- Envoi individuel ou général
- Interface admin intuitive

## 🧪 Tests

L'application a été testée sur :

- ✅ Chrome (Web)
- ✅ Firefox (Web)
- ✅ Safari (Web)
- ✅ Android (API 21+)
- ✅ iOS (Simulateur)

## 📈 Performance

- **Chargement centralisé** des données pour optimiser les performances
- **Gestion d'état efficace** avec Provider et GetX
- **Assets optimisés** pour le web et mobile
- **Code modulaire** pour faciliter la maintenance

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👨‍💻 Développement

### Branches principales

- `master` : Version stable
- `feature/*` : Nouvelles fonctionnalités
- `hotfix/*` : Corrections urgentes

### Version actuelle

- **v1.0.0** : Version stable avec toutes les fonctionnalités

## 📞 Support

Pour toute question ou problème :

- Créer une issue sur GitHub
- Contacter l'équipe de développement

---

**Terre en Vie** - Application de gestion des bénévoles
