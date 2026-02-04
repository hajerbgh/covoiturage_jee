package com.covoiturage.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.covoiturage.dao.TrajetDAO;
import com.covoiturage.dao.ReservationDAO;
import com.covoiturage.dao.AvisDAO;
import com.covoiturage.model.Avis;
import com.covoiturage.model.Utilisateur;
import com.covoiturage.dao.NotificationDAO;

public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private TrajetDAO trajetDAO;
    private ReservationDAO reservationDAO;
    private AvisDAO avisDAO;
    
    @Override
    public void init() throws ServletException {
        trajetDAO = new TrajetDAO();
        reservationDAO = new ReservationDAO();
        avisDAO = new AvisDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect(request.getContextPath() + "/connexion");
            return;
        }
        
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
        Long userId = utilisateur.getId();
        String role = utilisateur.getRole();
      
        String action = request.getParameter("action");
     
        if ("check-notifications".equals(action)) {
            NotificationDAO notificationDAO = new NotificationDAO();
            int notificationsNonLues = notificationDAO.countNonLues(userId);
            response.setContentType("text/plain");
            response.getWriter().print(notificationsNonLues);
            return;
        }
        if ("mes-avis".equals(action)) {
            try {
                // Charger les avis reçus
                List<Avis> avisRecus = avisDAO.getAvisByUtilisateurId(userId.intValue());
                request.setAttribute("avisRecus", avisRecus);
                request.setAttribute("utilisateur", utilisateur);
                NotificationDAO notificationDAO = new NotificationDAO();
                int notificationsNonLues = notificationDAO.countNonLues(userId);

                request.setAttribute("notificationsNonLues", notificationsNonLues);
                // Transférer à la JSP
                RequestDispatcher dispatcher = request.getRequestDispatcher("/mes-avis.jsp");
                dispatcher.forward(request, response);
                return;
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("erreur", "Erreur lors du chargement des avis");
                request.getRequestDispatcher("/mes-avis.jsp").forward(request, response);
                return;
            }
        }
        
        try {
            if ("CONDUCTEUR".equals(role)) {
                // Statistiques pour CONDUCTEUR
            	System.out.println("Calcul trajetsProposes...");
                int trajetsProposes = trajetDAO.countByConducteur(userId);
                System.out.println("trajetsProposes: " + trajetsProposes);
                int reservationsPourMesTrajets = reservationDAO.countByConducteurId(userId);
                System.out.println("reservationsPourMesTrajets: " + reservationsPourMesTrajets);
                double noteMoyenne = avisDAO.getNoteMoyenneConducteur(userId);
                int avisRecus = avisDAO.countByEvalueId(userId);
                System.out.println("avisRecus: " + avisRecus);
                NotificationDAO notificationDAO = new NotificationDAO();
                int notificationsNonLues = notificationDAO.countNonLues(userId);
                
                request.setAttribute("notificationsNonLues", notificationsNonLues);
                request.setAttribute("trajetsProposes", trajetsProposes);
                request.setAttribute("reservations", reservationsPourMesTrajets);
                request.setAttribute("noteMoyenne", noteMoyenne);
                request.setAttribute("avisRecus", avisRecus);
                
            } else if ("PASSAGER".equals(role)) {
                // Statistiques pour PASSAGER
                int reservations = reservationDAO.countByPassagerId(userId);
                double noteMoyenne = avisDAO.getNoteMoyennePassager(userId);
                int avisRecus = avisDAO.countByEvalueId(userId);
                
                request.setAttribute("reservations", reservations);
                request.setAttribute("noteMoyenne", noteMoyenne);
                request.setAttribute("avisRecus", avisRecus);
            }
            
            request.setAttribute("utilisateur", utilisateur);
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur lors du chargement du dashboard");
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
            throw e;
        }
    }
}