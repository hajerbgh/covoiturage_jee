package com.covoiturage.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.covoiturage.dao.UtilisateurDAO;
import com.covoiturage.model.Utilisateur;

public class ProfilServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UtilisateurDAO utilisateurDAO;
    
    @Override
    public void init() throws ServletException {
        utilisateurDAO = new UtilisateurDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== PROFIL SERVLET DOGET ===");
        System.out.println("Request URI: " + request.getRequestURI());
        System.out.println("Context Path: " + request.getContextPath());
        System.out.println("Servlet Path: " + request.getServletPath());
        
        HttpSession session = request.getSession(false);
        
        // Vérifier si l'utilisateur est connecté
        if (session == null || session.getAttribute("utilisateur") == null) {
            System.out.println("❌ Session null ou utilisateur non connecté");
            response.sendRedirect("connexion.jsp");
            return;
        }
        
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
        System.out.println("✅ Utilisateur connecté: " + utilisateur.getEmail());
        
        // Vérifier si le fichier existe
        String realPath = getServletContext().getRealPath("/profil.jsp");
        System.out.println("Chemin réel de profil.jsp: " + realPath);
        
        java.io.File file = new java.io.File(realPath);
        if (file.exists()) {
            System.out.println("✅ Fichier profil.jsp EXISTE (" + file.length() + " bytes)");
        } else {
            System.out.println("❌ Fichier profil.jsp N'EXISTE PAS");
            // Lister le contenu du répertoire
            String parentDir = file.getParent();
            System.out.println("Parent directory: " + parentDir);
            java.io.File parent = new java.io.File(parentDir);
            if (parent.exists()) {
                System.out.println("Contenu du répertoire:");
                for (String f : parent.list()) {
                    System.out.println("  - " + f);
                }
            }
            return;
        }
        
        // Récupérer les informations à jour de l'utilisateur
        Utilisateur utilisateurMaj = utilisateurDAO.findById(utilisateur.getId());
        if (utilisateurMaj != null) {
            // Mettre à jour l'utilisateur dans la session
            session.setAttribute("utilisateur", utilisateurMaj);
            request.setAttribute("utilisateur", utilisateurMaj);
        } else {
            request.setAttribute("utilisateur", utilisateur);
        }
        
        System.out.println("Tentative de forward vers /profil.jsp...");
        
        try {
            // Essayer avec getRequestDispatcher
            javax.servlet.RequestDispatcher dispatcher = request.getRequestDispatcher("/profil.jsp");
            if (dispatcher != null) {
                System.out.println("✅ RequestDispatcher obtenu");
                dispatcher.forward(request, response);
                System.out.println("✅ Forward exécuté avec succès");
            } else {
                System.out.println("❌ RequestDispatcher est null");
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    "RequestDispatcher est null pour /profil.jsp");
            }
        } catch (Exception e) {
            System.err.println("❌ Exception lors du forward: " + e.getClass().getName() + " - " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Erreur lors du forward: " + e.getMessage());
        }
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Vérifier si l'utilisateur est connecté
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("connexion.jsp");
            return;
        }
        
        Utilisateur utilisateurSession = (Utilisateur) session.getAttribute("utilisateur");
        String action = request.getParameter("action");
        
        if ("modifier".equals(action)) {
            modifierProfil(request, response, utilisateurSession);
        } else if ("changer-motdepasse".equals(action)) {
            changerMotDePasse(request, response, utilisateurSession);
        } else {
            request.setAttribute("erreur", "Action non reconnue.");
            request.getRequestDispatcher("/profil.jsp").forward(request, response);
        }
    }
    
    private void modifierProfil(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateurSession) 
            throws ServletException, IOException {
        
        // Récupérer les données du formulaire
        String nom = request.getParameter("nom");
        String prenom = request.getParameter("prenom");
        String email = request.getParameter("email");
        String telephone = request.getParameter("telephone");
        
        // Validation des données
        StringBuilder erreurs = new StringBuilder();
        
        if (nom == null || nom.trim().isEmpty()) {
            erreurs.append("Le nom est requis.<br>");
        }
        
        if (prenom == null || prenom.trim().isEmpty()) {
            erreurs.append("Le prénom est requis.<br>");
        }
        
        if (email == null || email.trim().isEmpty()) {
            erreurs.append("L'email est requis.<br>");
        }
        
        if (erreurs.length() > 0) {
            request.setAttribute("erreur", erreurs.toString());
            request.getRequestDispatcher("/profil.jsp").forward(request, response);
            return;
        }
        
        try {
            // Vérifier si l'email est déjà utilisé par un autre utilisateur
            if (!email.equals(utilisateurSession.getEmail())) {
                Utilisateur utilisateurExist = utilisateurDAO.findByEmail(email);
                if (utilisateurExist != null && !utilisateurExist.getId().equals(utilisateurSession.getId())) {
                    request.setAttribute("erreur", "Cet email est déjà utilisé par un autre utilisateur.");
                    request.getRequestDispatcher("/profil.jsp").forward(request, response);
                    return;
                }
            }
            
            // Mettre à jour l'utilisateur
            utilisateurSession.setNom(nom.trim());
            utilisateurSession.setPrenom(prenom.trim());
            utilisateurSession.setEmail(email.trim());
            utilisateurSession.setTelephone(telephone != null ? telephone.trim() : null);
            
            boolean success = utilisateurDAO.update(utilisateurSession);
            
            if (success) {
                // Mettre à jour l'utilisateur dans la session
                request.getSession().setAttribute("utilisateur", utilisateurSession);
                request.setAttribute("success", "✅ Vos informations ont été mises à jour avec succès !");
            } else {
                request.setAttribute("erreur", "❌ Une erreur est survenue lors de la mise à jour.");
            }
            
            request.setAttribute("utilisateur", utilisateurSession);
            request.getRequestDispatcher("/profil.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "❌ Une erreur inattendue est survenue: " + e.getMessage());
            request.getRequestDispatcher("/profil.jsp").forward(request, response);
        }
    }
    
    private void changerMotDePasse(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateurSession) 
            throws ServletException, IOException {
        
        // Récupérer les données du formulaire
        String motDePasseActuel = request.getParameter("motDePasseActuel");
        String nouveauMotDePasse = request.getParameter("nouveauMotDePasse");
        String confirmerMotDePasse = request.getParameter("confirmerMotDePasse");
        
        // Validation des données
        StringBuilder erreurs = new StringBuilder();
        
        if (motDePasseActuel == null || motDePasseActuel.trim().isEmpty()) {
            erreurs.append("Le mot de passe actuel est requis.<br>");
        }
        
        if (nouveauMotDePasse == null || nouveauMotDePasse.trim().isEmpty()) {
            erreurs.append("Le nouveau mot de passe est requis.<br>");
        }
        
        if (confirmerMotDePasse == null || confirmerMotDePasse.trim().isEmpty()) {
            erreurs.append("La confirmation du mot de passe est requise.<br>");
        }
        
        if (erreurs.length() > 0) {
            request.setAttribute("erreurMotDePasse", erreurs.toString());
            request.getRequestDispatcher("/profil.jsp").forward(request, response);
            return;
        }
        
        // Vérifier que le nouveau mot de passe correspond à la confirmation
        if (!nouveauMotDePasse.equals(confirmerMotDePasse)) {
            request.setAttribute("erreurMotDePasse", "Les nouveaux mots de passe ne correspondent pas.");
            request.getRequestDispatcher("/profil.jsp").forward(request, response);
            return;
        }
        
        try {
            // Vérifier le mot de passe actuel
            if (!utilisateurDAO.verifierMotDePasse(utilisateurSession.getEmail(), motDePasseActuel)) {
                request.setAttribute("erreurMotDePasse", "Le mot de passe actuel est incorrect.");
                request.getRequestDispatcher("/profil.jsp").forward(request, response);
                return;
            }
            
            // Mettre à jour le mot de passe
            boolean success = utilisateurDAO.updateMotDePasse(utilisateurSession.getId(), nouveauMotDePasse);
            
            if (success) {
                request.setAttribute("successMotDePasse", "✅ Votre mot de passe a été changé avec succès !");
            } else {
                request.setAttribute("erreurMotDePasse", "❌ Une erreur est survenue lors du changement de mot de passe.");
            }
            
            request.setAttribute("utilisateur", utilisateurSession);
            request.getRequestDispatcher("/profil.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreurMotDePasse", "❌ Une erreur inattendue est survenue: " + e.getMessage());
            request.getRequestDispatcher("/profil.jsp").forward(request, response);
        }
    }
}