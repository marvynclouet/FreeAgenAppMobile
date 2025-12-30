# 🔐 Configuration de la réinitialisation de mot de passe

## ✅ Fonctionnalités implémentées

1. **Page "Mot de passe oublié"** : Permet à l'utilisateur de demander une réinitialisation
2. **Page "Réinitialiser le mot de passe"** : Permet de définir un nouveau mot de passe avec un token
3. **Routes backend** : 
   - `POST /api/auth/forgot-password` : Génère un token de réinitialisation
   - `POST /api/auth/reset-password` : Réinitialise le mot de passe avec le token

## 📋 Étapes de configuration

### 1. Créer la table dans la base de données

Exécutez le script SQL pour créer la table `password_reset_tokens` :

```bash
cd backend/src/scripts
node create_password_reset_table.js
```

Ou exécutez directement le SQL dans votre base de données :

```sql
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at)
);
```

### 2. Utilisation dans l'application

#### Pour l'utilisateur :

1. Sur la page de connexion, cliquez sur **"Mot de passe oublié ?"**
2. Entrez votre adresse email
3. Un token de réinitialisation sera généré (actuellement affiché dans un dialog pour le développement)
4. Copiez le token et utilisez-le dans la page de réinitialisation
5. Entrez le token et votre nouveau mot de passe
6. Votre mot de passe sera réinitialisé et vous serez redirigé vers la page de connexion

## 🔒 Sécurité

- Les tokens expirent après **1 heure**
- Les tokens ne peuvent être utilisés qu'**une seule fois**
- Les anciens tokens non utilisés sont automatiquement supprimés lors de la génération d'un nouveau token
- Le mot de passe doit respecter les règles : au moins 6 caractères, une majuscule et un chiffre

## 📧 Envoi d'email (À implémenter)

Actuellement, le token est retourné dans la réponse API pour le développement. 

**Pour la production**, vous devez :

1. Installer un service d'envoi d'email (ex: Nodemailer, SendGrid, etc.)
2. Modifier la route `/api/auth/forgot-password` pour envoyer un email avec le lien :
   ```
   https://votre-app.com/reset-password?token={resetToken}
   ```
3. Retirer le champ `resetToken` de la réponse API
4. Créer une page web ou une deep link dans l'app pour gérer le token depuis l'email

## 🧪 Test

Pour tester la fonctionnalité :

1. Lancez l'application Flutter
2. Allez sur la page de connexion
3. Cliquez sur "Mot de passe oublié ?"
4. Entrez un email existant dans la base de données
5. Copiez le token affiché
6. Utilisez ce token dans la page de réinitialisation
7. Définissez un nouveau mot de passe
8. Connectez-vous avec le nouveau mot de passe

## 📝 Notes

- Les tokens sont stockés dans la table `password_reset_tokens`
- Les tokens expirés sont automatiquement ignorés
- Les tokens utilisés sont marqués comme `used = TRUE` et ne peuvent plus être réutilisés

