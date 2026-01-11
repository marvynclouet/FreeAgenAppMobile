# 🔐 Guide - Compte de Test pour Google Play Console

## Problème
Google Play Console demande des identifiants de connexion pour examiner votre application car elle nécessite une authentification.

## Solution

### Étape 1 : Créer le compte de test

Exécutez le script pour créer un compte de test :

```bash
cd backend/src
node scripts/create_playstore_test_account.js
```

**OU** créez manuellement un compte via l'application avec ces identifiants :

```
📧 Email: playstore.test@freeagent.app
🔑 Mot de passe: GooglePlay2024!Test
👤 Nom: Google Play Test Account
🎯 Type de profil: Joueur
```

### Étape 2 : Ajouter les identifiants dans Google Play Console

1. **Connectez-vous à Google Play Console**
   - Allez sur [play.google.com/console](https://play.google.com/console)

2. **Accédez à votre application**
   - Sélectionnez "FreeAgent" dans la liste des applications

3. **Allez dans "Politique de l'app"**
   - Menu de gauche > "Politique de l'app"

4. **Cliquez sur "Déclaration d'accès à l'app"**
   - Section "Accès à l'app"

5. **Remplissez le formulaire**

   **Question : "Votre application nécessite-t-elle des identifiants de connexion ?"**
   - ✅ **Oui**

   **Type d'accès :**
   - Sélectionnez "Identifiants de connexion" ou "Compte de test"

   **Informations à fournir :**

   ```
   📧 Email: playstore.test@freeagent.app
   🔑 Mot de passe: GooglePlay2024!Test
   ```

   **Instructions supplémentaires (optionnel) :**
   ```
   Ce compte de test a été créé spécialement pour l'examen Google Play.
   Il a accès à toutes les fonctionnalités de l'application :
   - Création et consultation de profils
   - Messagerie
   - Annonces et opportunités
   - Toutes les fonctionnalités premium
   ```

6. **Sauvegardez les modifications**
   - Cliquez sur "Enregistrer"

### Étape 3 : Vérifier que le problème est résolu

1. Retournez dans "Politique de l'app"
2. Vérifiez que la section "Déclaration d'accès à l'app" est complétée
3. Le problème "Identifiants de connexion manquants" devrait disparaître

---

## Informations du compte de test

### Identifiants de connexion
```
Email: playstore.test@freeagent.app
Mot de passe: GooglePlay2024!Test
```

### Caractéristiques du compte
- ✅ **Type de profil** : Joueur
- ✅ **Statut** : Premium (accès complet)
- ✅ **Accès** : Toutes les fonctionnalités
- ✅ **Créé spécialement** : Pour l'examen Google Play

---

## Alternative : Créer le compte manuellement

Si le script ne fonctionne pas, créez le compte via l'application :

1. **Ouvrez l'application FreeAgent**
2. **Allez sur la page d'inscription**
3. **Remplissez le formulaire avec :**
   - Nom : `Google Play Test Account`
   - Email : `playstore.test@freeagent.app`
   - Mot de passe : `GooglePlay2024!Test`
   - Type de profil : `Joueur`
4. **Validez l'inscription**

---

## Notes importantes

⚠️ **Sécurité :**
- Ce compte est uniquement pour l'examen Google Play
- Ne supprimez pas ce compte tant que l'application est sur le Play Store
- Vous pouvez changer le mot de passe si nécessaire

✅ **Bonnes pratiques :**
- Gardez ce compte actif
- Vérifiez régulièrement qu'il fonctionne
- Si vous changez le mot de passe, mettez à jour Google Play Console

---

## Dépannage

### Le compte n'existe pas
- Exécutez le script de création
- Ou créez-le manuellement via l'application

### Le compte existe mais ne fonctionne pas
- Vérifiez que l'email est correct : `playstore.test@freeagent.app`
- Vérifiez que le mot de passe est correct : `GooglePlay2024!Test`
- Essayez de vous connecter via l'application pour tester

### Google Play Console ne trouve toujours pas les identifiants
- Vérifiez que vous avez bien enregistré les modifications
- Attendez quelques minutes pour que les changements soient pris en compte
- Vérifiez que vous avez rempli tous les champs requis

---

## Support

Si vous rencontrez des problèmes :
1. Vérifiez que le compte de test existe dans la base de données
2. Testez la connexion avec ces identifiants dans l'application
3. Vérifiez que les identifiants sont correctement enregistrés dans Google Play Console




