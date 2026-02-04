package com.covoiturage.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.text.SimpleDateFormat;


import com.covoiturage.dao.ReservationDAO;
import com.covoiturage.dao.UtilisateurDAO;  
import com.covoiturage.dao.TrajetDAO;
import com.covoiturage.model.Reservation;
import com.covoiturage.model.Trajet;
import com.covoiturage.model.Utilisateur;
import com.covoiturage.service.EmailService;
import com.covoiturage.util.DatabaseConnection;

public class ReservationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UtilisateurDAO utilisateurDAO;  

    private ReservationDAO reservationDAO;
    private TrajetDAO trajetDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
        trajetDAO = new TrajetDAO();
        utilisateurDAO = new UtilisateurDAO();  
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== RESERVATION SERVLET DOGET ===");
        System.out.println("URL: " + request.getRequestURI());
        System.out.println("Action: " + request.getParameter("action"));
        
        HttpSession session = request.getSession(false);
        
        // Vérifier si l'utilisateur est connecté
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("connexion.jsp");
            return;
        }
        
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
        String action = request.getParameter("action");
        
        // Vérifier si l'utilisateur est passager
        if (!"PASSAGER".equals(utilisateur.getRole())) {
            request.setAttribute("erreur", "Cette fonctionnalité est réservée aux passagers.");
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
            return;
        }
        
        if (action == null) {
            // Par défaut, afficher les réservations du passager
            System.out.println("Action: null - Afficher mes réservations");
            afficherMesReservations(request, response, utilisateur);
        } else {
            System.out.println("Action: " + action);
            switch (action) {
                case "creer":
                    // Afficher le formulaire de réservation
                    System.out.println("Afficher formulaire réservation");
                    afficherFormulaireReservation(request, response, utilisateur);
                    break;
                    
                case "annuler":
                    // Annuler une réservation
                    System.out.println("Annuler réservation");
                    annulerReservation(request, response, utilisateur);
                    break;
                    
                case "details":
                    // Afficher les détails d'une réservation
                    System.out.println("Afficher détails réservation");
                    afficherDetailsReservation(request, response, utilisateur);
                    break;
                    
                default:
                    System.out.println("Action inconnue - Afficher mes réservations");
                    afficherMesReservations(request, response, utilisateur);
                    break;
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== RESERVATION SERVLET DOPOST ===");
        System.out.println("Action POST: " + request.getParameter("action"));
        
        HttpSession session = request.getSession(false);
        
        // Vérifier si l'utilisateur est connecté
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("connexion.jsp");
            return;
        }
        
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
        String action = request.getParameter("action");
        
        if ("creer".equals(action)) {
            System.out.println("POST: Créer réservation");
            creerReservation(request, response, utilisateur);
        } else {
            System.out.println("POST: Action non reconnue -> GET");
            doGet(request, response);
        }
    }
    
    // Afficher les réservations du passager
    private void afficherMesReservations(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        System.out.println("=== Afficher mes réservations ===");
        System.out.println("Passager ID: " + utilisateur.getId());
        
        try {
            // Récupérer les réservations du passager
            java.util.List<Reservation> reservations = reservationDAO.findByPassagerId(utilisateur.getId());
            
            System.out.println("Nombre de réservations trouvées: " + (reservations != null ? reservations.size() : 0));
            
            request.setAttribute("reservations", reservations);
            
            System.out.println("Forward vers mes-reservations.jsp");
            request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("❌ ERREUR dans afficherMesReservations:");
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur lors du chargement de vos réservations: " + e.getMessage());
            request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
        }
    }
    
    // MODIFIÉ : Afficher le formulaire de réservation
    private void afficherFormulaireReservation(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String trajetIdStr = request.getParameter("trajetId");
        System.out.println("Trajet ID pour réservation: " + trajetIdStr);
        
        if (trajetIdStr == null || trajetIdStr.trim().isEmpty()) {
            System.out.println("❌ ERREUR: ID de trajet manquant");
            request.setAttribute("erreur", "ID de trajet manquant.");
            response.sendRedirect("trajets");
            return;
        }
        
        try {
            Long trajetId = Long.parseLong(trajetIdStr);
            Trajet trajet = trajetDAO.findById(trajetId);
            
            if (trajet == null) {
                System.out.println("❌ ERREUR: Trajet non trouvé ID=" + trajetId);
                request.setAttribute("erreur", "Trajet non trouvé.");
                response.sendRedirect("trajets");
                return;
            }
            
            System.out.println("Trajet trouvé: " + trajet.getDepart() + " → " + trajet.getDestination());
            System.out.println("Places disponibles: " + trajet.getPlacesDisponibles());
            
            // Vérifier la disponibilité
            if (trajet.getPlacesDisponibles() <= 0) {
                System.out.println("❌ ERREUR: Trajet complet");
                request.setAttribute("erreur", "Désolé, ce trajet est complet.");
                request.setAttribute("trajet", trajet);
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            // Vérifier que le passager n'est pas le conducteur
            boolean estConducteur = trajet.getConducteurId().equals(utilisateur.getId());
            System.out.println("Est conducteur: " + estConducteur);
            
            if (estConducteur) {
                System.out.println("❌ ERREUR: Passager est conducteur");
                request.setAttribute("erreur", "Vous ne pouvez pas réserver votre propre trajet.");
                request.setAttribute("trajet", trajet);
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ Toutes les vérifications OK - Affichage formulaire");
            request.setAttribute("trajet", trajet);
            request.getRequestDispatcher("/reserver-trajet.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            System.err.println("❌ ERREUR: ID de trajet invalide");
            e.printStackTrace();
            request.setAttribute("erreur", "ID de trajet invalide.");
            response.sendRedirect("trajets");
        } catch (Exception e) {
            System.err.println("❌ ERREUR dans afficherFormulaireReservation:");
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            response.sendRedirect("trajets");
        }
    }
    
    //  : Créer une nouvelle réservation

    private void creerReservation(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String trajetIdStr = request.getParameter("trajetId");
        System.out.println("=== Créer réservation ===");
        System.out.println("Trajet ID: " + trajetIdStr);
        
        if (trajetIdStr == null || trajetIdStr.trim().isEmpty()) {
            System.out.println("❌ ERREUR: ID de trajet manquant");
            request.setAttribute("erreur", "ID de trajet manquant.");
            request.getRequestDispatcher("/reserver-trajet.jsp").forward(request, response);
            return;
        }
        
        try {
            Long trajetId = Long.parseLong(trajetIdStr);
            Trajet trajet = trajetDAO.findById(trajetId);
            
            if (trajet == null) {
                System.out.println("❌ ERREUR: Trajet non trouvé");
                request.setAttribute("erreur", "Trajet non trouvé.");
                request.getRequestDispatcher("/reserver-trajet.jsp").forward(request, response);
                return;
            }
            
            System.out.println("Vérifications du trajet...");
            
            // Vérifier que le passager n'est pas le conducteur
            if (trajet.getConducteurId().equals(utilisateur.getId())) {
                System.out.println("❌ ERREUR: Passager est conducteur");
                request.setAttribute("erreur", "Vous ne pouvez pas réserver votre propre trajet.");
                request.setAttribute("trajet", trajet);
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            // Récupérer le nombre de places déjà réservées par cet utilisateur
            int placesDejaReservees = reservationDAO.getNombrePlacesReservees(trajetId, utilisateur.getId());
            System.out.println("Places déjà réservées par cet utilisateur: " + placesDejaReservees);
            
            // Vérifier la disponibilité
            if (trajet.getPlacesDisponibles() <= 0) {
                System.out.println("❌ ERREUR: Trajet complet");
                request.setAttribute("erreur", "Désolé, ce trajet est maintenant complet.");
                request.setAttribute("trajet", trajet);
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ Création de l'objet réservation...");
            
            // Créer la réservation
            Reservation reservation = new Reservation();
            reservation.setTrajetId(trajetId);
            reservation.setPassagerId(utilisateur.getId());
            reservation.setStatut("EN_ATTENTE");
            reservation.setDateReservation(new Date());
            reservation.setPrixTotal(trajet.getPrix()); // 1 place = prix du trajet
            
            System.out.println("Appel à reservationDAO.create()...");
            boolean success = reservationDAO.create(reservation);
            System.out.println("Résultat création: " + success);
            
            if (success) {
                System.out.println("✅ Réservation créée avec ID: " + reservation.getId());
                
                // Mettre à jour les places disponibles (diminuer de 1)
                int nouvellesPlaces = trajet.getPlacesDisponibles() - 1;
                trajet.setPlacesDisponibles(nouvellesPlaces);
                System.out.println("Nouvelles places disponibles: " + nouvellesPlaces);
                
                // Mettre à jour le trajet dans la base de données
                System.out.println("Mise à jour places disponibles...");
                boolean trajetUpdated = updateTrajetPlacesDisponibles(trajet);
                System.out.println("Résultat mise à jour trajet: " + trajetUpdated);
                
                if (trajetUpdated) {
                    System.out.println("=== DEBUG EMAIL ===");
                    System.out.println("Contexte Servlet: " + (getServletContext() != null));
                    
                    // Test configuration email
                    String host = getServletContext().getInitParameter("mail.smtp.host");
                    String username = getServletContext().getInitParameter("mail.username");
                    System.out.println("SMTP Host: " + host);
                    System.out.println("SMTP Username: " + username);
                    
                    
                    Utilisateur conducteur = utilisateurDAO.findById(trajet.getConducteurId());
                    
                    if (conducteur != null) {
                        System.out.println("✅ Conducteur trouvé: " + conducteur.getPrenom() + " " + conducteur.getNom());
                        System.out.println("📧 Email conducteur: " + conducteur.getEmail());
                        System.out.println("📞 Téléphone conducteur: " + conducteur.getTelephone());
                        System.out.println("📧 Email passager: " + utilisateur.getEmail());
                        
                        // Test simple d'envoi
                        try {
                            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                            String dateDepart = sdf.format(trajet.getDateDepart());
                            
                            System.out.println("🔄 Tentative envoi email...");
                            
                            // Test 1: Email simple
                            boolean emailSent = EmailService.sendEmail(
                                getServletContext(),
                                utilisateur.getEmail(),
                                "Test Email Covoiturage",
                                "<h1>Test d'email</h1><p>Si vous recevez ceci, le service email fonctionne.</p>"
                            );
                            
                            System.out.println("✅ Résultat test email: " + emailSent);
                            
                            // Test 2: Email de notification (conducteur)
                            if (emailSent) {
                                String trajetDetails = trajet.getDepart() + " → " + trajet.getDestination();
                                String prixFormatted = String.format("%.2f DT", trajet.getPrix());
                                
                                System.out.println("🔄 Envoi email notification conducteur...");
                                EmailService.sendReservationNotification(
                                    getServletContext(),
                                    conducteur.getEmail(),
                                    conducteur.getPrenom(),
                                    trajetDetails,
                                    dateDepart,
                                    prixFormatted
                                );
                                System.out.println("✅ Email notification envoyé au conducteur");
                                
                                // Test 3: Email confirmation (passager)
                                System.out.println("🔄 Envoi email confirmation passager...");
                                String telephoneConducteur = (conducteur.getTelephone() != null) ? 
                                    conducteur.getTelephone() : "Non renseigné";
                                
                                EmailService.sendReservationConfirmation(
                                    getServletContext(),
                                    utilisateur.getEmail(),
                                    utilisateur.getPrenom(),
                                    trajetDetails,
                                    dateDepart,
                                    prixFormatted,
                                    conducteur.getPrenom() + " " + conducteur.getNom(),
                                    telephoneConducteur
                                );
                                System.out.println("✅ Email confirmation envoyé au passager");
                            }
                            
                        } catch (Exception e) {
                            System.err.println("❌ Erreur lors de l'envoi des emails: " + e.getMessage());
                            e.printStackTrace();
                        }
                    } else {
                        System.err.println("❌ Conducteur non trouvé avec ID: " + trajet.getConducteurId());
                    }
                    
                    System.out.println("✅ Tout est réussi - Redirection...");
                    // Stocker le message de succès
                    request.getSession().setAttribute("successMessage", 
                        "✅ Votre réservation a été enregistrée avec succès ! " +
                        "Le conducteur doit maintenant confirmer votre réservation. " +
                        "Un email de confirmation vous a été envoyé.");
                    
                    // Rediriger vers les détails de la réservation
                    response.sendRedirect("reservations?action=details&reservationId=" + reservation.getId());
                } else {
                    System.out.println("❌ ERREUR: Échec mise à jour places");
                    request.setAttribute("erreur", "❌ Erreur lors de la mise à jour des places disponibles.");
                    request.setAttribute("trajet", trajet);
                    request.getRequestDispatcher("/reserver-trajet.jsp").forward(request, response);
                }
            } else {
                System.out.println("❌ ERREUR: Échec création réservation");
                request.setAttribute("erreur", "❌ Erreur lors de l'enregistrement de la réservation.");
                request.setAttribute("trajet", trajet);
                request.getRequestDispatcher("/reserver-trajet.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            System.err.println("❌ ERREUR: ID de trajet invalide");
            e.printStackTrace();
            request.setAttribute("erreur", "ID de trajet invalide.");
            request.getRequestDispatcher("/reserver-trajet.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("❌ ERREUR dans creerReservation:");
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/reserver-trajet.jsp").forward(request, response);
        }
    }
    
    // Annuler une réservation
    private void annulerReservation(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String reservationIdStr = request.getParameter("reservationId");
        System.out.println("=== Annuler réservation ===");
        System.out.println("Reservation ID: " + reservationIdStr);
        
        if (reservationIdStr == null || reservationIdStr.trim().isEmpty()) {
            System.out.println("❌ ERREUR: ID de réservation manquant");
            request.setAttribute("erreur", "ID de réservation manquant.");
            request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
            return;
        }
        
        try {
            Long reservationId = Long.parseLong(reservationIdStr);
            Reservation reservation = reservationDAO.findById(reservationId);
            
            if (reservation == null) {
                System.out.println("❌ ERREUR: Réservation non trouvée");
                request.setAttribute("erreur", "Réservation non trouvée.");
                request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
                return;
            }
            
            System.out.println("Réservation trouvée - Passager ID: " + reservation.getPassagerId());
            System.out.println("Utilisateur ID: " + utilisateur.getId());
            
            // Vérifier que la réservation appartient bien au passager
            if (!reservation.getPassagerId().equals(utilisateur.getId())) {
                System.out.println("❌ ERREUR: Réservation n'appartient pas à l'utilisateur");
                request.setAttribute("erreur", "Vous n'êtes pas autorisé à annuler cette réservation.");
                request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
                return;
            }
            
            System.out.println("Statut actuel: " + reservation.getStatut());
            
            // Vérifier que la réservation peut être annulée
            if ("ANNULEE".equals(reservation.getStatut())) {
                System.out.println("❌ ERREUR: Déjà annulée");
                request.setAttribute("erreur", "Cette réservation est déjà annulée.");
                request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
                return;
            }
            
            if ("TERMINEE".equals(reservation.getStatut())) {
                System.out.println("❌ ERREUR: Déjà terminée");
                request.setAttribute("erreur", "Impossible d'annuler une réservation terminée.");
                request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
                return;
            }
            
            System.out.println("Appel à annulerReservation()...");
            // Annuler la réservation
            boolean success = reservationDAO.annulerReservation(reservationId);
            System.out.println("Résultat annulation: " + success);
            
            if (success) {
                System.out.println("✅ Réservation annulée - Mise à jour places...");
                // Augmenter les places disponibles
                Trajet trajet = trajetDAO.findById(reservation.getTrajetId());
                if (trajet != null) {
                    int nouvellesPlaces = trajet.getPlacesDisponibles() + 1;
                    trajet.setPlacesDisponibles(nouvellesPlaces);
                    System.out.println("Nouvelles places disponibles: " + nouvellesPlaces);
                    
                    // Mettre à jour le trajet dans la base de données
                    boolean trajetUpdated = updateTrajetPlacesDisponibles(trajet);
                    
                    if (trajetUpdated) {
                        System.out.println("✅ Tout est réussi");
                        request.getSession().setAttribute("successMessage", "✅ Réservation annulée avec succès !");
                        response.sendRedirect("reservations");
                    } else {
                        System.out.println("❌ ERREUR: Échec mise à jour places");
                        request.setAttribute("erreur", "❌ Erreur lors de la mise à jour des places disponibles.");
                        request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
                    }
                } else {
                    System.out.println("⚠️ Trajet non trouvé, mais réservation annulée");
                    request.getSession().setAttribute("successMessage", "✅ Réservation annulée avec succès !");
                    response.sendRedirect("reservations");
                }
            } else {
                System.out.println("❌ ERREUR: Échec annulation");
                request.setAttribute("erreur", "❌ Erreur lors de l'annulation de la réservation.");
                request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            System.err.println("❌ ERREUR dans annulerReservation:");
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
        }
    }
    
    // Afficher les détails d'une réservation
    private void afficherDetailsReservation(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String reservationIdStr = request.getParameter("reservationId");
        System.out.println("=== Afficher détails réservation ===");
        System.out.println("Reservation ID: " + reservationIdStr);
        
        if (reservationIdStr == null || reservationIdStr.trim().isEmpty()) {
            System.out.println("❌ ERREUR: ID de réservation manquant");
            request.setAttribute("erreur", "ID de réservation manquant.");
            request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
            return;
        }
        
        try {
            Long reservationId = Long.parseLong(reservationIdStr);
            Reservation reservation = reservationDAO.findById(reservationId);
            
            if (reservation == null) {
                System.out.println("❌ ERREUR: Réservation non trouvée");
                request.setAttribute("erreur", "Réservation non trouvée.");
                request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
                return;
            }
            
            System.out.println("Réservation trouvée - Passager ID: " + reservation.getPassagerId());
            System.out.println("Utilisateur ID: " + utilisateur.getId());
            
            // Vérifier que la réservation appartient bien au passager
            if (!reservation.getPassagerId().equals(utilisateur.getId())) {
                System.out.println("❌ ERREUR: Accès non autorisé");
                request.setAttribute("erreur", "Accès non autorisé.");
                request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ Affichage détails réservation");
            request.setAttribute("reservation", reservation);
            request.getRequestDispatcher("/details-reservation.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("❌ ERREUR dans afficherDetailsReservation:");
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/mes-reservations.jsp").forward(request, response);
        }
    }
    
    // Méthode pour mettre à jour seulement les places disponibles d'un trajet
    private boolean updateTrajetPlacesDisponibles(Trajet trajet) {
        String sql = "UPDATE trajet SET places_disponibles = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, trajet.getPlacesDisponibles());
            pstmt.setLong(2, trajet.getId());
            
            int rowsUpdated = pstmt.executeUpdate();
            System.out.println("Rows updated: " + rowsUpdated);
            
            return rowsUpdated > 0;
            
        } catch (Exception e) {
            System.err.println("❌ Erreur mise à jour places disponibles: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}