const { onCall } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const nodemailer = require("nodemailer");
require("dotenv").config();

/* -------------------------------------------------------
   TRANSPORTER SMTP (OVH)
------------------------------------------------------- */

function createTransporter() {
  const emailUser = process.env.EMAIL_USER;
  const emailPassword = process.env.EMAIL_PASSWORD;

  if (!emailUser || !emailPassword) {
    throw new Error("Variables EMAIL_USER / EMAIL_PASSWORD manquantes");
  }

  if (!emailUser.includes("@terreenvie.com")) {
    throw new Error("Seules les adresses @terreenvie.com sont supportées");
  }

  return nodemailer.createTransport({
    host: "ssl0.ovh.net",
    port: 465,
    secure: true,
    auth: {
      user: emailUser,
      pass: emailPassword,
    },
  });
}

/* -------------------------------------------------------
   1) ENVOI SIMPLE
------------------------------------------------------- */

exports.sendEmail = onCall(async (request) => {
  const auth = request.auth;
  const data = request.data;

  if (!auth) {
    logger.error("❌ sendEmail → utilisateur non authentifié");
    throw new Error("unauthenticated");
  }

  const { to, subject, body } = data;

  if (!to || !subject || !body) {
    throw new Error("invalid-argument");
  }

  try {
    const transporter = createTransporter();
    const emailUser = process.env.EMAIL_USER;

    const result = await transporter.sendMail({
      from: emailUser,
      to,
      subject,
      text: body,
    });

    logger.info("✅ Email envoyé", { to, messageId: result.messageId });

    return {
      success: true,
      messageId: result.messageId,
    };
  } catch (error) {
    logger.error("❌ Erreur sendEmail", error);
    throw new Error("internal");
  }
});

/* -------------------------------------------------------
   2) ENVOI EN MASSE
------------------------------------------------------- */

exports.sendBulkEmails = onCall(async (request) => {
  const auth = request.auth;
  const data = request.data;

  logger.info("📧 sendBulkEmails appelé", {
    hasAuth: !!auth,
    authUid: auth?.uid,
    emailsCount: data?.emails?.length || 0,
  });

  if (!auth) {
    logger.error("❌ sendBulkEmails → utilisateur non authentifié");
    throw new Error("unauthenticated");
  }

  const { emails, subject, body } = data;

  if (!emails || !Array.isArray(emails) || !subject || !body) {
    logger.error("❌ Paramètres invalides", {
      emails,
      subject,
      body,
    });
    throw new Error("invalid-argument");
  }

  try {
    const transporter = createTransporter();
    const emailUser = process.env.EMAIL_USER;

    const results = [];

    for (let i = 0; i < emails.length; i++) {
      const email = emails[i];
      try {
        logger.info(`📧 Envoi ${i + 1}/${emails.length} → ${email}`);
        await transporter.sendMail({
          from: emailUser,
          to: email,
          subject,
          text: body,
        });
        results.push({ email, success: true });
      } catch (error) {
        logger.error(`❌ Erreur pour ${email}`, error);
        results.push({ email, success: false, error: error.message });
      }
    }

    logger.info("✅ sendBulkEmails terminé", {
      total: emails.length,
      success: results.filter((r) => r.success).length,
      failed: results.filter((r) => !r.success).length,
    });

    return { success: true, results };
  } catch (error) {
    logger.error("❌ Erreur globale sendBulkEmails", error);
    throw new Error("internal");
  }
});

/* -------------------------------------------------------
   3) ENVOI PERSONNALISÉ
------------------------------------------------------- */

exports.sendPersonalizedEmails = onCall(async (request) => {
  const auth = request.auth;
  const data = request.data;

  if (!auth) {
    logger.error("❌ sendPersonalizedEmails → utilisateur non authentifié");
    throw new Error("unauthenticated");
  }

  const { users, subject, bodyTemplate, creneauData } = data;

  if (!users || !Array.isArray(users) || !subject || !bodyTemplate) {
    throw new Error("invalid-argument");
  }

  try {
    const transporter = createTransporter();
    const emailUser = process.env.EMAIL_USER;

    const results = [];

    for (const user of users) {
      try {
        let personalizedBody = bodyTemplate;

        if (user.prenom)
          personalizedBody = personalizedBody.replace(/{prenom}/g, user.prenom);
        if (user.nom)
          personalizedBody = personalizedBody.replace(/{nom}/g, user.nom);
        if (user.profil)
          personalizedBody = personalizedBody.replace(/{profil}/g, user.profil);

        if (creneauData) {
          if (creneauData.jour)
            personalizedBody = personalizedBody.replace(
              /{jour}/g,
              creneauData.jour
            );
          if (creneauData.poste)
            personalizedBody = personalizedBody.replace(
              /{poste}/g,
              creneauData.poste
            );
          if (creneauData.horaire)
            personalizedBody = personalizedBody.replace(
              /{horaire}/g,
              creneauData.horaire
            );
        }

        await transporter.sendMail({
          from: emailUser,
          to: user.email,
          subject,
          text: personalizedBody,
        });

        results.push({ email: user.email, success: true });
      } catch (error) {
        logger.error(`❌ Erreur pour ${user.email}`, error);
        results.push({
          email: user.email,
          success: false,
          error: error.message,
        });
      }
    }

    return { success: true, results };
  } catch (error) {
    logger.error("❌ Erreur sendPersonalizedEmails", error);
    throw new Error("internal");
  }
});
