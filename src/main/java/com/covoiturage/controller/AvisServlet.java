package com.covoiturage.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.covoiturage.dao.AvisDAO;
import com.covoiturage.model.Utilisateur;
import com.covoiturage.model.Avis;


public class AvisServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private AvisDAO avisDAO;
    
    @Override
    public void init() throws ServletException {
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
        
        try {
            List<Avis> avisRecus = avisDAO.getAvisByUtilisateurId(utilisateur.getId().intValue());
            request.setAttribute("avisRecus", avisRecus);
            request.setAttribute("utilisateur", utilisateur);
            
            request.getRequestDispatcher("/mes-avis.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur lors du chargement des avis");
            request.getRequestDispatcher("/mes-avis.jsp").forward(request, response);
        }
    }
}