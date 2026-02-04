package com.covoiturage.service;

import java.util.Properties;

import javax.servlet.ServletContext;

public class EmailService {
    
    /**
     * Méthode générique pour envoyer un email
     */
	public static boolean sendEmail(ServletContext context, 
            String toEmail, 
            String subject, 
            String content) {

System.out.println("=== EMAIL SERVICE - TENTATIVE ENVOI ===");
System.out.println("To: " + toEmail);
System.out.println("Subject: " + subject);
System.out.println("Context: " + (context != null ? "OK" : "NULL"));

try {
// 1. Récupérer la configuration
String host = context.getInitParameter("mail.smtp.host");
String port = context.getInitParameter("mail.smtp.port");
String username = context.getInitParameter("mail.username");
String password = context.getInitParameter("mail.password");
String fromEmail = context.getInitParameter("mail.from");

System.out.println("Configuration:");
System.out.println("  Host: " + host);
System.out.println("  Port: " + port);
System.out.println("  Username: " + username);
System.out.println("  Password: " + (password != null && !password.isEmpty() ? "SET" : "NOT SET"));
System.out.println("  From: " + fromEmail);

// 2. Vérifier la configuration
if (username == null || username.isEmpty()) {
System.err.println("❌ ERREUR: mail.username non configuré dans web.xml");
return false;
}

if (password == null || password.isEmpty()) {
System.err.println("❌ ERREUR: mail.password non configuré dans web.xml");
return false;
}

// 3. Configuration par défaut si nécessaire
if (host == null) host = "smtp.gmail.com";
if (port == null) port = "587";
if (fromEmail == null) fromEmail = username;

// 4. Propriétés SMTP
java.util.Properties props = new java.util.Properties();
props.put("mail.smtp.host", host);
props.put("mail.smtp.port", port);
props.put("mail.smtp.auth", "true");
props.put("mail.smtp.starttls.enable", "true");
props.put("mail.smtp.ssl.trust", host);
props.put("mail.debug", "true"); // DEBUG activé

System.out.println("🔄 Création de la session SMTP...");

// 5. Authentification
javax.mail.Authenticator auth = new javax.mail.Authenticator() {
@Override
protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
System.out.println("🔐 Authentification avec: " + username);
return new javax.mail.PasswordAuthentication(username, password);
}
};

// 6. Session
javax.mail.Session session = javax.mail.Session.getInstance(props, auth);

// 7. Message
System.out.println("📧 Création du message...");
javax.mail.Message message = new javax.mail.internet.MimeMessage(session);
message.setFrom(new javax.mail.internet.InternetAddress(fromEmail));
message.setRecipients(javax.mail.Message.RecipientType.TO, 
javax.mail.internet.InternetAddress.parse(toEmail));
message.setSubject(subject);
message.setContent(content, "text/html; charset=UTF-8");

// 8. Envoi
System.out.println("🚀 Envoi de l'email...");
javax.mail.Transport.send(message);

System.out.println("✅ Email envoyé avec succès à: " + toEmail);
return true;

} catch (javax.mail.AuthenticationFailedException e) {
System.err.println("❌ ERREUR AUTHENTIFICATION GMAIL:");
System.err.println("  Email: " + context.getInitParameter("mail.username"));
System.err.println("  Vérifiez:");
System.err.println("  1. Le mot de passe d'application est correct");
System.err.println("  2. L'authentification à 2 facteurs est désactivée");
System.err.println("  3. L'accès aux apps moins sécurisées est activé");
e.printStackTrace();
return false;

} catch (javax.mail.MessagingException e) {
System.err.println("❌ ERREUR MESSAGING: " + e.getMessage());
e.printStackTrace();
return false;

} catch (Exception e) {
System.err.println("❌ ERREUR GÉNÉRALE: " + e.getMessage());
e.printStackTrace();
return false;
}
}
    
    /**
     * Notification pour nouvelle réservation (conducteur)
     */
    public static void sendReservationNotification(ServletContext context,
                                                  String toEmail,
                                                  String conducteurNom,
                                                  String trajetDetails,
                                                  String dateDepart,
                                                  String prix) {
        
        String subject = "Nouvelle réservation sur votre trajet - Covoiturage";
        String content = "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<style>"
                + "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }"
                + ".container { max-width: 600px; margin: 0 auto; padding: 20px; }"
                + ".header { background: #4a6cf7; color: white; padding: 20px; border-radius: 8px 8px 0 0; }"
                + ".content { background: #f9f9f9; padding: 20px; border: 1px solid #ddd; }"
                + ".footer { background: #f5f7fa; padding: 15px; text-align: center; color: #666; font-size: 12px; }"
                + ".btn { display: inline-block; background: #4a6cf7; color: white; padding: 12px 25px; "
                + "text-decoration: none; border-radius: 6px; margin: 10px 0; }"
                + "</style>"
                + "</head>"
                + "<body>"
                + "<div class='container'>"
                + "<div class='header'>"
                + "<h1>Nouvelle réservation reçue !</h1>"
                + "</div>"
                + "<div class='content'>"
                + "<p>Bonjour " + conducteurNom + ",</p>"
                + "<p>Vous avez une nouvelle réservation pour votre trajet :</p>"
                + "<div style='background: white; padding: 15px; border-radius: 6px; margin: 15px 0; border-left: 4px solid #4a6cf7;'>"
                + "<p><strong>Trajet :</strong> " + trajetDetails + "</p>"
                + "<p><strong>Date de départ :</strong> " + dateDepart + "</p>"
                + "<p><strong>Prix :</strong> " + prix + " DT</p>"
                + "</div>"
                + "<p>Connectez-vous à votre compte pour voir les détails du passager.</p>"
                + "<a href='http://localhost:8080/covoiturageApp/dashboard' class='btn'>"
                + "Accéder à mon compte"
                + "</a>"
                + "</div>"
                + "<div class='footer'>"
                + "<p>Cordialement,<br>L'équipe Covoiturage App</p>"
                + "<p style='font-size: 11px;'>Ceci est un email automatique, merci de ne pas y répondre.</p>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";
        
        sendEmail(context, toEmail, subject, content);
    }
    
    /**
     * Confirmation de réservation (passager)
     */
    public static void sendReservationConfirmation(ServletContext context,
                                                  String toEmail,
                                                  String passagerNom,
                                                  String trajetDetails,
                                                  String dateDepart,
                                                  String prix,
                                                  String conducteurNom,
                                                  String conducteurTel) {
        
        String subject = "Confirmation de votre réservation - Covoiturage";
        String content = "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<style>"
                + "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }"
                + ".container { max-width: 600px; margin: 0 auto; padding: 20px; }"
                + ".header { background: #48bb78; color: white; padding: 20px; border-radius: 8px 8px 0 0; }"
                + ".content { background: #f9f9f9; padding: 20px; border: 1px solid #ddd; }"
                + ".footer { background: #f5f7fa; padding: 15px; text-align: center; color: #666; font-size: 12px; }"
                + ".btn { display: inline-block; background: #4a6cf7; color: white; padding: 12px 25px; "
                + "text-decoration: none; border-radius: 6px; margin: 10px 0; }"
                + ".info-box { background: white; padding: 15px; border-radius: 6px; margin: 15px 0; "
                + "border: 1px solid #e2e8f0; }"
                + "</style>"
                + "</head>"
                + "<body>"
                + "<div class='container'>"
                + "<div class='header'>"
                + "<h1>Votre réservation est confirmée !</h1>"
                + "</div>"
                + "<div class='content'>"
                + "<p>Bonjour " + passagerNom + ",</p>"
                + "<p>Votre réservation a été confirmée avec succès. Voici les détails :</p>"
                + "<div class='info-box'>"
                + "<p><strong>Trajet :</strong> " + trajetDetails + "</p>"
                + "<p><strong>Date de départ :</strong> " + dateDepart + "</p>"
                + "<p><strong>Prix :</strong> " + prix + " DT</p>"
                + "<p><strong>Conducteur :</strong> " + conducteurNom + "</p>"
                + "<p><strong>Téléphone conducteur :</strong> " + conducteurTel + "</p>"
                + "</div>"
                + "<h3>Instructions importantes :</h3>"
                + "<ul>"
                + "<li>Présentez-vous au point de rendez-vous 15 minutes avant le départ</li>"
                + "<li>Ayez le montant exact pour le paiement</li>"
                + "<li>Contactez le conducteur en cas de retard ou d'annulation</li>"
                + "</ul>"
                + "<a href='http://localhost:8080/covoiturageApp/reservations' class='btn'>"
                + "Voir mes réservations"
                + "</a>"
                + "</div>"
                + "<div class='footer'>"
                + "<p>Bon voyage !<br>L'équipe Covoiturage App</p>"
                + "<p style='font-size: 11px;'>Ceci est un email automatique, merci de ne pas y répondre.</p>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";
        
        sendEmail(context, toEmail, subject, content);
    }
    
    /**
     * Notification d'annulation de trajet
     */
    public static void sendCancellationNotification(ServletContext context,
                                                   String toEmail,
                                                   String nom,
                                                   String trajetDetails,
                                                   String raison) {
        
        String subject = "Trajet annulé - Covoiturage";
        String content = "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<style>"
                + "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }"
                + ".container { max-width: 600px; margin: 0 auto; padding: 20px; }"
                + ".header { background: #f56565; color: white; padding: 20px; border-radius: 8px 8px 0 0; }"
                + ".content { background: #f9f9f9; padding: 20px; border: 1px solid #ddd; }"
                + ".btn { display: inline-block; background: #4a6cf7; color: white; padding: 12px 25px; "
                + "text-decoration: none; border-radius: 6px; margin: 10px 0; }"
                + "</style>"
                + "</head>"
                + "<body>"
                + "<div class='container'>"
                + "<div class='header'>"
                + "<h1>Trajet annulé</h1>"
                + "</div>"
                + "<div class='content'>"
                + "<p>Bonjour " + nom + ",</p>"
                + "<p>Nous vous informons que le trajet suivant a été annulé :</p>"
                + "<div style='background: white; padding: 15px; border-radius: 6px; margin: 15px 0; "
                + "border-left: 4px solid #f56565;'>"
                + "<p><strong>Trajet :</strong> " + trajetDetails + "</p>"
                + "<p><strong>Raison :</strong> " + raison + "</p>"
                + "</div>"
                + "<p>Votre réservation a été automatiquement annulée.</p>"
                + "<a href='http://localhost:8080/covoiturageApp/dashboard' class='btn'>"
                + "Chercher un autre trajet"
                + "</a>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";
        
        sendEmail(context, toEmail, subject, content);
    }
    
    /**
     * Notification d'inscription
     */
    public static void sendWelcomeEmail(ServletContext context,
                                       String toEmail,
                                       String nom) {
        
        String subject = "Bienvenue sur Covoiturage App !";
        String content = "<!DOCTYPE html>"
                + "<html>"
                + "<body style='font-family: Arial, sans-serif;'>"
                + "<h2 style='color: #4a6cf7;'>Bienvenue " + nom + " !</h2>"
                + "<p>Votre compte a été créé avec succès sur notre plateforme de covoiturage.</p>"
                + "<p>Vous pouvez dès maintenant :</p>"
                + "<ul>"
                + "<li>Rechercher des trajets</li>"
                + "<li>Proposer vos propres trajets</li>"
                + "<li>Gérer vos réservations</li>"
                + "</ul>"
                + "<a href='http://localhost:8080/covoiturageApp/dashboard' "
                + "style='background: #4a6cf7; color: white; padding: 12px 25px; "
                + "text-decoration: none; border-radius: 6px; display: inline-block;'>"
                + "Commencer à utiliser la plateforme"
                + "</a>"
                + "<br><br>"
                + "<p>Cordialement,<br>L'équipe Covoiturage App</p>"
                + "</body>"
                + "</html>";
        
        sendEmail(context, toEmail, subject, content);
    }
}