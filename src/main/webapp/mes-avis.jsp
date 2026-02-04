<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="com.covoiturage.model.Avis" %>
<%@ page import="com.covoiturage.dao.AvisDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Vérifier si l'utilisateur est connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    AvisDAO avisDAO = new AvisDAO();
    List<Avis> avisRecus = avisDAO.findByEvalueId(utilisateur.getId());
    double noteMoyenne = avisDAO.getNoteMoyenne(utilisateur.getId());
    int totalAvis = avisRecus.size();
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes Avis Reçus - Covoiturage</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: #f5f7fa;
            color: #333;
        }
        
        .header {
            background: white;
            padding: 20px 40px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .logo {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .logo i {
            font-size: 2.5rem;
            color: #4a6cf7;
        }
        
        .logo h1 {
            color: #2d3748;
            font-size: 1.8rem;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto 40px;
            padding: 0 20px;
        }
        
        .page-header {
            background: white;
            border-radius: 12px;
            padding: 25px 30px;
            margin-bottom: 25px;
            box-shadow: 0 3px 15px rgba(0,0,0,0.05);
        }
        
        .page-header h2 {
            color: #2d3748;
            font-size: 1.8rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .stats-summary {
            display: flex;
            gap: 30px;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        
        .stat-box {
            background: #f7fafc;
            border-radius: 10px;
            padding: 20px;
            min-width: 200px;
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: #2d3748;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #718096;
            font-size: 0.9rem;
        }
        
        .rating-display {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 10px;
        }
        
        .stars {
            display: flex;
            gap: 3px;
        }
        
        .star {
            color: #cbd5e0;
            font-size: 1.2rem;
        }
        
        .star.filled {
            color: #f6ad55;
        }
        
        .btn {
            padding: 10px 20px;
            background: #4a6cf7;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 500;
            transition: background 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn:hover {
            background: #3a5bd9;
        }
        
        .btn-secondary {
            background: #718096;
        }
        
        .btn-secondary:hover {
            background: #5a6c82;
        }
        
        /* Avis Cards */
        .avis-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
            margin-top: 20px;
        }
        
        .avis-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 3px 15px rgba(0,0,0,0.05);
        }
        
        .avis-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }
        
        .evaluateur-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .evaluateur-avatar {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, #4a6cf7, #8a63d2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }
        
        .evaluateur-details h4 {
            color: #2d3748;
            margin-bottom: 3px;
        }
        
        .evaluateur-details p {
            color: #718096;
            font-size: 0.85rem;
        }
        
        .avis-note {
            font-size: 1.8rem;
            font-weight: bold;
            color: #f6ad55;
        }
        
        .avis-commentaire {
            margin-top: 15px;
            padding: 15px;
            background: #f7fafc;
            border-radius: 8px;
            color: #4a5568;
            line-height: 1.5;
        }
        
        .avis-metadata {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            color: #718096;
            font-size: 0.85rem;
        }
        
        .trajet-info {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #718096;
        }
        
        .empty-state i {
            font-size: 4rem;
            margin-bottom: 20px;
            color: #cbd5e0;
        }
        
        @media (max-width: 768px) {
            .header {
                padding: 15px 20px;
                flex-direction: column;
                gap: 20px;
            }
            
            .avis-grid {
                grid-template-columns: 1fr;
            }
            
            .stats-summary {
                flex-direction: column;
            }
            
            .stat-box {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="logo">
            <i class="fas fa-star"></i>
            <h1>Mes Avis Reçus</h1>
        </div>
        <div>
            <a href="dashboard" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Retour au dashboard
            </a>
        </div>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h2>
                <i class="fas fa-comments"></i>
                Tous les avis reçus
            </h2>
            
            <!-- Statistiques -->
            <div class="stats-summary">
                <div class="stat-box">
                    <div class="stat-value"><%= totalAvis %></div>
                    <div class="stat-label">Avis totaux</div>
                </div>
                
                <div class="stat-box">
                    <div class="stat-value">
                        <% if (noteMoyenne > 0) { %>
                            <%= String.format("%.1f", noteMoyenne) %>
                        <% } else { %>
                            0.0
                        <% } %>
                    </div>
                    <div class="stat-label">Note moyenne</div>
                    <div class="rating-display">
                        <div class="stars">
                            <% 
                                int fullStars = (int) Math.floor(noteMoyenne);
                                for (int i = 1; i <= 5; i++) { 
                            %>
                                <span class="star <%= i <= fullStars ? "filled" : "" %>">
                                    <i class="fas fa-star"></i>
                                </span>
                            <% } %>
                        </div>
                        <span>(<%= String.format("%.1f", noteMoyenne) %>)</span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Liste des avis -->
        <% if (avisRecus != null && !avisRecus.isEmpty()) { %>
            <div class="avis-grid">
                <% for (Avis avis : avisRecus) { %>
                    <div class="avis-card">
                        <div class="avis-header">
                            <div class="evaluateur-info">
                                <div class="evaluateur-avatar">
                                    <%= "U" %>
                                </div>
                                <div class="evaluateur-details">
                                    <h4>
    <% 
        String nomComplet = "";
        if (avis.getEvaluateurPrenom() != null) {
            nomComplet += avis.getEvaluateurPrenom();
        }
        if (avis.getEvaluateurNom() != null) {
            if (!nomComplet.isEmpty()) nomComplet += " ";
            nomComplet += avis.getEvaluateurNom();
        }
        out.print(nomComplet.isEmpty() ? "Utilisateur " + avis.getEvaluateurId() : nomComplet);
    %>
</h4>
                                    <p><i class="fas fa-user"></i> Évaluateur</p>
                                </div>
                            </div>
                            <div class="avis-note">
                                <%= avis.getNote() %>/5
                            </div>
                        </div>
                        
                        <% if (avis.getCommentaire() != null && !avis.getCommentaire().isEmpty()) { %>
                            <div class="avis-commentaire">
                                <i class="fas fa-quote-left" style="color: #cbd5e0; margin-right: 5px;"></i>
                                <%= avis.getCommentaire() %>
                            </div>
                        <% } else { %>
                            <div class="avis-commentaire" style="color: #a0aec0; font-style: italic;">
                                Aucun commentaire
                            </div>
                        <% } %>
                        
                        <div class="avis-metadata">
                            <div class="trajet-info">
                                <i class="fas fa-road"></i>
                                <span>Trajet #<%= avis.getTrajetId() %></span>
                            </div>
                            <div>
                                <i class="far fa-clock"></i>
                                <%= sdf.format(avis.getDateAvis()) %>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <i class="fas fa-comments"></i>
                <h3>Aucun avis reçu</h3>
                <p>Vous n'avez pas encore reçu d'évaluation de la part d'autres utilisateurs.</p>
                <a href="dashboard" class="btn" style="margin-top: 15px;">
                    <i class="fas fa-arrow-left"></i> Retour au dashboard
                </a>
            </div>
        <% } %>
    </div>
    
    <script>
        // Fonction pour afficher les étoiles dynamiquement
        function renderStars(rating, elementId) {
            const starsContainer = document.getElementById(elementId);
            starsContainer.innerHTML = '';
            
            for (let i = 1; i <= 5; i++) {
                const star = document.createElement('span');
                star.className = i <= rating ? 'star filled' : 'star';
                star.innerHTML = '<i class="fas fa-star"></i>';
                starsContainer.appendChild(star);
            }
        }
        
        // Initialiser les étoiles pour chaque avis
        document.addEventListener('DOMContentLoaded', function() {
            // Vous pouvez ajouter du JavaScript supplémentaire ici si besoin
            console.log('Page des avis chargée');
        });
    </script>
</body>
</html>