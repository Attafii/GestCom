# Système de Sauvegarde et Restauration Automatique - GestCom

## Vue d'ensemble

GestCom dispose maintenant d'un système complet de sauvegarde et restauration automatique pour protéger vos données contre la perte ou la corruption.

## Fonctionnalités

### ✅ Sauvegarde Automatique
- **Fréquence configurable** : Choisissez entre plusieurs intervalles
  - Toutes les heures
  - Toutes les 3 heures
  - Toutes les 6 heures
  - Toutes les 12 heures
  - Une fois par jour (défaut)
  - Tous les 2 jours
  - Une fois par semaine

- **Activation/Désactivation** : Toggle simple dans les paramètres
- **Sauvegarde au démarrage** : Une sauvegarde est créée automatiquement au lancement si activée
- **Gestion automatique des anciennes sauvegardes** : Conservation des 10 dernières sauvegardes uniquement

### ✅ Sauvegarde Manuelle
- **Création immédiate** : Bouton pour créer une sauvegarde à tout moment
- **Feedback visuel** : Indicateur de progression pendant la création
- **Confirmation** : Notification de succès/échec avec détails

### ✅ Restauration de Sauvegarde
- **Liste des sauvegardes disponibles** : Affichage de toutes les sauvegardes avec métadonnées
- **Aperçu détaillé** : 
  - Nom du fichier
  - Date et heure de création
  - Taille du fichier
  - Nombre d'éléments
  - Version
- **Restauration sécurisée** : Confirmation obligatoire avant restauration
- **Avertissement** : Message clair sur le remplacement des données actuelles

### ✅ Gestion des Sauvegardes
- **Suppression** : Possibilité de supprimer les sauvegardes anciennes
- **Rafraîchissement** : Bouton pour actualiser la liste
- **Stockage local** : Sauvegardes dans le dossier Documents de l'utilisateur

## Architecture Technique

### Composants

#### 1. BackupService (`lib/core/services/backup_service.dart`)
Service principal gérant toutes les opérations de sauvegarde/restauration.

**Méthodes principales :**
```dart
// Démarrer la sauvegarde automatique
Future<void> startAutomaticBackup(int intervalHours)

// Arrêter la sauvegarde automatique
void stopAutomaticBackup()

// Créer une sauvegarde
Future<BackupResult> createBackup()

// Obtenir la liste des sauvegardes
Future<List<BackupInfo>> getAvailableBackups()

// Restaurer une sauvegarde
Future<RestoreResult> restoreBackup(String backupFilePath)

// Supprimer une sauvegarde
Future<bool> deleteBackup(String backupFilePath)
```

**Fonctionnalités :**
- Timer automatique pour sauvegardes périodiques
- Sérialisation JSON de toutes les boxes Hive
- Nettoyage automatique des anciennes sauvegardes
- Gestion des erreurs robuste
- Logging détaillé pour débogage

#### 2. Providers (`lib/core/providers/backup_providers.dart`)

**backupServiceProvider**
```dart
final backupServiceProvider = Provider<BackupService>((ref) {
  final service = BackupService();
  final settings = ref.watch(backupSettingsProvider);
  if (settings?.autoBackupEnabled == true) {
    service.startAutomaticBackup(settings.backupIntervalHours);
  }
  return service;
});
```

**backupSettingsProvider**
```dart
final backupSettingsProvider = StateNotifierProvider<BackupSettingsNotifier, BackupSettings?>
```
Gère les paramètres de sauvegarde :
- Activation/désactivation
- Intervalle de sauvegarde
- Nombre de sauvegardes à conserver
- Date de dernière sauvegarde

**availableBackupsProvider**
```dart
final availableBackupsProvider = FutureProvider<List<BackupInfo>>
```
Liste actualisée des sauvegardes disponibles.

#### 3. UI - BackupSettingsScreen (`lib/features/settings/presentation/screens/backup_settings_screen.dart`)

Interface utilisateur complète avec :
- **Card de paramètres** : Configuration de la sauvegarde automatique
- **Card de sauvegarde manuelle** : Bouton pour créer une sauvegarde immédiate
- **Card de sauvegardes disponibles** : Liste avec actions (restaurer/supprimer)

**Composants UI :**
- Toggle pour activer/désactiver
- Sélecteur de fréquence (dialog avec radio buttons)
- Liste scrollable des sauvegardes
- Boutons d'action avec confirmations
- Indicateurs de chargement
- Messages de succès/erreur

## Format de Sauvegarde

### Structure JSON
```json
{
  "timestamp": "2024-10-04T15:30:00.000Z",
  "version": "1.0",
  "boxes": {
    "clients": {
      "client_id_1": { /* données client */ },
      "client_id_2": { /* données client */ }
    },
    "articles": {
      "article_id_1": { /* données article */ },
      "article_id_2": { /* données article */ }
    },
    "receptions": { /* ... */ },
    "livraisons": { /* ... */ },
    "factures": { /* ... */ },
    "treatments": { /* ... */ },
    "notification_settings": { /* ... */ },
    "tasks": { /* ... */ }
  }
}
```

### Nom de Fichier
Format : `backup_YYYY-MM-DD_HH-mm-ss.json`

Exemple : `backup_2024-10-04_15-30-25.json`

### Emplacement
`C:\Users\[Username]\Documents\backups\`

## Utilisation

### 1. Accéder aux Paramètres de Sauvegarde

1. Cliquez sur l'icône **Paramètres** dans la barre de navigation
2. La page "Sauvegarde et Restauration" s'affiche automatiquement

### 2. Configurer la Sauvegarde Automatique

1. Activez le toggle **"Sauvegarde automatique"**
2. Cliquez sur **"Fréquence de sauvegarde"**
3. Sélectionnez l'intervalle souhaité
4. Les sauvegardes se créeront automatiquement selon l'intervalle choisi

### 3. Créer une Sauvegarde Manuelle

1. Cliquez sur le bouton **"Créer une sauvegarde"**
2. Attendez la fin de l'opération (quelques secondes)
3. Un message de confirmation s'affiche avec le nom du fichier
4. La nouvelle sauvegarde apparaît dans la liste

### 4. Restaurer une Sauvegarde

1. Dans la liste des sauvegardes, repérez celle que vous souhaitez restaurer
2. Cliquez sur l'icône **Restaurer** (↻)
3. Lisez attentivement l'avertissement
4. Confirmez en cliquant sur **"Restaurer"**
5. Attendez la fin de l'opération
6. **Important** : Redémarrez l'application pour appliquer tous les changements

### 5. Supprimer une Sauvegarde

1. Cliquez sur l'icône **Supprimer** (🗑️) à côté de la sauvegarde
2. Confirmez la suppression
3. La sauvegarde est supprimée définitivement

## Gestion des Erreurs

### Erreurs Courantes et Solutions

**1. Erreur de création de sauvegarde**
- **Cause** : Espace disque insuffisant, permissions d'écriture
- **Solution** : Vérifiez l'espace disque disponible et les permissions du dossier Documents

**2. Erreur de restauration**
- **Cause** : Fichier corrompu, format invalide
- **Solution** : Essayez avec une autre sauvegarde, vérifiez l'intégrité du fichier

**3. Timer ne démarre pas**
- **Cause** : Paramètres non chargés, erreur d'initialisation
- **Solution** : Désactivez/réactivez la sauvegarde automatique

### Logging

Tous les événements sont loggés dans la console de debug :
```
Creating backup...
Backed up clients: 15 items
Backed up articles: 45 items
...
Backup created successfully: backup_2024-10-04_15-30-25.json (245.3 KB)
```

## Bonnes Pratiques

### Recommandations

1. **Fréquence de sauvegarde** :
   - Usage intensif : Toutes les 3-6 heures
   - Usage normal : Une fois par jour
   - Usage occasionnel : Tous les 2-7 jours

2. **Avant modifications importantes** :
   - Créez toujours une sauvegarde manuelle
   - Vérifiez que la sauvegarde est bien créée

3. **Stockage** :
   - Les sauvegardes sont conservées localement uniquement
   - Copiez manuellement les fichiers vers un stockage cloud ou externe pour une protection supplémentaire
   - Les 10 dernières sauvegardes sont conservées automatiquement

4. **Restauration** :
   - Utilisez uniquement en cas de problème réel
   - Créez une sauvegarde de l'état actuel avant restauration (si possible)
   - Redémarrez toujours l'application après restauration

5. **Maintenance** :
   - Vérifiez périodiquement l'espace disque
   - Supprimez les très anciennes sauvegardes si nécessaire
   - Testez occasionnellement une restauration sur un environnement de test

## Sécurité

### Données Sauvegardées
- Toutes les boxes Hive de l'application
- Pas de données sensibles externes
- Format JSON lisible (non chiffré)

### Considérations
- **Pas de chiffrement** : Les sauvegardes sont en texte clair
- **Stockage local** : Les fichiers sont sur le disque local de l'utilisateur
- **Permissions** : Protégé par les permissions du système d'exploitation

### Pour une sécurité renforcée (future)
- Chiffrement AES des fichiers de sauvegarde
- Sauvegarde cloud automatique
- Authentification pour restauration
- Compression des données

## Performances

### Temps de Création
- Petit dataset (< 100 items) : < 1 seconde
- Dataset moyen (100-1000 items) : 1-3 secondes
- Grand dataset (> 1000 items) : 3-10 secondes

### Taille des Fichiers
- Varie selon le volume de données
- Typiquement : 50 KB - 5 MB
- Format JSON avec indentation (lisible)

### Impact sur l'Application
- **Création** : Opération asynchrone, n'affecte pas l'UI
- **Restauration** : Bloque l'UI temporairement (nécessaire)
- **Timer automatique** : Impact négligeable sur les performances

## Maintenance et Évolution

### Extensions Futures Possibles

1. **Sauvegarde cloud**
   - Google Drive integration
   - Dropbox sync
   - OneDrive backup

2. **Compression**
   - Format .zip ou .gz
   - Réduction de la taille des fichiers

3. **Chiffrement**
   - Protection par mot de passe
   - Chiffrement AES-256

4. **Sauvegarde sélective**
   - Choisir les tables à sauvegarder
   - Sauvegarde par catégorie

5. **Import/Export**
   - Export vers Excel/CSV
   - Import depuis d'autres formats

6. **Historique détaillé**
   - Journal des sauvegardes/restaurations
   - Statistiques

## Support et Dépannage

### Fichiers de Log
Les logs sont disponibles dans la console de debug de Flutter.

### Dossier de Sauvegarde
Ouvrir manuellement : `C:\Users\[Username]\Documents\backups\`

### Restauration Manuelle
En cas de problème avec l'interface :
1. Localisez le fichier .json de sauvegarde
2. Copiez son contenu
3. Utilisez un outil de gestion Hive pour importer les données

### Contact Support
En cas de problème persistant, conservez :
- Le fichier de sauvegarde problématique
- Les logs de la console
- Description détaillée du problème

---

**Version** : 1.0  
**Date** : Octobre 2024  
**Status** : ✅ Production Ready
