const functions = require("firebase-functions");
const nodemailer = require("nodemailer");
const cors = require("cors")({ origin: true });

// Configuration SMTP pour Gmail
const transporter = nodemailer.createTransporter({
  service: "gmail",
  auth: {
    user:
      functions.config().email?.user || "communication.terreenvie@gmail.com",
    pass: functions.config().email?.password || "dernierWE09",
  },
});

// Fonction pour envoyer un email simple
exports.sendEmail = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      // Vérifier la méthode HTTP
      if (req.method !== "POST") {
        return res.status(405).json({ error: "Méthode non autorisée" });
      }

      const { to, subject, body, fromName } = req.body;

      // Validation des paramètres
      if (!to || !subject || !body) {
        return res.status(400).json({
          error: "Paramètres manquants: to, subject, body sont requis",
        });
      }

      // Configuration de l'email
      const mailOptions = {
        from: `"${fromName || "Terre en Vie"}" <${
          functions.config().email?.user || "communication.terreenvie@gmail.com"
        }>`,
        to: to,
        subject: subject,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background-color: #4CAF50; color: white; padding: 20px; text-align: center;">
              <h1 style="margin: 0;">Terre en Vie</h1>
            </div>
            <div style="padding: 20px; background-color: #f9f9f9;">
              ${body}
            </div>
            <div style="background-color: #333; color: white; padding: 15px; text-align: center; font-size: 12px;">
              © 2024 Terre en Vie - Tous droits réservés
            </div>
          </div>
        `,
      };

      // Envoi de l'email
      const info = await transporter.sendMail(mailOptions);

      console.log("Email envoyé avec succès:", info.messageId);

      return res.status(200).json({
        success: true,
        messageId: info.messageId,
        message: "Email envoyé avec succès",
      });
    } catch (error) {
      console.error("Erreur lors de l'envoi de l'email:", error);
      return res.status(500).json({
        error: "Erreur lors de l'envoi de l'email",
        details: error.message,
      });
    }
  });
});

// Fonction pour envoyer des emails en lot
exports.sendBulkEmails = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      // Vérifier la méthode HTTP
      if (req.method !== "POST") {
        return res.status(405).json({ error: "Méthode non autorisée" });
      }

      const { recipients, subject, body, fromName } = req.body;

      // Validation des paramètres
      if (
        !recipients ||
        !Array.isArray(recipients) ||
        recipients.length === 0
      ) {
        return res.status(400).json({
          error:
            "Paramètres manquants: recipients doit être un tableau non vide",
        });
      }

      if (!subject || !body) {
        return res.status(400).json({
          error: "Paramètres manquants: subject et body sont requis",
        });
      }

      const results = {};
      const emailPromises = recipients.map(async (recipient) => {
        try {
          const mailOptions = {
            from: `"${fromName || "Terre en Vie"}" <${
              functions.config().email?.user ||
              "communication.terreenvie@gmail.com"
            }>`,
            to: recipient,
            subject: subject,
            html: `
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #4CAF50; color: white; padding: 20px; text-align: center;">
                  <h1 style="margin: 0;">Terre en Vie</h1>
                </div>
                <div style="padding: 20px; background-color: #f9f9f9;">
                  ${body}
                </div>
                <div style="background-color: #333; color: white; padding: 15px; text-align: center; font-size: 12px;">
                  © 2024 Terre en Vie - Tous droits réservés
                </div>
              </div>
            `,
          };

          const info = await transporter.sendMail(mailOptions);
          results[recipient] = { success: true, messageId: info.messageId };
          console.log(
            `Email envoyé avec succès à ${recipient}:`,
            info.messageId
          );
        } catch (error) {
          console.error(`Erreur lors de l'envoi à ${recipient}:`, error);
          results[recipient] = { success: false, error: error.message };
        }
      });

      await Promise.all(emailPromises);

      const successCount = Object.values(results).filter(
        (r) => r.success
      ).length;
      const failureCount = recipients.length - successCount;

      return res.status(200).json({
        success: true,
        results: results,
        summary: {
          total: recipients.length,
          success: successCount,
          failure: failureCount,
        },
        message: `${successCount} emails envoyés avec succès, ${failureCount} échecs`,
      });
    } catch (error) {
      console.error("Erreur lors de l'envoi des emails en lot:", error);
      return res.status(500).json({
        error: "Erreur lors de l'envoi des emails en lot",
        details: error.message,
      });
    }
  });
});

// Fonction pour envoyer des emails personnalisés
exports.sendPersonalizedEmails = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      // Vérifier la méthode HTTP
      if (req.method !== "POST") {
        return res.status(405).json({ error: "Méthode non autorisée" });
      }

      const { emails, subject, bodyTemplate, fromName } = req.body;

      // Validation des paramètres
      if (!emails || !Array.isArray(emails) || emails.length === 0) {
        return res.status(400).json({
          error: "Paramètres manquants: emails doit être un tableau non vide",
        });
      }

      if (!subject || !bodyTemplate) {
        return res.status(400).json({
          error: "Paramètres manquants: subject et bodyTemplate sont requis",
        });
      }

      const results = {};
      const emailPromises = emails.map(async (emailData) => {
        const { email, variables } = emailData;

        try {
          // Remplacer les variables dans le template
          let personalizedBody = bodyTemplate;
          if (variables) {
            Object.keys(variables).forEach((key) => {
              const regex = new RegExp(`{{${key}}}`, "g");
              personalizedBody = personalizedBody.replace(
                regex,
                variables[key] || ""
              );
            });
          }

          const mailOptions = {
            from: `"${fromName || "Terre en Vie"}" <${
              functions.config().email?.user ||
              "communication.terreenvie@gmail.com"
            }>`,
            to: email,
            subject: subject,
            html: `
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #4CAF50; color: white; padding: 20px; text-align: center;">
                  <h1 style="margin: 0;">Terre en Vie</h1>
                </div>
                <div style="padding: 20px; background-color: #f9f9f9;">
                  ${personalizedBody}
                </div>
                <div style="background-color: #333; color: white; padding: 15px; text-align: center; font-size: 12px;">
                  © 2024 Terre en Vie - Tous droits réservés
                </div>
              </div>
            `,
          };

          const info = await transporter.sendMail(mailOptions);
          results[email] = { success: true, messageId: info.messageId };
          console.log(
            `Email personnalisé envoyé avec succès à ${email}:`,
            info.messageId
          );
        } catch (error) {
          console.error(
            `Erreur lors de l'envoi personnalisé à ${email}:`,
            error
          );
          results[email] = { success: false, error: error.message };
        }
      });

      await Promise.all(emailPromises);

      const successCount = Object.values(results).filter(
        (r) => r.success
      ).length;
      const failureCount = emails.length - successCount;

      return res.status(200).json({
        success: true,
        results: results,
        summary: {
          total: emails.length,
          success: successCount,
          failure: failureCount,
        },
        message: `${successCount} emails personnalisés envoyés avec succès, ${failureCount} échecs`,
      });
    } catch (error) {
      console.error("Erreur lors de l'envoi des emails personnalisés:", error);
      return res.status(500).json({
        error: "Erreur lors de l'envoi des emails personnalisés",
        details: error.message,
      });
    }
  });
});
