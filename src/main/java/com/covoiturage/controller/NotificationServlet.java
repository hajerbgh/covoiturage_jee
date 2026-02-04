package com.covoiturage.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.covoiturage.dao.NotificationDAO;
import com.covoiturage.model.Utilisateur;
import com.covoiturage.model.Notification;

public class NotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private NotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        notificationDAO = new NotificationDAO();
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
        String action = request.getParameter("action");
        
        if ("marquer-comme-lue".equals(action)) {
            String notificationId = request.getParameter("id");
            if (notificationId != null) {
                notificationDAO.marquerCommeLue(Long.parseLong(notificationId));
            }
            response.sendRedirect("/notification.jsp");
            return;
        }
        
        if ("marquer-toutes-lues".equals(action)) {
            notificationDAO.marquerToutesCommeLues(utilisateur.getId());
            response.sendRedirect("/notification.jsp");
            return;
        }
        
        if ("supprimer".equals(action)) {
            String notificationId = request.getParameter("id");
            if (notificationId != null) {
                notificationDAO.delete(Long.parseLong(notificationId));
            }
            response.sendRedirect("notifications");
            return;
        }
        
        // Récupérer les notifications
        List<Notification> notifications = notificationDAO.findByUtilisateurId(utilisateur.getId(), false);
        int notificationsNonLues = notificationDAO.countNonLues(utilisateur.getId());
        
        request.setAttribute("notifications", notifications);
        request.setAttribute("notificationsNonLues", notificationsNonLues);
        request.setAttribute("utilisateur", utilisateur);
        
        request.getRequestDispatcher("/notifications.jsp").forward(request, response);
    }
}