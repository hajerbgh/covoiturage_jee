package com.covoiturage.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.covoiturage.dao.ReservationDAO;
import com.covoiturage.dao.TrajetDAO;
import com.covoiturage.model.Reservation;
import com.covoiturage.model.Trajet;
import com.covoiturage.model.Utilisateur;

public class PassagerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private ReservationDAO reservationDAO;
    private TrajetDAO trajetDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
        trajetDAO = new TrajetDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Vérifier si l'utilisateur est connecté
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("connexion.jsp");
            return;
        }
        
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
        String action = request.getParameter("action");
        
        // Vérifier si l'utilisateur est conducteur
        if (!"CONDUCTEUR".equals(utilisateur.getRole())) {
            request.setAttribute("erreur", "Cette fonctionnalité est réservée aux conducteurs.");
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
            return;
        }
        
        if (action == null) {
            // Par défaut, afficher tous les passagers de tous les trajets
            afficherMesPassagers(request, response, utilisateur);
        } else {
            switch (action) {
                case "trajet":
                    // Afficher les passagers d'un trajet spécifique
                    afficherPassagersParTrajet(request, response, utilisateur);
                    break;
                    
                case "confirmer":
                    // Confirmer une réservation
                    confirmerReservation(request, response, utilisateur);
                    break;
                    
                case "annuler":
                    // Annuler une réservation
                    annulerReservation(request, response, utilisateur);
                    break;
                    
                case "details":
                    // Afficher les détails d'une réservation
                    afficherDetailsReservation(request, response, utilisateur);
                    break;
                    
                default:
                    afficherMesPassagers(request, response, utilisateur);
                    break;
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response); // Traiter POST comme GET
    }
    
    // Méthode pour afficher tous les passagers de tous les trajets
    private void afficherMesPassagers(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        try {
            // Vous avez besoin d'une méthode dans ReservationDAO pour récupérer toutes les réservations
            // des trajets d'un conducteur
            // Pour l'instant, on va récupérer tous les trajets du conducteur
            List<Trajet> trajets = trajetDAO.findByConducteur(utilisateur.getId());
            
            // Récupérer toutes les réservations pour ces trajets
            List<Reservation> reservations = reservationDAO.findByConducteurId(utilisateur.getId());
            
            request.setAttribute("reservations", reservations);
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur lors du chargement des passagers.");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
        }
    }
    
    // Méthode pour afficher les passagers d'un trajet spécifique
    private void afficherPassagersParTrajet(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String trajetIdStr = request.getParameter("trajetId");
        
        if (trajetIdStr == null || trajetIdStr.trim().isEmpty()) {
            request.setAttribute("erreur", "ID de trajet manquant.");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            return;
        }
        
        try {
            Long trajetId = Long.parseLong(trajetIdStr);
            
            // Vérifier que le trajet appartient bien au conducteur
            Trajet trajet = trajetDAO.findById(trajetId);
            if (trajet == null || !trajet.getConducteurId().equals(utilisateur.getId())) {
                request.setAttribute("erreur", "Trajet non trouvé ou accès non autorisé.");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
                return;
            }
            
            // Récupérer les réservations du trajet
            List<Reservation> reservations = reservationDAO.findByTrajetId(trajetId);
            
            request.setAttribute("reservations", reservations);
            request.setAttribute("trajet", trajet);
            request.setAttribute("filtreTrajet", true);
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("erreur", "ID de trajet invalide.");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur lors du chargement des passagers.");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
        }
    }
    
    // Méthode pour confirmer une réservation
    private void confirmerReservation(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String reservationIdStr = request.getParameter("reservationId");
        
        if (reservationIdStr == null || reservationIdStr.trim().isEmpty()) {
            request.setAttribute("erreur", "ID de réservation manquant.");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            return;
        }
        
        try {
            Long reservationId = Long.parseLong(reservationIdStr);
            
            // Vérifier que la réservation appartient à un trajet du conducteur
            Reservation reservation = reservationDAO.findById(reservationId);
            if (reservation == null) {
                request.setAttribute("erreur", "Réservation non trouvée.");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
                return;
            }
            
            Trajet trajet = trajetDAO.findById(reservation.getTrajetId());
            if (trajet == null || !trajet.getConducteurId().equals(utilisateur.getId())) {
                request.setAttribute("erreur", "Vous n'êtes pas autorisé à modifier cette réservation.");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
                return;
            }
            
            // Confirmer la réservation
            boolean success = reservationDAO.updateStatut(reservationId, "CONFIRMEE");
            
            if (success) {
                // Stocker le message de succès dans la session
                request.getSession().setAttribute("successMessage", "✅ Réservation confirmée avec succès !");
                // Rediriger vers la page des passagers du trajet
                response.sendRedirect("passagers?action=trajet&trajetId=" + trajet.getId());
            } else {
                request.setAttribute("erreur", "❌ Erreur lors de la confirmation de la réservation.");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
        }
    }
    
    // Méthode pour annuler une réservation
    private void annulerReservation(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String reservationIdStr = request.getParameter("reservationId");
        
        if (reservationIdStr == null || reservationIdStr.trim().isEmpty()) {
            request.setAttribute("erreur", "ID de réservation manquant.");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            return;
        }
        
        try {
            Long reservationId = Long.parseLong(reservationIdStr);
            
            // Vérifier que la réservation appartient à un trajet du conducteur
            Reservation reservation = reservationDAO.findById(reservationId);
            if (reservation == null) {
                request.setAttribute("erreur", "Réservation non trouvée.");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
                return;
            }
            
            Trajet trajet = trajetDAO.findById(reservation.getTrajetId());
            if (trajet == null || !trajet.getConducteurId().equals(utilisateur.getId())) {
                request.setAttribute("erreur", "Vous n'êtes pas autorisé à modifier cette réservation.");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
                return;
            }
            
            // Annuler la réservation
            boolean success = reservationDAO.updateStatut(reservationId, "ANNULEE");
            
            if (success) {
                // Augmenter les places disponibles
                trajet.setPlacesDisponibles(trajet.getPlacesDisponibles() + 1);
                trajetDAO.updatePlaces(trajet.getId(), trajet.getPlacesDisponibles());
                
                // Stocker le message de succès dans la session
                request.getSession().setAttribute("successMessage", "✅ Réservation annulée avec succès !");
                // Rediriger vers la page des passagers du trajet
                response.sendRedirect("passagers?action=trajet&trajetId=" + trajet.getId());
            } else {
                request.setAttribute("erreur", "❌ Erreur lors de l'annulation de la réservation.");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
        }
    }
    
    // Méthode pour afficher les détails d'une réservation
    private void afficherDetailsReservation(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String reservationIdStr = request.getParameter("reservationId");
        
        if (reservationIdStr == null || reservationIdStr.trim().isEmpty()) {
            request.setAttribute("erreur", "ID de réservation manquant.");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            return;
        }
        
        try {
            Long reservationId = Long.parseLong(reservationIdStr);
            Reservation reservation = reservationDAO.findById(reservationId);
            
            if (reservation == null) {
                request.setAttribute("erreur", "Réservation non trouvée.");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
                return;
            }
            
            // Vérifier que le trajet appartient bien au conducteur
            Trajet trajet = trajetDAO.findById(reservation.getTrajetId());
            if (trajet == null || !trajet.getConducteurId().equals(utilisateur.getId())) {
                request.setAttribute("erreur", "Vous n'êtes pas autorisé à voir cette réservation.");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
                return;
            }
            
            request.setAttribute("reservation", reservation);
            request.setAttribute("trajet", trajet);
            request.getRequestDispatcher("/details-reservation-conducteur.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
        }
    }
}