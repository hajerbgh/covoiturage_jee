<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Trajet" %>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Vérifier si l'utilisateur est connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    List<Trajet> trajets = (List<Trajet>) request.getAttribute("trajets");
    String erreur = (String) request.getAttribute("erreur");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trajets disponibles - Covoiturage</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Style similaire à dashboard.jsp */
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
        
        .search-box {
            background: white;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }
        
        .search-form {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #4a5568;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
        }
        
        .btn {
            padding: 12px 25px;
            background: #4a6cf7;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            align-self: end;
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
        
        .empty-state {
            text-align: center;
            padding: 50px 20px;
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
            
            .trajets-grid {
                grid-template-columns: 1fr;
            }
            
            .search-form {
                grid-template-columns: 1fr;
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
            <% if ("CONDUCTEUR".equals(utilisateur.getRole())) { %>
                <a href="trajets?action=creer">
                    <i class="fas fa-plus-circle"></i> Proposer trajet
                </a>
            <% } %>
            <a href="trajets?action=rechercher">
                <i class="fas fa-search"></i> Rechercher
            </a>
            <a href="deconnexion">
                <i class="fas fa-sign-out-alt"></i> Déconnexion
            </a>
        </nav>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <div class="page-header">
            <h2><i class="fas fa-road"></i> Trajets disponibles</h2>
            <p>Trouvez le trajet qui correspond à vos besoins</p>
        </div>
        
        <!-- Search Box -->
        <div class="search-box">
            <form action="trajets" method="get" class="search-form">
                <input type="hidden" name="action" value="rechercher">
                
                <div class="form-group">
                    <label><i class="fas fa-map-marker-alt"></i> Départ</label>
                    <input type="text" name="depart" class="form-control" placeholder="Ville de départ">
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-flag-checkered"></i> Destination</label>
                    <input type="text" name="destination" class="form-control" placeholder="Ville d'arrivée">
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-calendar-alt"></i> Date</label>
                    <input type="date" name="date" class="form-control">
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-tag"></i> Prix max (DT)</label>
                    <input type="number" name="prixMax" class="form-control" placeholder="Prix maximum" step="0.5">
                </div>
                
                <button type="submit" class="btn">
                    <i class="fas fa-search"></i> Rechercher
                </button>
            </form>
        </div>
        
        <!-- Trajets List -->
        <% if (erreur != null && !erreur.isEmpty()) { %>
            <div style="background: #fed7d7; color: #c53030; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                <i class="fas fa-exclamation-circle"></i> <%= erreur %>
            </div>
        <% } %>
        
        <% if (trajets != null && !trajets.isEmpty()) { %>
            <div class="trajets-grid">
                <% for (Trajet trajet : trajets) { %>
                    <div class="trajet-card">
                        <div class="card-header">
                            <div>
                                <h3><%= trajet.getDepart() %> → <%= trajet.getDestination() %></h3>
                                <p style="opacity: 0.9; font-size: 0.9rem;">
                                    <i class="far fa-clock"></i> <%= sdf.format(trajet.getDateDepart()) %>
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
                                        <span><strong>Départ:</strong> <%= trajet.getDepart() %></span>
                                    </div>
                                    <div class="route-arrivee">
                                        <i class="fas fa-flag-checkered" style="color: #f56565;"></i>
                                        <span><strong>Arrivée:</strong> <%= trajet.getDestination() %></span>
                                    </div>
                                </div>
                            </div>
                            
                            <% if (trajet.getDescription() != null && !trajet.getDescription().isEmpty()) { %>
                                <div style="margin-top: 15px; padding: 10px; background: #f7fafc; border-radius: 6px; font-size: 0.9rem;">
                                    <i class="fas fa-comment-alt"></i> 
                                    <%= trajet.getDescription().length() > 100 ? 
                                        trajet.getDescription().substring(0, 100) + "..." : 
                                        trajet.getDescription() %>
                                </div>
                            <% } %>
                            
                            <div class="trajet-details">
                                <div class="detail-item">
                                    <i class="fas fa-chair"></i>
                                    <span><%= trajet.getPlacesDisponibles() %> place(s) dispo</span>
                                </div>
                                
                                <% if (trajet.getRestrictions() != null && !trajet.getRestrictions().isEmpty()) { %>
                                    <div class="detail-item">
                                        <i class="fas fa-ban"></i>
                                        <span><%= trajet.getRestrictions() %></span>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                        
                        <div class="card-footer">
                            <div class="places-badge">
                                <i class="fas fa-users"></i> <%= trajet.getPlacesDisponibles() %> places
                            </div>
                            <a href="trajets?action=details&id=<%= trajet.getId() %>" class="btn-details">
                                <i class="fas fa-eye"></i> Voir détails
                            </a>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <i class="fas fa-road"></i>
                <h3>Aucun trajet disponible</h3>
                <p>Il n'y a aucun trajet disponible pour le moment.</p>
                <% if ("CONDUCTEUR".equals(utilisateur.getRole())) { %>
                    <a href="trajets?action=creer" class="btn" style="margin-top: 20px; display: inline-block;">
                        <i class="fas fa-plus-circle"></i> Proposer un trajet
                    </a>
                <% } %>
            </div>
        <% } %>
    </div>
</body>
</html>