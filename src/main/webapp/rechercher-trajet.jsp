<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Trajet" %>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Vérifier si l'utilisateur est connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    List<Trajet> trajets = (List<Trajet>) request.getAttribute("trajets");
    Map<String, String[]> criteres = (Map<String, String[]>) request.getAttribute("criteres");
    String erreur = (String) request.getAttribute("erreur");
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    
    // Récupérer les valeurs des critères pour pré-remplir le formulaire
    String departValue = "";
    String destinationValue = "";
    String dateValue = "";
    String prixMaxValue = "";
    
    if (criteres != null) {
        if (criteres.containsKey("depart") && criteres.get("depart") != null && criteres.get("depart").length > 0) {
            departValue = criteres.get("depart")[0];
        }
        if (criteres.containsKey("destination") && criteres.get("destination") != null && criteres.get("destination").length > 0) {
            destinationValue = criteres.get("destination")[0];
        }
        if (criteres.containsKey("date") && criteres.get("date") != null && criteres.get("date").length > 0) {
            dateValue = criteres.get("date")[0];
        }
        if (criteres.containsKey("prixMax") && criteres.get("prixMax") != null && criteres.get("prixMax").length > 0) {
            prixMaxValue = criteres.get("prixMax")[0];
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rechercher un trajet - Covoiturage</title>
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
        
        .nav-links {
            display: flex;
            gap: 20px;
        }
        
        .nav-links a {
            color: #4a5568;
            text-decoration: none;
            padding: 8px 15px;
            border-radius: 6px;
            transition: background 0.3s;
        }
        
        .nav-links a:hover {
            background: #edf2f7;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto 40px;
            padding: 0 20px;
        }
        
        .page-header {
            margin-bottom: 30px;
        }
        
        .page-header h2 {
            color: #2d3748;
            font-size: 2rem;
            margin-bottom: 10px;
        }
        
        .page-header p {
            color: #718096;
        }
        
        /* Formulaire de recherche amélioré */
        .search-container {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }
        
        .search-form {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            align-items: end;
        }
        
        .form-group {
            margin-bottom: 0;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #4a5568;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #4a6cf7;
        }
        
        .btn {
            padding: 14px 25px;
            background: #4a6cf7;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: background 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
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
        
        /* Résultats */
        .results-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .results-count {
            color: #4a5568;
            font-size: 1rem;
        }
        
        .trajets-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
        }
        
        .trajet-card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            transition: transform 0.3s;
        }
        
        .trajet-card:hover {
            transform: translateY(-5px);
        }
        
        .card-header {
            background: linear-gradient(135deg, #4a6cf7, #8a63d2);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .card-price {
            font-size: 1.5rem;
            font-weight: bold;
        }
        
        .card-body {
            padding: 20px;
        }
        
        .trajet-route {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 15px;
        }
        
        .route-dots {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 5px;
        }
        
        .dot {
            width: 8px;
            height: 8px;
            background: #4a6cf7;
            border-radius: 50%;
        }
        
        .dot.start {
            background: #48bb78;
        }
        
        .dot.end {
            background: #f56565;
        }
        
        .route-line {
            width: 2px;
            height: 30px;
            background: #cbd5e0;
        }
        
        .route-info {
            flex: 1;
        }
        
        .route-depart, .route-arrivee {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 5px;
        }
        
        .trajet-details {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-top: 15px;
        }
        
        .detail-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #718096;
            font-size: 0.9rem;
        }
        
        .card-footer {
            padding: 15px 20px;
            background: #f7fafc;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .places-badge {
            background: #48bb78;
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.9rem;
        }
        
        .btn-details {
            padding: 8px 20px;
            background: #4a6cf7;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            font-size: 0.9rem;
        }
        
        /* États vides */
        .empty-state {
            text-align: center;
            padding: 50px 20px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }
        
        .empty-state i {
            font-size: 4rem;
            margin-bottom: 20px;
            color: #cbd5e0;
        }
        
        .empty-state h3 {
            color: #2d3748;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: #718096;
            margin-bottom: 30px;
        }
        
        /* Filtres actifs */
        .active-filters {
            background: #ebf8ff;
            border-left: 4px solid #4299e1;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .filters-title {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 15px;
            color: #2d3748;
        }
        
        .filters-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .filter-tag {
            background: #bee3f8;
            color: #2c5282;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .filter-tag a {
            color: inherit;
            text-decoration: none;
        }
        
        @media (max-width: 1024px) {
            .search-form {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        @media (max-width: 768px) {
            .header {
                padding: 15px 20px;
                flex-direction: column;
                gap: 20px;
            }
            
            .search-form {
                grid-template-columns: 1fr;
            }
            
            .trajets-grid {
                grid-template-columns: 1fr;
            }
            
            .results-header {
                flex-direction: column;
                gap: 15px;
                align-items: stretch;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="logo">
            <i class="fas fa-car"></i>
            <h1>Covoiturage App</h1>
        </div>
        
        <nav class="nav-links">
            <a href="dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="trajets">
                <i class="fas fa-road"></i> Tous les trajets
            </a>
            <% if ("CONDUCTEUR".equals(utilisateur.getRole())) { %>
                <a href="trajets?action=creer">
                    <i class="fas fa-plus-circle"></i> Proposer trajet
                </a>
            <% } %>
            <a href="deconnexion">
                <i class="fas fa-sign-out-alt"></i> Déconnexion
            </a>
        </nav>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <div class="page-header">
            <h2><i class="fas fa-search"></i> Rechercher un trajet</h2>
            <p>Trouvez le trajet parfait selon vos critères</p>
        </div>
        
        <!-- Formulaire de recherche -->
        <div class="search-container">
            <form action="trajets" method="get" class="search-form">
                <input type="hidden" name="action" value="rechercher">
                
                <div class="form-group">
                    <label><i class="fas fa-map-marker-alt"></i> Départ</label>
                    <input type="text" name="depart" class="form-control" 
                           placeholder="Ville de départ" value="<%= departValue %>">
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-flag-checkered"></i> Destination</label>
                    <input type="text" name="destination" class="form-control" 
                           placeholder="Ville d'arrivée" value="<%= destinationValue %>">
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-calendar-alt"></i> Date de départ</label>
                    <input type="date" name="date" class="form-control" value="<%= dateValue %>">
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-tag"></i> Prix max (DT)</label>
                    <input type="number" name="prixMax" class="form-control" 
                           placeholder="Prix maximum" step="0.5" value="<%= prixMaxValue %>">
                </div>
                
                <button type="submit" class="btn">
                    <i class="fas fa-search"></i> Rechercher
                </button>
                
                <a href="trajets?action=rechercher" class="btn btn-secondary">
                    <i class="fas fa-times"></i> Effacer
                </a>
            </form>
        </div>
        
        <!-- Filtres actifs -->
        <% if ((departValue != null && !departValue.isEmpty()) || 
               (destinationValue != null && !destinationValue.isEmpty()) || 
               (dateValue != null && !dateValue.isEmpty()) || 
               (prixMaxValue != null && !prixMaxValue.isEmpty())) { %>
        <div class="active-filters">
            <div class="filters-title">
                <i class="fas fa-filter"></i>
                <h3>Filtres actifs</h3>
            </div>
            <div class="filters-list">
                <% if (departValue != null && !departValue.isEmpty()) { %>
                <span class="filter-tag">
                    Départ: <%= departValue %>
                    <a href="?action=rechercher&destination=<%= destinationValue %>&date=<%= dateValue %>&prixMax=<%= prixMaxValue %>">
                        <i class="fas fa-times"></i>
                    </a>
                </span>
                <% } %>
                
                <% if (destinationValue != null && !destinationValue.isEmpty()) { %>
                <span class="filter-tag">
                    Destination: <%= destinationValue %>
                    <a href="?action=rechercher&depart=<%= departValue %>&date=<%= dateValue %>&prixMax=<%= prixMaxValue %>">
                        <i class="fas fa-times"></i>
                    </a>
                </span>
                <% } %>
                
                <% if (dateValue != null && !dateValue.isEmpty()) { %>
                <span class="filter-tag">
                    Date: <%= dateValue %>
                    <a href="?action=rechercher&depart=<%= departValue %>&destination=<%= destinationValue %>&prixMax=<%= prixMaxValue %>">
                        <i class="fas fa-times"></i>
                    </a>
                </span>
                <% } %>
                
                <% if (prixMaxValue != null && !prixMaxValue.isEmpty()) { %>
                <span class="filter-tag">
                    Prix max: <%= prixMaxValue %> DT
                    <a href="?action=rechercher&depart=<%= departValue %>&destination=<%= destinationValue %>&date=<%= dateValue %>">
                        <i class="fas fa-times"></i>
                    </a>
                </span>
                <% } %>
            </div>
        </div>
        <% } %>
        
        <!-- Résultats CORRIGÉ -->
        <% if (erreur != null && !erreur.isEmpty()) { %>
            <div style="background: #fed7d7; color: #9b2c2c; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                <i class="fas fa-exclamation-triangle"></i> <%= erreur %>
            </div>
        <% } %>
        
        <% if (trajets != null && !trajets.isEmpty()) { %>
            <div class="results-header">
                <h3><i class="fas fa-route"></i> Trajets trouvés</h3>
                <div class="results-count">
                    <%= trajets.size() %> trajet(s) correspondant à votre recherche
                </div>
            </div>
            
            <div class="trajets-grid">
                <% for (Trajet trajet : trajets) { %>
                    <div class="trajet-card">
                        <div class="card-header">
                            <div>
                                <h4><i class="fas fa-car"></i> Conducteur #<%= trajet.getConducteurId() %></h4>
                                <p style="font-size: 0.9rem; opacity: 0.9; margin-top: 5px;">
                                    <i class="fas fa-star" style="color: #ffd700;"></i> 4.5/5
                                </p>
                            </div>
                            <div class="card-price">
                                <%= String.format("%.2f", trajet.getPrix()) %> DT
                            </div>
                        </div>
                        
                        <div class="card-body">
                            <div class="trajet-route">
                                <div class="route-dots">
                                    <div class="dot start"></div>
                                    <div class="route-line"></div>
                                    <div class="dot end"></div>
                                </div>
                                <div class="route-info">
                                    <div class="route-depart">
                                        <i class="fas fa-map-marker-alt" style="color: #48bb78;"></i>
                                        <strong><%= trajet.getDepart() %></strong>
                                    </div>
                                    <div class="route-arrivee">
                                        <i class="fas fa-flag-checkered" style="color: #f56565;"></i>
                                        <strong><%= trajet.getDestination() %></strong>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="trajet-details">
                                <div class="detail-item">
                                    <i class="fas fa-calendar-alt"></i>
                                    <span>Départ: <%= sdf.format(trajet.getDateDepart()) %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-clock"></i>
                                    <span>Durée: -- min</span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-road"></i>
                                    <span>Distance: -- km</span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-car-side"></i>
                                    <span>Voiture: #<%= trajet.getVoitureId() %></span>
                                </div>
                            </div>
                            
                            <% if (trajet.getDescription() != null && !trajet.getDescription().isEmpty()) { %>
                            <div style="margin-top: 15px; padding-top: 15px; border-top: 1px solid #e2e8f0;">
                                <p style="font-size: 0.9rem; color: #718096;">
                                    <i class="fas fa-info-circle"></i> <%= trajet.getDescription() %>
                                </p>
                            </div>
                            <% } %>
                            
                            <% if (trajet.getRestrictions() != null && !trajet.getRestrictions().isEmpty()) { %>
                            <div style="margin-top: 10px;">
                                <p style="font-size: 0.85rem; color: #f56565;">
                                    <i class="fas fa-exclamation-triangle"></i> Restrictions: <%= trajet.getRestrictions() %>
                                </p>
                            </div>
                            <% } %>
                        </div>
                        
                        <div class="card-footer">
                            <div class="places-badge">
                                <i class="fas fa-users"></i> <%= trajet.getPlacesDisponibles() %> places
                            </div>
                            <div>
                                <span style="background: #edf2f7; color: #4a5568; padding: 5px 12px; border-radius: 20px; font-size: 0.9rem; margin-right: 10px;">
                                    <i class="fas fa-<%= "ACTIF".equals(trajet.getStatut()) ? "check-circle" : "times-circle" %>"></i> 
                                    <%= trajet.getStatut() %>
                                </span>
                                <a href="trajets?action=details&id=<%= trajet.getId() %>" class="btn-details">
                                    <i class="fas fa-eye"></i> Voir détails
                                </a>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else if (criteres != null && !criteres.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-search"></i>
                <h3>Aucun résultat trouvé</h3>
                <p>Aucun trajet ne correspond à vos critères de recherche.</p>
                <a href="trajets?action=rechercher" class="btn" style="margin-top: 20px; display: inline-block;">
                    <i class="fas fa-redo"></i> Modifier les critères
                </a>
                <a href="trajets" class="btn btn-secondary" style="margin-top: 20px; display: inline-block; margin-left: 10px;">
                    <i class="fas fa-road"></i> Voir tous les trajets
                </a>
            </div>
        <% } else { %>
            <div class="empty-state">
                <i class="fas fa-search"></i>
                <h3>Rechercher un trajet</h3>
                <p>Utilisez le formulaire ci-dessus pour trouver des trajets selon vos critères.</p>
            </div>
        <% } %>
    </div>
</body>
</html>