const nodemailer = require('nodemailer');

function createTransporter(session) {
    const host = session.smtpHost || 'localhost';
    const port = parseInt(session.smtpPort) || 25;
    const secure = session.smtpSecure === true;

    const config = {
        host,
        port,
        secure,
        tls: {
            rejectUnauthorized: false
        }
    };

    // If auth is provided (not localhost relaying)
    if (session.smtpUser && session.smtpPass) {
        config.auth = {
            user: session.smtpUser,
            pass: session.smtpPass
        };
    }

    return nodemailer.createTransport(config);
}

async function sendMail(session, { to, subject, text, html, cc, bcc, attachments }) {
    const transport = createTransporter(session);
    const info = await transport.sendMail({
        from: session.userEmail || process.env.SMTP_USER || 'noreply@localhost',
        to,
        subject,
        text,
        html,
        cc,
        bcc,
        attachments
    });
    return info;
}

async function verifyConnection(session) {
    const transport = createTransporter(session);
    await transport.verify();
}

module.exports = { sendMail, verifyConnection };
