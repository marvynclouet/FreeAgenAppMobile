const nodemailer = require('nodemailer');

// Configuration du transporteur email
const createTransporter = () => {
  // Si SMTP est configuré, utiliser SMTP
  if (process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASSWORD) {
    return nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT || 587,
      secure: process.env.SMTP_SECURE === 'true', // true pour 465, false pour autres ports
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD,
      },
    });
  }

  // Sinon, utiliser Gmail avec OAuth2 ou App Password
  if (process.env.GMAIL_USER && process.env.GMAIL_APP_PASSWORD) {
    return nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_APP_PASSWORD, // Mot de passe d'application Gmail
      },
    });
  }

  // Mode développement : transporter de test (ne pas envoyer d'emails réels)
  if (process.env.NODE_ENV === 'development') {
    console.log('⚠️  Mode développement : emails ne seront pas envoyés (transporter de test)');
    return nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      auth: {
        user: 'test@ethereal.email',
        pass: 'test',
      },
    });
  }

  throw new Error('Configuration email manquante. Configurez SMTP ou Gmail dans les variables d\'environnement.');
};

// Template HTML pour l'email de réinitialisation
const getPasswordResetEmailTemplate = (resetLink, userName = 'Utilisateur') => {
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .container {
      background-color: #f9f9f9;
      border-radius: 10px;
      padding: 30px;
      border: 1px solid #ddd;
    }
    .header {
      text-align: center;
      margin-bottom: 30px;
    }
    .logo {
      font-size: 24px;
      font-weight: bold;
      color: #9B5CFF;
      margin-bottom: 10px;
    }
    .content {
      background-color: white;
      padding: 25px;
      border-radius: 8px;
      margin-bottom: 20px;
    }
    .button {
      display: inline-block;
      padding: 12px 30px;
      background-color: #9B5CFF;
      color: white;
      text-decoration: none;
      border-radius: 5px;
      margin: 20px 0;
      font-weight: bold;
    }
    .button:hover {
      background-color: #7B4CDB;
    }
    .footer {
      text-align: center;
      color: #666;
      font-size: 12px;
      margin-top: 20px;
    }
    .warning {
      background-color: #fff3cd;
      border-left: 4px solid #ffc107;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="logo">FreeAgent</div>
      <h2>Réinitialisation de votre mot de passe</h2>
    </div>
    
    <div class="content">
      <p>Bonjour ${userName},</p>
      
      <p>Vous avez demandé à réinitialiser votre mot de passe pour votre compte FreeAgent.</p>
      
      <p>Cliquez sur le bouton ci-dessous pour créer un nouveau mot de passe :</p>
      
      <div style="text-align: center;">
        <a href="${resetLink}" class="button">Réinitialiser mon mot de passe</a>
      </div>
      
      <p>Ou copiez-collez ce lien dans votre navigateur :</p>
      <p style="word-break: break-all; color: #9B5CFF;">${resetLink}</p>
      
      <div class="warning">
        <strong>⚠️ Important :</strong>
        <ul style="margin: 10px 0; padding-left: 20px;">
          <li>Ce lien est valide pendant <strong>1 heure</strong> uniquement</li>
          <li>Si vous n'avez pas demandé cette réinitialisation, ignorez cet email</li>
          <li>Ne partagez jamais ce lien avec quelqu'un d'autre</li>
        </ul>
      </div>
      
      <p>Si vous n'avez pas demandé cette réinitialisation, vous pouvez ignorer cet email en toute sécurité.</p>
    </div>
    
    <div class="footer">
      <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
      <p>&copy; ${new Date().getFullYear()} FreeAgent. Tous droits réservés.</p>
    </div>
  </div>
</body>
</html>
  `;
};

// Envoyer un email de réinitialisation de mot de passe
const sendPasswordResetEmail = async (email, resetToken, userName = null) => {
  try {
    const transporter = createTransporter();
    
    // URL de réinitialisation (à adapter selon votre frontend)
    const resetLink = process.env.FRONTEND_URL 
      ? `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`
      : `https://free-agen-app.vercel.app/reset-password?token=${resetToken}`;

    const mailOptions = {
      from: process.env.EMAIL_FROM || process.env.SMTP_USER || process.env.GMAIL_USER || 'noreply@freeagent.app',
      to: email,
      subject: 'Réinitialisation de votre mot de passe - FreeAgent',
      html: getPasswordResetEmailTemplate(resetLink, userName),
      text: `Bonjour ${userName || 'Utilisateur'},

Vous avez demandé à réinitialiser votre mot de passe pour votre compte FreeAgent.

Cliquez sur ce lien pour créer un nouveau mot de passe :
${resetLink}

Ce lien est valide pendant 1 heure uniquement.

Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.

Cet email a été envoyé automatiquement, merci de ne pas y répondre.
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    
    // En mode développement avec Ethereal, afficher l'URL de prévisualisation
    if (process.env.NODE_ENV === 'development' && info.messageId) {
      console.log('📧 Email de test envoyé. Prévisualisation:', nodemailer.getTestMessageUrl(info));
    }
    
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email:', error);
    throw error;
  }
};

module.exports = {
  sendPasswordResetEmail,
  createTransporter,
};

