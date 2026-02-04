package com.covoiturage.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.covoiturage.dao.UtilisateurDAO;
import com.covoiturage.model.Utilisateur;

public class InscriptionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UtilisateurDAO utilisateurDAO;
    
    @Override
    public void init() throws ServletException {
        utilisateurDAO = new UtilisateurDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Afficher le formulaire d'inscription
        request.getRequestDispatcher("/inscription.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Récupérer les données du formulaire
        String nom = request.getParameter("nom");
        String prenom = request.getParameter("prenom");
        String email = request.getParameter("email");
        String motDePasse = request.getParameter("mot_de_passe");
        String telephone = request.getParameter("telephone");
        String role = request.getParameter("role");
        
        // Validation basique
        if (nom == null || nom.isEmpty() || 
            prenom == null || prenom.isEmpty() ||
            email == null || email.isEmpty() ||
            motDePasse == null || motDePasse.isEmpty()) {
            
            request.setAttribute("erreur", "Tous les champs obligatoires doivent être remplis");
            request.getRequestDispatcher("/inscription.jsp").forward(request, response);
            return;
        }
        
        // Vérifier si l'email existe déjà
        if (utilisateurDAO.findByEmail(email) != null) {
            request.setAttribute("erreur", "Cet email est déjà utilisé");
            request.getRequestDispatcher("/inscription.jsp").forward(request, response);
            return;
        }
        
        // Créer l'utilisateur
        Utilisateur nouvelUtilisateur = new Utilisateur(nom, prenom, email, motDePasse, role);
        nouvelUtilisateur.setTelephone(telephone);
        
        // Sauvegarder dans la base
        if (utilisateurDAO.create(nouvelUtilisateur)) {
            // Rediriger vers la page de connexion avec un message de succès
            request.setAttribute("success", "Inscription réussie ! Vous pouvez maintenant vous connecter.");
            request.getRequestDispatcher("/WEB-INF/views/connexion.jsp").forward(request, response);
        } else {
            request.setAttribute("erreur", "Erreur lors de l'inscription. Veuillez réessayer.");
            request.getRequestDispatcher("/inscription.jsp").forward(request, response);
        }
    }
}