const { onCall, HttpsError } = require("firebase-functions/v2/https");
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
   HTML Body
------------------------------------------------------- */
function buildHtmlBody({ body, attachment }) {
  let html = `
<table width="100%" cellpadding="0" cellspacing="0"
  style="font-family:Arial,sans-serif;font-size:14px;line-height:1.6;">
  <tr>
    <td>
      <p>${body.replace(/\n/g, "<br>")}</p>
    </td>
  </tr>
`;

  if (attachment) {
    const isImage = attachment.mime?.startsWith("image/");

    html += `
      <tr>
        <td style="padding-top:24px;">
          <hr style="border:none;border-top:1px solid #ddd;" />
          <p><strong>Pièce jointe :</strong></p>
          ${
            isImage
              ? `
                <div style="margin-top:8px;">
                  <img
                    src="cid:attachment1"
                    alt="${attachment.filename}"
                    style="display:block;max-width:100%;border:1px solid #ddd;"
                  />
                </div>
              `
              : `
                <p style="margin-top:8px;">
                  📎 <a href="cid:attachment1">${attachment.filename}</a>
                </p>
              `
          }
        </td>
      </tr>
    `;
  }

  html += `</table>`;
  return html;
}

/* -------------------------------------------------------
   UTILITAIRES
------------------------------------------------------- */
function buildAttachments(attachment) {
  if (!attachment || !attachment.content || !attachment.filename) return [];

  return [
    {
      filename: attachment.filename,
      content: Buffer.from(attachment.content, "base64"),
      contentType: attachment.mime || "application/octet-stream",
      cid: "attachment1", 
    },
  ];
}

/* -------------------------------------------------------
   1) ENVOI SIMPLE
------------------------------------------------------- */
exports.sendEmail = onCall(async (request) => {
  const { auth, data } = request;
  if (!auth)
    throw new HttpsError("unauthenticated", "Utilisateur non authentifié");

  const { to, subject, body, attachment } = data;
  if (!to || !subject || !body)
    throw new HttpsError("invalid-argument", "to, subject et body requis");

  try {
    const transporter = createTransporter();
    const emailUser = process.env.EMAIL_USER;

    const result = await transporter.sendMail({
      from: emailUser,
      to,
      subject,
      html: buildHtmlBody({ body, attachment }),
      text: body, // fallback clients très anciens
      attachments: buildAttachments(attachment), // INLINE ATTACHMENTS

    });

    logger.info("✅ sendEmail → Email envoyé", {
      to,
      messageId: result.messageId,
    });
    return { success: true, messageId: result.messageId };
  } catch (error) {
    logger.error("❌ Erreur sendEmail", error);
    throw new HttpsError("internal", "Erreur lors de l’envoi de l’email");
  }
});

/* -------------------------------------------------------
   2) ENVOI EN MASSE
------------------------------------------------------- */
exports.sendBulkEmails = onCall(async (request) => {
  const { auth, data } = request;
  if (!auth)
    throw new HttpsError("unauthenticated", "Utilisateur non authentifié");

  const { emails, subject, body, attachment } = data;
  if (!emails || !Array.isArray(emails) || !subject || !body) {
    throw new HttpsError(
      "invalid-argument",
      "emails (array), subject et body requis"
    );
  }

  try {
    const transporter = createTransporter();
    const emailUser = process.env.EMAIL_USER;
    const attachments = buildAttachments(attachment);

    const results = [];

    for (let i = 0; i < emails.length; i++) {
      const email = emails[i];
      try {
        await transporter.sendMail({
          from: emailUser,
          to: email,
          subject,
          html: buildHtmlBody({ body, attachment }),
          text: body,
          attachments,
        });
        results.push({ email, success: true });
        logger.info(`✅ Email ${i + 1}/${emails.length} envoyé → ${email}`);
      } catch (err) {
        results.push({ email, success: false, error: err.message });
        logger.error(`❌ Erreur pour ${email}`, err);
      }
    }

    logger.info("📧 sendBulkEmails terminé", {
      total: emails.length,
      success: results.filter((r) => r.success).length,
      failed: results.filter((r) => !r.success).length,
    });

    return { success: true, results };
  } catch (error) {
    logger.error("❌ Erreur globale sendBulkEmails", error);
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", "Erreur lors de l’envoi des emails");
  }
});

/* -------------------------------------------------------
   3) ENVOI PERSONNALISÉ
------------------------------------------------------- */
exports.sendPersonalizedEmails = onCall(async (request) => {
  const { auth, data } = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "Utilisateur non authentifié");
  }

  const { users, subject, bodyTemplate, creneauData, attachment } = data;

  if (!users || !Array.isArray(users) || !subject || !bodyTemplate) {
    throw new HttpsError("invalid-argument", "Paramètres manquants");
  }

  try {
    const transporter = createTransporter();
    const emailUser = process.env.EMAIL_USER;
    const attachments = buildAttachments(attachment);

    const results = [];

    for (const user of users) {
      try {
        // 🔹 Personnalisation du texte
        let personalizedBody = bodyTemplate;
        let personalizedSubject = subject;

        if (user.prenom) {
          personalizedBody = personalizedBody.replace(/{prenom}/g, user.prenom);
          personalizedSubject = personalizedSubject.replace(
            /{prenom}/g,
            user.prenom
          );
        }
        if (user.nom) {
          personalizedBody = personalizedBody.replace(/{nom}/g, user.nom);
          personalizedSubject = personalizedSubject.replace(/{nom}/g, user.nom);
        }
        if (user.profil) {
          personalizedBody = personalizedBody.replace(/{profil}/g, user.profil);
          personalizedSubject = personalizedSubject.replace(
            /{profil}/g,
            user.profil
          );
        }
        if (user.creneauxText) {
          personalizedBody = personalizedBody.replace(
            /{creneaux}/g,
            user.creneauxText
          );
        }

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

        // 🔹 Construction du HTML
        const htmlBody = buildHtmlBody({
          body: personalizedBody,
          attachment,
        });


        await transporter.sendMail({
          from: emailUser,
          to: user.email,
          subject: personalizedSubject,
          html: htmlBody,
          text: personalizedBody,
          attachments,
        });

        results.push({ email: user.email, success: true });
        logger.info(`✅ Email personnalisé envoyé → ${user.email}`);
      } catch (err) {
        results.push({ email: user.email, success: false, error: err.message });
        logger.error(`❌ Erreur pour ${user.email}`, err);
      }
    }

    return { success: true, results };
  } catch (error) {
    logger.error("❌ Erreur sendPersonalizedEmails", error);
    if (error instanceof HttpsError) throw error;
    throw new HttpsError(
      "internal",
      "Erreur lors de l’envoi des emails personnalisés"
    );
  }
});
