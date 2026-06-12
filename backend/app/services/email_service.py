import smtplib
from email.message import EmailMessage

from app.core.config import settings


def send_reset_code_email(
    to_email: str,
    code: str,
):
    message = EmailMessage()

    message["Subject"] = "VOXA Password Reset Code"
    message["From"] = settings.smtp_from_email
    message["To"] = to_email

    message.set_content(
        f"""
Hello,

Your VOXA password reset code is:

{code}

This code will expire in 10 minutes.

If you did not request this, please ignore this email.

VOXA Team
"""
    )

    with smtplib.SMTP(
        settings.smtp_host,
        settings.smtp_port,
    ) as smtp:
        smtp.starttls()
        smtp.login(
            settings.smtp_username,
            settings.smtp_password,
        )
        smtp.send_message(message)