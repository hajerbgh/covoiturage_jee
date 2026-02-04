package com.covoiturage.controller;

import java.io.IOException;
import java.util.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.covoiturage.dao.AvisDAO;
import com.covoiturage.dao.ReservationDAO;
import com.covoiturage.dao.TrajetDAO;
import com.covoiturage.model.Reservation;
import com.covoiturage.model.Trajet;
import com.covoiturage.model.Utilisateur;

public class HistoriqueServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private ReservationDAO reservationDAO;
    private TrajetDAO trajetDAO;
    private AvisDAO avisDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
        trajetDAO = new TrajetDAO();
        avisDAO = new AvisDAO(); // Assurez-vous d'avoir cette classe
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
        String role = utilisateur.getRole();
        
        System.out.println("=== HISTORIQUE SERVLET ===");
        System.out.println("Utilisateur: " + utilisateur.getEmail() + " - Rôle: " + role);
        
        if ("PASSAGER".equals(role)) {
            // Pour les passagers : récupérer les réservations passées
            List<Reservation> toutesReservations = reservationDAO.findByPassagerId(utilisateur.getId());
            System.out.println("Nombre total de réservations: " + toutesReservations.size());
            
            // 1. Historique normal (terminés et annulés)
            List<Reservation> reservationsPassees = toutesReservations.stream()
                .filter(r -> "TERMINEE".equals(r.getStatut()) || "ANNULEE".equals(r.getStatut()))
                .toList();
            
            // 2. Évaluations à faire (terminés mais non évalués)
            List<Reservation> evaluationsAFaire = toutesReservations.stream()
                .filter(r -> "TERMINEE".equals(r.getStatut()))
                .filter(r -> !avisDAO.aDejaEvalue(r.getTrajetId(), utilisateur.getId()))
                .toList();
            
            request.setAttribute("reservationsPassees", reservationsPassees);
            request.setAttribute("evaluationsAFaire", evaluationsAFaire);
            
            System.out.println("Historique: " + reservationsPassees.size() + " réservations");
            System.out.println("Évaluations à faire: " + evaluationsAFaire.size() + " réservations");
            
        } else if ("CONDUCTEUR".equals(role)) {
            // Pour les conducteurs : récupérer les trajets passés
            List<Trajet> tousTrajets = trajetDAO.findByConducteur(utilisateur.getId());
            System.out.println("Nombre total de trajets: " + tousTrajets.size());
            
            List<Trajet> trajetsPassees = tousTrajets.stream()
                .filter(t -> "TERMINE".equals(t.getStatut()) || "ANNULE".equals(t.getStatut()))
                .toList();
            
            request.setAttribute("trajetsPassees", trajetsPassees);
            System.out.println("Historique conducteur: " + trajetsPassees.size() + " trajets");
        }
        
        request.getRequestDispatcher("/historique.jsp").forward(request, response);
    }
}