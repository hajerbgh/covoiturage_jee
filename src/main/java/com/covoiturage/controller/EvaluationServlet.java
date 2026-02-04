package com.covoiturage.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.covoiturage.dao.AvisDAO;
import com.covoiturage.dao.TrajetDAO;
import com.covoiturage.model.Avis;
import com.covoiturage.model.Utilisateur;

public class EvaluationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private AvisDAO avisDAO;
    private TrajetDAO trajetDAO;
    
    @Override
    public void init() throws ServletException {
        avisDAO = new AvisDAO();
        trajetDAO = new TrajetDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("connexion.jsp");
            return;
        }
        
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
        String action = request.getParameter("action");
        
        try {
            if ("evaluerPassager".equals(action)) {
                evaluerPassager(request, response, utilisateur);
            } else if ("creer".equals(action)) {
                creerEvaluation(request, response, utilisateur);
            } else {
                request.setAttribute("erreur", "Action non reconnue");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
        }
    }
 //
    private void evaluerPassager(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        try {
            // Récupérer les paramètres
            Long trajetId = Long.parseLong(request.getParameter("trajetId"));
            Long passagerId = Long.parseLong(request.getParameter("passagerId"));
            Long reservationId = Long.parseLong(request.getParameter("reservationId"));
            int note = Integer.parseInt(request.getParameter("note"));
            String commentaire = request.getParameter("commentaire");
            
            // Vérifier que l'utilisateur est bien le conducteur du trajet
            var trajet = trajetDAO.findById(trajetId);
            if (trajet == null || !trajet.getConducteurId().equals(utilisateur.getId())) {
                request.setAttribute("erreur", "Vous n'êtes pas autorisé à évaluer ce passager");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
                return;
            }
            
            // Vérifier que le conducteur n'a pas déjà évalué ce passager pour ce trajet
            if (avisDAO.aDejaEvaluePassager(trajetId, passagerId)) {
                request.setAttribute("erreur", "Vous avez déjà évalué ce passager pour ce trajet");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
                return;
            }
            
            // Créer l'avis (conducteur évalue passager)
            Avis avis = new Avis();
            avis.setNote(note);
            avis.setCommentaire(commentaire);
            avis.setDateAvis(new java.util.Date());
            avis.setEvaluateurId(utilisateur.getId()); // Le conducteur qui évalue
            avis.setEvalueId(passagerId); // Le passager évalué
            avis.setTrajetId(trajetId);
            
            boolean success = avisDAO.create(avis);
            
            if (success) {
                // Message de succès
                request.getSession().setAttribute("successMessage", 
                    "✅ Votre évaluation du passager a été enregistrée avec succès !");
                
                // Rediriger vers la page des passagers
                response.sendRedirect("passagers");
            } else {
                request.setAttribute("erreur", "❌ Erreur lors de l'enregistrement de l'évaluation");
                request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("erreur", "Format de données invalide");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("erreur", "Note invalide (doit être entre 1 et 5)");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
        }
    }
    private void creerEvaluation(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        try {
            // Récupérer les paramètres
            Long trajetId = Long.parseLong(request.getParameter("trajetId"));
            Long reservationId = Long.parseLong(request.getParameter("reservationId"));
            int note = Integer.parseInt(request.getParameter("note"));
            String commentaire = request.getParameter("commentaire");
            
            // Récupérer l'ID du conducteur depuis le trajet
            var trajet = trajetDAO.findById(trajetId);
            if (trajet == null) {
                request.setAttribute("erreur", "Trajet non trouvé");
                request.getRequestDispatcher("/historique.jsp").forward(request, response);
                return;
            }
            
            Long conducteurId = trajet.getConducteurId();
            
            // Vérifier que l'utilisateur n'a pas déjà évalué ce trajet
            if (avisDAO.aDejaEvalue(trajetId, utilisateur.getId())) {
                request.setAttribute("erreur", "Vous avez déjà évalué ce trajet");
                request.getRequestDispatcher("/historique.jsp").forward(request, response);
                return;
            }
            
            // Créer l'avis
            Avis avis = new Avis();
            avis.setNote(note);
            avis.setCommentaire(commentaire);
            avis.setDateAvis(new java.util.Date());
            avis.setEvaluateurId(utilisateur.getId()); // Le passager qui évalue
            avis.setEvalueId(conducteurId); // Le conducteur évalué
            avis.setTrajetId(trajetId);
            
            boolean success = avisDAO.create(avis);
            
            if (success) {
                // Message de succès
                request.getSession().setAttribute("successMessage", 
                    "✅ Votre évaluation a été enregistrée avec succès !");
                
                // Rediriger vers l'historique
                response.sendRedirect("historique");
            } else {
                request.setAttribute("erreur", "❌ Erreur lors de l'enregistrement de l'évaluation");
                request.getRequestDispatcher("/historique.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("erreur", "Format de données invalide");
            request.getRequestDispatcher("/historique.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("erreur", "Note invalide (doit être entre 1 et 5)");
            request.getRequestDispatcher("/historique.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Rediriger vers POST ou afficher un formulaire
        response.sendRedirect("historique");
    }
}