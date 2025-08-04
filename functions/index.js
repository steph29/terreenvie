const { onRequest } = require("firebase-functions/v2/https");
const nodemailer = require("nodemailer");
const cors = require("cors")({ origin: true });

// Configuration SMTP - Utilisation d'une variable d'environnement directe
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "communication.terreenvie@gmail.com",
    pass: "dernierWE09", // Temporairement en dur pour le déploiement
  },
});

// Fonction pour envoyer un email simple
exports.sendemail = onRequest((request, response) => {
  cors(request, response, async () => {
    try {
      const { to, subject, body } = request.body;

      const mailOptions = {
        from: "communication.terreenvie@gmail.com",
        to: to,
        subject: subject,
        text: body,
      };

      await transporter.sendMail(mailOptions);

      response
        .status(200)
        .json({ success: true, message: "Email envoyé avec succès" });
    } catch (error) {
      console.error("Erreur lors de l'envoi d'email:", error);
      response.status(500).json({ success: false, error: error.message });
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
            from: "communication.terreenvie@gmail.com",
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
      const { emails, subject, bodyTemplate, variables } = request.body;

      const results = [];

      for (const email of emails) {
        try {
          // Personnaliser le contenu pour chaque email
          let personalizedBody = bodyTemplate;
          if (variables && variables[email]) {
            for (const [key, value] of Object.entries(variables[email])) {
              personalizedBody = personalizedBody.replace(
                new RegExp(`{{${key}}}`, "g"),
                value
              );
            }
          }

          const mailOptions = {
            from: "communication.terreenvie@gmail.com",
            to: email,
            subject: subject,
            text: personalizedBody,
          };

          await transporter.sendMail(mailOptions);
          results.push({ email, success: true });
        } catch (error) {
          results.push({ email, success: false, error: error.message });
        }
      }

      response.status(200).json({ success: true, results });
    } catch (error) {
      console.error("Erreur lors de l'envoi d'emails personnalisés:", error);
      response.status(500).json({ success: false, error: error.message });
    }
  });
});
