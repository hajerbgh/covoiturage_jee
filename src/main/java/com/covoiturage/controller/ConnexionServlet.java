package com.covoiturage.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.covoiturage.dao.UtilisateurDAO;
import com.covoiturage.model.Utilisateur;

public class ConnexionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UtilisateurDAO utilisateurDAO;
    
    @Override
    public void init() throws ServletException {
        utilisateurDAO = new UtilisateurDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Afficher le formulaire de connexion
        request.getRequestDispatcher("/WEB-INF/views/connexion.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Récupérer les données du formulaire
        String email = request.getParameter("email");
        String motDePasse = request.getParameter("mot_de_passe");
        
        // Validation
        if (email == null || email.isEmpty() || 
            motDePasse == null || motDePasse.isEmpty()) {
            
            request.setAttribute("erreur", "Email et mot de passe requis");
            request.getRequestDispatcher("/WEB-INF/views/connexion.jsp").forward(request, response);
            return;
        }
        
        // Vérifier les identifiants
        Utilisateur utilisateur = utilisateurDAO.checkLogin(email, motDePasse);
        
        if (utilisateur != null) {
            // Créer la session
            HttpSession session = request.getSession();
            session.setAttribute("utilisateur", utilisateur);
            session.setAttribute("utilisateurId", utilisateur.getId());
            session.setAttribute("utilisateurNom", utilisateur.getNomComplet());
            session.setAttribute("utilisateurRole", utilisateur.getRole());
            
            // Rediriger vers le dashboard
            response.sendRedirect("dashboard");
        } else {
            request.setAttribute("erreur", "Email ou mot de passe incorrect");
            request.getRequestDispatcher("connexion.jsp").forward(request, response);
        }
    }
}