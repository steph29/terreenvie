const { onRequest } = require("firebase-functions/v2/https");
const nodemailer = require("nodemailer");
const cors = require("cors")({ origin: true });
require("dotenv").config();

// Configuration SMTP - Utilisation de variables d'environnement
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER || "communication.terreenvie@gmail.com",
    pass: process.env.EMAIL_PASSWORD || "dernierWE09",
  },
  // Ajouter des options pour améliorer la compatibilité
  secure: false,
  tls: {
    rejectUnauthorized: false,
  },
});

// Fonction pour envoyer un email simple
exports.sendemail = onRequest((request, response) => {
  cors(request, response, async () => {
    try {
      console.log("📧 Début de l'envoi d'email");
      console.log("📧 Email configuré:", process.env.EMAIL_USER || "communication.terreenvie@gmail.com");
      console.log("📧 Mot de passe configuré:", process.env.EMAIL_PASSWORD ? "✅ Présent" : "❌ Absent");
      
      const { to, subject, body } = request.body;

      console.log("📧 Données reçues:", { to, subject, body });

      const mailOptions = {
        from: process.env.EMAIL_USER || "communication.terreenvie@gmail.com",
        to: to,
        subject: subject,
        text: body,
      };

      console.log("📧 Options d'email:", mailOptions);

      const result = await transporter.sendMail(mailOptions);
      console.log("✅ Email envoyé avec succès:", result);

      response
        .status(200)
        .json({ success: true, message: "Email envoyé avec succès" });
    } catch (error) {
      console.error("❌ Erreur lors de l'envoi d'email:", error);

      // Message d'erreur plus détaillé
      let errorMessage = error.message;
      if (error.message.includes("Application-specific password required")) {
        errorMessage =
          "Configuration Gmail incorrecte. Un mot de passe d'application est requis.";
      } else if (error.message.includes("Username and Password not accepted")) {
        errorMessage =
          "Email ou mot de passe d'application incorrect. Vérifiez les identifiants Gmail.";
      }

      response.status(500).json({
        success: false,
        error: errorMessage,
        details: "Vérifiez la configuration SMTP dans les Firebase Functions",
      });
    }
  });
});

// Fonction pour envoyer des emails en masse
exports.sendbulkemails = onRequest((request, response) => {
  cors(request, response, async () => {
    try {
      const { emails, subject, body } = request.body;

      const results = [];

      for (const email of emails) {
        try {
          const mailOptions = {
            from: process.env.EMAIL_USER || "communication.terreenvie@gmail.com",
            to: email,
            subject: subject,
            text: body,
          };

          await transporter.sendMail(mailOptions);
          results.push({ email, success: true });
        } catch (error) {
          results.push({ email, success: false, error: error.message });
        }
      }

      response.status(200).json({ success: true, results });
    } catch (error) {
      console.error("Erreur lors de l'envoi d'emails en masse:", error);
      response.status(500).json({ success: false, error: error.message });
    }
  });
});

// Fonction pour envoyer des emails personnalisés
exports.sendpersonalizedemails = onRequest((request, response) => {
  cors(request, response, async () => {
    try {
      const { users, subject, bodyTemplate, creneauData } = request.body;

      const results = [];

      for (const user of users) {
        try {
          // Personnaliser le contenu pour chaque utilisateur
          let personalizedBody = bodyTemplate;

          // Remplacer les variables dans le template
          if (user.prenom) {
            personalizedBody = personalizedBody.replace(
              /{prenom}/g,
              user.prenom
            );
          }
          if (user.nom) {
            personalizedBody = personalizedBody.replace(/{nom}/g, user.nom);
          }
          if (user.profil) {
            personalizedBody = personalizedBody.replace(
              /{profil}/g,
              user.profil
            );
          }

          // Ajouter les données de créneau si disponibles
          if (creneauData) {
            if (creneauData.jour) {
              personalizedBody = personalizedBody.replace(
                /{jour}/g,
                creneauData.jour
              );
            }
            if (creneauData.poste) {
              personalizedBody = personalizedBody.replace(
                /{poste}/g,
                creneauData.poste
              );
            }
            if (creneauData.horaire) {
              personalizedBody = personalizedBody.replace(
                /{horaire}/g,
                creneauData.horaire
              );
            }
          }

          const mailOptions = {
            from: process.env.EMAIL_USER || "communication.terreenvie@gmail.com",
            to: user.email,
            subject: subject,
            text: personalizedBody,
          };

          await transporter.sendMail(mailOptions);
          results.push({ email: user.email, success: true });
        } catch (error) {
          results.push({
            email: user.email,
            success: false,
            error: error.message,
          });
        }
      }

      response.status(200).json({ success: true, results });
    } catch (error) {
      console.error("Erreur lors de l'envoi d'emails personnalisés:", error);
      response.status(500).json({ success: false, error: error.message });
    }
  });
});
