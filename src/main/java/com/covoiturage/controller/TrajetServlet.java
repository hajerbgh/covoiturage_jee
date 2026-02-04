package com.covoiturage.controller;

import java.io.IOException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.covoiturage.dao.TrajetDAO;
import com.covoiturage.model.Trajet;
import com.covoiturage.dao.ReservationDAO;
import com.covoiturage.model.Utilisateur;
import com.covoiturage.util.DatabaseConnection; 
import java.sql.Timestamp;
import java.sql.Types;

public class TrajetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private TrajetDAO trajetDAO;
    
    @Override
    public void init() throws ServletException {
        trajetDAO = new TrajetDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== TRAJET SERVLET DOGET ===");
        System.out.println("URL demandée: " + request.getRequestURI());
        System.out.println("Paramètre 'action': " + request.getParameter("action"));
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        
        // Vérifier si l'utilisateur est connecté
        if (session == null || session.getAttribute("utilisateur") == null) {
            response.sendRedirect("connexion.jsp");
            return;
        }
        
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
        
        if (action == null) {
            // Par défaut, afficher la liste des trajets
            afficherListeTrajets(request, response, utilisateur);
        } else {
            switch (action) {
                case "creer":
                    // Afficher le formulaire de création
                    System.out.println("Action: creer - Redirection vers creer-trajet.jsp");
                    request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
                    break;
                    
                case "details":
                    // Afficher les détails d'un trajet
                    System.out.println("Action: details");
                    afficherDetailsTrajet(request, response, utilisateur);
                    break;
                    
                case "mes-trajets":
                    // Afficher les trajets de l'utilisateur
                    System.out.println("Action: mes-trajets - Appel méthode afficherMesTrajets");
                    afficherMesTrajets(request, response, utilisateur);
                    break;
                    
                case "rechercher":
                    // Rechercher des trajets
                    System.out.println("Action: rechercher");
                    rechercherTrajets(request, response, utilisateur);
                    break;
                    
                case "modifier":
                    // Afficher le formulaire de modification
                    System.out.println("Action: modifier");
                    afficherFormulaireModification(request, response, utilisateur);
                    break;
                    
                case "annuler":
                    // Annuler un trajet
                    System.out.println("Action: annuler");
                    annulerTrajet(request, response, utilisateur);
                    break;
                    
                case "passagers":
                    // Afficher les passagers d'un trajet
                    System.out.println("Action: passagers");
                    afficherPassagers(request, response, utilisateur);
                    break;
                    
                default:
                    System.out.println("Action: null ou inconnue - Affichage liste trajets");
                    afficherListeTrajets(request, response, utilisateur);
                    break;
            }
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
        
        Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
        String action = request.getParameter("action");
        
   
        
        // Si c'est une création (pas de modification), vérifier si c'est un conducteur
        if (!"modifier".equals(action) && !"CONDUCTEUR".equals(utilisateur.getRole())) {
            request.setAttribute("erreur", "Seuls les conducteurs peuvent proposer des trajets");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        // Pour la modification, on vérifie seulement si l'utilisateur a une voiture
        // Pour la création, on vérifie aussi le rôle de conducteur
        if (!"modifier".equals(action) && !"CONDUCTEUR".equals(utilisateur.getRole())) {
            request.setAttribute("erreur", "Seuls les conducteurs peuvent créer des trajets");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        // 1. CHERCHER LA VOITURE DU CONDUCTEUR (pour création uniquement)
        Long voitureId = null;
        if (!"modifier".equals(action)) {
            try (Connection conn = DatabaseConnection.getConnection()) {
                String sqlVoiture = "SELECT id FROM voiture WHERE conducteur_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlVoiture)) {
                    pstmt.setLong(1, utilisateur.getId());
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            voitureId = rs.getLong("id");
                            System.out.println("✅ Voiture trouvée, ID: " + voitureId);
                        } else {
                            // Aucune voiture trouvée
                            request.setAttribute("erreur", "Vous devez d'abord enregistrer une voiture avant de proposer un trajet.");
                            request.getRequestDispatcher("/ajouter-voiture.jsp").forward(request, response);
                            return;
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                request.setAttribute("erreur", "Erreur lors de la recherche de votre voiture.");
                request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
                return;
            }
        }
        
        // 2. RÉCUPÉRER LES DONNÉES DU FORMULAIRE
        String depart = request.getParameter("villeDepart");
        String destination = request.getParameter("villeDestination");
        String dateDepartStr = request.getParameter("dateDepart");
        String placesStr = request.getParameter("placesDisponibles");
        String prixStr = request.getParameter("prixParPlace");
        String description = request.getParameter("description");
        String restrictions = request.getParameter("restrictions");
     
        String departLatStr = request.getParameter("departLat");
        String departLngStr = request.getParameter("departLng");
        String destinationLatStr = request.getParameter("destinationLat");
        String destinationLngStr = request.getParameter("destinationLng");
        // 3. VALIDATION DES DONNÉES
        StringBuilder erreurs = new StringBuilder();
        
        if (depart == null || depart.trim().isEmpty()) {
            erreurs.append("Le lieu de départ est requis.<br>");
        }
        
        if (destination == null || destination.trim().isEmpty()) {
            erreurs.append("La destination est requise.<br>");
        }
        
        if (dateDepartStr == null || dateDepartStr.trim().isEmpty()) {
            erreurs.append("La date de départ est requise.<br>");
        }
        
        if (placesStr == null || placesStr.trim().isEmpty()) {
            erreurs.append("Le nombre de places est requis.<br>");
        }
        
        if (prixStr == null || prixStr.trim().isEmpty()) {
            erreurs.append("Le prix par place est requis.<br>");
        }
        
        if (erreurs.length() > 0) {
            request.setAttribute("erreur", erreurs.toString());
            if ("modifier".equals(action)) {
                request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
            }
            return;
        }
        
        try {
            // 4. PARSER LES DONNÉES
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date dateDepart = sdf.parse(dateDepartStr);
            Double departLat = null;
            Double departLng = null;
            Double destinationLat = null;
            Double destinationLng = null;
            int placesDisponibles = Integer.parseInt(placesStr);
            double prix = Double.parseDouble(prixStr);
            
            // Vérifier la date (au moins 1 heure dans le futur)
            Date maintenant = new Date();
            Date uneHeurePlusTard = new Date(maintenant.getTime() + (60 * 60 * 1000));
            if (departLatStr != null && !departLatStr.isEmpty() && 
                    departLngStr != null && !departLngStr.isEmpty()) {
                    departLat = Double.parseDouble(departLatStr);
                    departLng = Double.parseDouble(departLngStr);
                }
                
                if (destinationLatStr != null && !destinationLatStr.isEmpty() && 
                    destinationLngStr != null && !destinationLngStr.isEmpty()) {
                    destinationLat = Double.parseDouble(destinationLatStr);
                    destinationLng = Double.parseDouble(destinationLngStr);
                }
            if (dateDepart.before(uneHeurePlusTard)) {
                request.setAttribute("erreur", "La date de départ doit être au moins 1 heure dans le futur.");
                if ("modifier".equals(action)) {
                    request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
                }
                return;
            }
            
            // Vérifier les valeurs
            if (placesDisponibles < 1 || placesDisponibles > 8) {
                request.setAttribute("erreur", "Le nombre de places doit être entre 1 et 8.");
                if ("modifier".equals(action)) {
                    request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
                }
                return;
            }
            
            if (prix < 0) {
                request.setAttribute("erreur", "Le prix ne peut pas être négatif.");
                if ("modifier".equals(action)) {
                    request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
                }
                return;
            }
            
            // 5. TRAITEMENT SELON L'ACTION
            if ("modifier".equals(action)) {
                // MODIFICATION D'UN TRAJET
                String trajetIdStr = request.getParameter("id");
                if (trajetIdStr == null || trajetIdStr.trim().isEmpty()) {
                    request.setAttribute("erreur", "ID de trajet manquant pour la modification.");
                    request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
                    return;
                }
                
                Long trajetId = Long.parseLong(trajetIdStr);
                
                // Vérifier que l'utilisateur est bien le conducteur du trajet
                Trajet trajetExist = trajetDAO.findById(trajetId);
                if (trajetExist == null) {
                    request.setAttribute("erreur", "Trajet non trouvé.");
                    request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
                    return;
                }
                
                if (!trajetExist.getConducteurId().equals(utilisateur.getId())) {
                    request.setAttribute("erreur", "Vous n'êtes pas autorisé à modifier ce trajet.");
                    request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
                    return;
                }
                
                
                // Mettre à jour le trajet dans la base de données
                boolean success = updateTrajetEnBase(trajetId, depart.trim(), destination.trim(), 
                        dateDepart, prix, placesDisponibles, 
                        description != null ? description.trim() : "", 
                        restrictions != null ? restrictions.trim() : "",
                        departLat, departLng,
                        destinationLat, destinationLng);
                
                if (success) {
                    // Stocker le message de succès dans la session
                    session.setAttribute("successMessage", "✅ Le trajet a été modifié avec succès !");
                    // Rediriger vers la page de détails
                    response.sendRedirect("trajets?action=details&id=" + trajetId);
                } else {
                    request.setAttribute("erreur", "❌ Une erreur est survenue lors de la modification du trajet.");
                    // Récupérer à nouveau le trajet pour l'afficher dans le formulaire
                    Trajet trajet = trajetDAO.findById(trajetId);
                    request.setAttribute("trajet", trajet);
                    request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
                }
                
            } else {
                // CRÉATION D'UN NOUVEAU TRAJET
                // 6. CRÉER L'OBJET TRAJET
            	
            	Trajet trajet = new Trajet();
            	trajet.setDepart(depart.trim());
            	trajet.setDestination(destination.trim());
            	trajet.setDateDepart(dateDepart);
            	trajet.setPrix(prix);
            	trajet.setPlacesDisponibles(placesDisponibles);
            	trajet.setDescription(description != null ? description.trim() : "");
            	trajet.setRestrictions(restrictions != null ? restrictions.trim() : "");
            	trajet.setStatut("ACTIF");
            	trajet.setConducteurId(utilisateur.getId());
            	trajet.setVoitureId(voitureId); 
            	// Ajouter les coordonnées si disponibles
            	if (departLatStr != null && !departLatStr.isEmpty() && 
            	    departLngStr != null && !departLngStr.isEmpty()) {
            	    trajet.setDepartLat(Double.parseDouble(departLatStr));
            	    trajet.setDepartLng(Double.parseDouble(departLngStr));
            	}

            	if (destinationLatStr != null && !destinationLatStr.isEmpty() && 
            	    destinationLngStr != null && !destinationLngStr.isEmpty()) {
            	    trajet.setDestinationLat(Double.parseDouble(destinationLatStr));
            	    trajet.setDestinationLng(Double.parseDouble(destinationLngStr));
            	} // Utiliser l'ID trouvé plus tôt
                
                // 7. SAUVEGARDER DANS LA BASE DE DONNÉES
                boolean success = trajetDAO.create(trajet);
                
                if (success) {
                    // Stocker le message de succès dans la session
                    session.setAttribute("successMessage", "✅ Votre trajet a été créé avec succès !");
                    // Rediriger vers la liste des trajets
                    response.sendRedirect("trajets?action=mes-trajets");
                } else {
                    request.setAttribute("erreur", "❌ Une erreur est survenue lors de la création du trajet.");
                    request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
                }
            }
            
        } catch (ParseException e) {
            request.setAttribute("erreur", "❌ Format de date invalide.");
            if ("modifier".equals(action)) {
                String trajetIdStr = request.getParameter("id");
                if (trajetIdStr != null) {
                    try {
                        Trajet trajet = trajetDAO.findById(Long.parseLong(trajetIdStr));
                        request.setAttribute("trajet", trajet);
                    } catch (Exception ex) {
                        // Ignorer si on ne peut pas récupérer le trajet
                    }
                }
                request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("erreur", "❌ Format de nombre invalide pour les places ou le prix.");
            if ("modifier".equals(action)) {
                String trajetIdStr = request.getParameter("id");
                if (trajetIdStr != null) {
                    try {
                        Trajet trajet = trajetDAO.findById(Long.parseLong(trajetIdStr));
                        request.setAttribute("trajet", trajet);
                    } catch (Exception ex) {
                        // Ignorer si on ne peut pas récupérer le trajet
                    }
                }
                request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "❌ Une erreur inattendue est survenue: " + e.getMessage());
            if ("modifier".equals(action)) {
                String trajetIdStr = request.getParameter("id");
                if (trajetIdStr != null) {
                    try {
                        Trajet trajet = trajetDAO.findById(Long.parseLong(trajetIdStr));
                        request.setAttribute("trajet", trajet);
                    } catch (Exception ex) {
                        // Ignorer si on ne peut pas récupérer le trajet
                    }
                }
                request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/creer-trajet.jsp").forward(request, response);
            }
        }
    }
    
    // ============================================================
    // MÉTHODES PRIVÉES POUR LES DIFFÉRENTES ACTIONS
    // ============================================================
    
    // Méthode pour afficher la liste de tous les trajets
    private void afficherListeTrajets(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        try {
            java.util.List<Trajet> trajets = trajetDAO.search(null, null, null, null);
            request.setAttribute("trajets", trajets);
            request.getRequestDispatcher("/liste-trajets.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur lors du chargement des trajets.");
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
        }
    }
    
    // Méthode pour afficher les détails d'un trajet
    private void afficherDetailsTrajet(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String trajetIdStr = request.getParameter("id");
        
        if (trajetIdStr == null || trajetIdStr.trim().isEmpty()) {
            request.setAttribute("erreur", "ID de trajet manquant.");
            request.getRequestDispatcher("/liste-trajets.jsp").forward(request, response);
            return;
        }
        
        try {
            Long trajetId = Long.parseLong(trajetIdStr);
            Trajet trajet = trajetDAO.findById(trajetId);
            
            if (trajet == null) {
                request.setAttribute("erreur", "Trajet non trouvé.");
                request.getRequestDispatcher("/liste-trajets.jsp").forward(request, response);
                return;
            }
            
            // Vérifier s'il y a un message de succès dans la session
            HttpSession session = request.getSession(false);
            if (session != null) {
                String successMessage = (String) session.getAttribute("successMessage");
                if (successMessage != null) {
                    request.setAttribute("successMessage", successMessage);
                    session.removeAttribute("successMessage"); // Nettoyer après utilisation
                }
            }
            
            request.setAttribute("trajet", trajet);
            request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("erreur", "ID de trajet invalide.");
            request.getRequestDispatcher("/liste-trajets.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur lors du chargement du trajet.");
            request.getRequestDispatcher("/liste-trajets.jsp").forward(request, response);
        }
    }
    
    
 // Méthode pour afficher les trajets d'un conducteur
    private void afficherMesTrajets(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        System.out.println("=== DÉBUT afficherMesTrajets ===");
        
        // Vérifier si l'utilisateur est conducteur
        if (!"CONDUCTEUR".equals(utilisateur.getRole())) {
            System.out.println("ERREUR: Utilisateur n'est pas conducteur!");
            request.setAttribute("erreur", "Cette fonctionnalité est réservée aux conducteurs.");
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
            return;
        }
        
        try {
            java.util.List<Trajet> trajets = trajetDAO.findByConducteur(utilisateur.getId());
            
            System.out.println(" DAO appelé avec succès");
            System.out.println("Nombre de trajets récupérés par DAO: " + trajets.size());
            
            // AJOUTEZ CE CODE POUR CALCULER LE NOMBRE TOTAL DE PASSAGERS
            int totalPassagers = 0;
            try {
            	ReservationDAO reservationDAO = new ReservationDAO();
                totalPassagers = reservationDAO.countTotalPassagersByConducteur(utilisateur.getId());
                System.out.println("✅ Nombre total de passagers: " + totalPassagers);
            } catch (Exception e) {
                System.err.println("❌ Erreur lors du calcul des passagers: " + e.getMessage());
                e.printStackTrace();
                // Continuer même en cas d'erreur, la valeur restera à 0
            }
            
            // Stocker dans la requête
            request.setAttribute("trajets", trajets);
            request.setAttribute("totalPassagers", totalPassagers); // AJOUTEZ CET ATTRIBUT
            
            System.out.println("✅ Redirection vers /mes-trajets.jsp");
            System.out.println("=== FIN afficherMesTrajets ===");
            
            request.getRequestDispatcher("/mes-trajets.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("❌ ERREUR dans afficherMesTrajets:");
            e.printStackTrace();
            request.setAttribute("erreur", 
                "Erreur lors du chargement de vos trajets: " + 
                e.getClass().getSimpleName() + " - " + e.getMessage());
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
        }
    }
    
    // Méthode pour rechercher des trajets
    private void rechercherTrajets(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String depart = request.getParameter("depart");
        String destination = request.getParameter("destination");
        String dateStr = request.getParameter("date");
        String prixMaxStr = request.getParameter("prixMax");
        
        try {
            Double prixMax = null;
            if (prixMaxStr != null && !prixMaxStr.trim().isEmpty()) {
                prixMax = Double.parseDouble(prixMaxStr);
            }
            
            java.util.List<Trajet> trajets = trajetDAO.search(depart, destination, dateStr, prixMax);
            request.setAttribute("trajets", trajets);
            request.setAttribute("criteres", request.getParameterMap());
            request.getRequestDispatcher("/rechercher-trajet.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("erreur", "Format de prix invalide.");
            request.getRequestDispatcher("/rechercher-trajet.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur lors de la recherche.");
            request.getRequestDispatcher("/rechercher-trajet.jsp").forward(request, response);
        }
    }
    
    // Méthode pour afficher le formulaire de modification
    private void afficherFormulaireModification(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String trajetIdStr = request.getParameter("id");
        
        if (trajetIdStr == null || trajetIdStr.trim().isEmpty()) {
            request.setAttribute("erreur", "ID de trajet manquant.");
            request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
            return;
        }
        
        try {
            Long trajetId = Long.parseLong(trajetIdStr);
            Trajet trajet = trajetDAO.findById(trajetId);
            
            if (trajet == null) {
                request.setAttribute("erreur", "Trajet non trouvé.");
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            // Vérifier que l'utilisateur est bien le conducteur
            if (!trajet.getConducteurId().equals(utilisateur.getId())) {
                request.setAttribute("erreur", "Vous n'êtes pas autorisé à modifier ce trajet.");
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            // Vérifier que le trajet peut être modifié
            if (!"ACTIF".equals(trajet.getStatut())) {
                request.setAttribute("erreur", "Seuls les trajets actifs peuvent être modifiés.");
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            request.setAttribute("trajet", trajet);
            request.getRequestDispatcher("/modifier-trajet.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("erreur", "ID de trajet invalide.");
            request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
        }
    }
    
    // Méthode pour annuler un trajet
    private void annulerTrajet(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String trajetIdStr = request.getParameter("id");
        
        if (trajetIdStr == null || trajetIdStr.trim().isEmpty()) {
            request.setAttribute("erreur", "ID de trajet manquant.");
            request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
            return;
        }
        
        try {
            Long trajetId = Long.parseLong(trajetIdStr);
            Trajet trajet = trajetDAO.findById(trajetId);
            
            if (trajet == null) {
                request.setAttribute("erreur", "Trajet non trouvé.");
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            // Vérifier que l'utilisateur est bien le conducteur
            if (!trajet.getConducteurId().equals(utilisateur.getId())) {
                request.setAttribute("erreur", "Vous n'êtes pas autorisé à annuler ce trajet.");
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            // Vérifier que le trajet peut être annulé
            if ("ANNULE".equals(trajet.getStatut())) {
                request.setAttribute("erreur", "Ce trajet est déjà annulé.");
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            if ("TERMINE".equals(trajet.getStatut())) {
                request.setAttribute("erreur", "Impossible d'annuler un trajet terminé.");
                request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
                return;
            }
            
            // Annuler le trajet dans la base de données
            boolean success = annulerTrajetEnBase(trajetId);
            
            if (success) {
                request.setAttribute("success", "✅ Le trajet a été annulé avec succès.");
                // Rafraîchir les données du trajet
                trajet = trajetDAO.findById(trajetId);
                request.setAttribute("trajet", trajet);
            } else {
                request.setAttribute("erreur", "❌ Une erreur est survenue lors de l'annulation du trajet.");
            }
            
            request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("erreur", "ID de trajet invalide.");
            request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/details-trajet.jsp").forward(request, response);
        }
    }
    
    
    
    
    
    
    
    // Méthode pour afficher les passagers d'un trajet (stub - à implémenter)
    private void afficherPassagers(HttpServletRequest request, HttpServletResponse response, Utilisateur utilisateur) 
            throws ServletException, IOException {
        
        String trajetIdStr = request.getParameter("id");
        
        if (trajetIdStr == null || trajetIdStr.trim().isEmpty()) {
            request.setAttribute("erreur", "ID de trajet manquant.");
            request.getRequestDispatcher("/mes-trajets.jsp").forward(request, response);
            return;
        }
        
        try {
            Long trajetId = Long.parseLong(trajetIdStr);
            Trajet trajet = trajetDAO.findById(trajetId);
            
            if (trajet == null) {
                request.setAttribute("erreur", "Trajet non trouvé.");
                request.getRequestDispatcher("/mes-trajets.jsp").forward(request, response);
                return;
            }
            
            // Vérifier que l'utilisateur est bien le conducteur
            if (!trajet.getConducteurId().equals(utilisateur.getId())) {
                request.setAttribute("erreur", "Accès non autorisé.");
                request.getRequestDispatcher("/mes-trajets.jsp").forward(request, response);
                return;
            }
            
            // Ici, vous devrez récupérer les réservations/passagers de la base
            // Pour l'instant, on affiche juste un message
            request.setAttribute("trajet", trajet);
            request.setAttribute("message", "Fonctionnalité des passagers à implémenter.");
            request.getRequestDispatcher("/mes-passagers.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erreur", "Erreur: " + e.getMessage());
            request.getRequestDispatcher("/mes-trajets.jsp").forward(request, response);
        }
    }
    
    // ============================================================
    // MÉTHODES D'AIDE POUR LES OPÉRATIONS BASE DE DONNÉES
    // ============================================================
    
    // Méthode pour annuler un trajet en base de données
    private boolean annulerTrajetEnBase(Long trajetId) {
        String sql = "UPDATE trajet SET statut = 'ANNULE' WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, trajetId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur annulation trajet: " + e.getMessage());
            return false;
        }
    }
    
    
    
    
    
    
    
    
    // Méthode pour mettre à jour un trajet en base de données
 // Méthode pour mettre à jour un trajet en base de données avec coordonnées
    private boolean updateTrajetEnBase(Long trajetId, String depart, String destination, 
                                      Date dateDepart, double prix, int placesDisponibles,
                                      String description, String restrictions,
                                      Double departLat, Double departLng,
                                      Double destinationLat, Double destinationLng) {
        String sql = "UPDATE trajet SET depart = ?, destination = ?, date_depart = ?, " +
                     "prix = ?, places_disponibles = ?, description = ?, restrictions = ?, " +
                     "depart_lat = ?, depart_lng = ?, destination_lat = ?, destination_lng = ? " +
                     "WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, depart);
            pstmt.setString(2, destination);
            pstmt.setTimestamp(3, new Timestamp(dateDepart.getTime()));
            pstmt.setDouble(4, prix);
            pstmt.setInt(5, placesDisponibles);
            pstmt.setString(6, description);
            pstmt.setString(7, restrictions);
            
            // Ajouter les coordonnées
            if (departLat != null && departLng != null) {
                pstmt.setDouble(8, departLat);
                pstmt.setDouble(9, departLng);
            } else {
                pstmt.setNull(8, Types.DOUBLE);
                pstmt.setNull(9, Types.DOUBLE);
            }
            
            if (destinationLat != null && destinationLng != null) {
                pstmt.setDouble(10, destinationLat);
                pstmt.setDouble(11, destinationLng);
            } else {
                pstmt.setNull(10, Types.DOUBLE);
                pstmt.setNull(11, Types.DOUBLE);
            }
            
            pstmt.setLong(12, trajetId);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur modification trajet: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}