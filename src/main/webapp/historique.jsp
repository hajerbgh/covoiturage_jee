<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Reservation" %>
<%@ page import="com.covoiturage.model.Trajet" %>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Vérifier si l'utilisateur est connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    List<Reservation> reservationsPassees = (List<Reservation>) request.getAttribute("reservationsPassees");
    List<Reservation> evaluationsAFaire = (List<Reservation>) request.getAttribute("evaluationsAFaire");
    List<Trajet> trajetsPassees = (List<Trajet>) request.getAttribute("trajetsPassees");
    String role = utilisateur.getRole();
    boolean isConducteur = "CONDUCTEUR".equals(role);
    boolean isPassager = "PASSAGER".equals(role);
    
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm");
    SimpleDateFormat sdfFull = new SimpleDateFormat("dd/MM/yyyy à HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historique - Covoiturage</title>
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
        
        .nav-links a.active {
            background: #4a6cf7;
            color: white;
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
        
        /* Tabs */
        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 5px;
        }
        
        .tab {
            padding: 12px 25px;
            background: #f7fafc;
            border: none;
            border-radius: 8px 8px 0 0;
            font-size: 1rem;
            font-weight: 500;
            color: #4a5568;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .tab:hover {
            background: #edf2f7;
        }
        
        .tab.active {
            background: #4a6cf7;
            color: white;
        }
        
        /* Historique Cards */
        .historique-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }
        
        .section-title {
            color: #2d3748;
            font-size: 1.5rem;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e2e8f0;
            display: flex;
            align-items: center;
            gap: 10px;
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
            border: 1px solid #e2e8f0;
            transition: transform 0.3s;
        }
        
        .trajet-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
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
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
        }
        
        .status-terminee {
            background: #c6f6d5;
            color: #22543d;
        }
        
        .status-annulee {
            background: #fed7d7;
            color: #c53030;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
        }
        
        .btn {
            padding: 8px 15px;
            border: none;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: #4a6cf7;
            color: white;
        }
        
        .btn-primary:hover {
            background: #3a5bd9;
        }
        
        .btn-secondary {
            background: #718096;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #5a6c82;
        }
        
        /* Empty State */
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
        
        .empty-state h3 {
            color: #2d3748;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            margin-bottom: 30px;
        }
        
        /* Evaluation Form */
        .evaluation-form {
            background: #f7fafc;
            border-radius: 10px;
            padding: 20px;
            margin-top: 15px;
            border-left: 4px solid #48bb78;
            display: none; /* Caché par défaut */
        }
        
        .rating-stars {
            display: flex;
            gap: 5px;
            margin: 10px 0;
        }
        
        .star {
            font-size: 1.5rem;
            color: #cbd5e0;
            cursor: pointer;
            transition: color 0.3s;
        }
        
        .star.active {
            color: #f6ad55;
        }
        
        .star:hover {
            color: #f6ad55;
        }
        
        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            margin-top: 10px;
            resize: vertical;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .header {
                padding: 15px 20px;
                flex-direction: column;
                gap: 20px;
            }
            
            .nav-links {
                flex-wrap: wrap;
                justify-content: center;
            }
            
            .trajets-grid {
                grid-template-columns: 1fr;
            }
            
            .tabs {
                flex-wrap: wrap;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="logo">
            <i class="fas fa-history"></i>
            <h1>Historique</h1>
        </div>
        
        <nav class="nav-links">
            <a href="dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <% if (isConducteur) { %>
                <a href="trajets?action=mes-trajets">
                    <i class="fas fa-road"></i> Mes trajets
                </a>
            <% } else { %>
                <a href="reservations">
                    <i class="fas fa-calendar-alt"></i> Mes réservations
                </a>
            <% } %>
            <a href="historique.jsp" class="active">
                <i class="fas fa-history"></i> Historique
            </a>
            <a href="deconnexion">
                <i class="fas fa-sign-out-alt"></i> Déconnexion
            </a>
        </nav>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <div class="page-header">
            <h2><i class="fas fa-clock"></i> Votre historique de covoiturage</h2>
            <p>Retrouvez tous vos trajets passés et évaluez vos expériences</p>
        </div>
        
        <!-- Tabs -->
        <div class="tabs">
            <button class="tab active" data-tab="trajets">
                <% if (isConducteur) { %>
                    <i class="fas fa-car"></i> Mes trajets passés
                <% } else { %>
                    <i class="fas fa-user"></i> Mes réservations passées
                <% } %>
            </button>
            <button class="tab" data-tab="evaluations">
                <i class="fas fa-star"></i> Évaluations à faire
            </button>
            <button class="tab" data-tab="statistiques">
                <i class="fas fa-chart-bar"></i> Statistiques
            </button>
        </div>
        
        <!-- Section 1: Trajets/Réservations passées -->
        <div id="trajets-tab" class="tab-content">
            <div class="historique-section">
                <h3 class="section-title">
                    <% if (isConducteur) { %>
                        <i class="fas fa-road"></i> Trajets que vous avez conduits
                    <% } else { %>
                        <i class="fas fa-calendar-check"></i> Trajets où vous avez été passager
                    <% } %>
                </h3>
                
                <% if ((isPassager && reservationsPassees != null && !reservationsPassees.isEmpty()) || 
                       (isConducteur && trajetsPassees != null && !trajetsPassees.isEmpty())) { %>
                    
                    <div class="trajets-grid">
                        <% if (isPassager && reservationsPassees != null) { 
                            for (Reservation reservation : reservationsPassees) { 
                                if ("TERMINEE".equals(reservation.getStatut()) || "ANNULEE".equals(reservation.getStatut())) { %>
                        <div class="trajet-card">
                            <div class="card-header">
                                <div>
                                    <h4><%= reservation.getDepart() %> → <%= reservation.getDestination() %></h4>
                                    <p style="opacity: 0.9; font-size: 0.9rem;">
                                        <i class="far fa-clock"></i> <%= sdfFull.format(reservation.getDateDepart()) %>
                                    </p>
                                </div>
                                <div class="card-price">
                                    <%= String.format("%.2f", reservation.getPrixTotal()) %> DT
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
                                            <strong><%= reservation.getDepart() %></strong>
                                        </div>
                                        <div class="route-arrivee">
                                            <i class="fas fa-flag-checkered" style="color: #f56565;"></i>
                                            <strong><%= reservation.getDestination() %></strong>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="trajet-details">
                                    <div class="detail-item">
                                        <i class="fas fa-user-tie"></i>
                                        <span>Conducteur: <%= reservation.getConducteurPrenom() %> <%= reservation.getConducteurNom() %></span>
                                    </div>
                                    <div class="detail-item">
                                        <i class="fas fa-calendar-alt"></i>
                                        <span>Date: <%= sdfDate.format(reservation.getDateDepart()) %></span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="card-footer">
                                <div class="status-badge <%= "TERMINEE".equals(reservation.getStatut()) ? "status-terminee" : "status-annulee" %>">
                                    <%= "TERMINEE".equals(reservation.getStatut()) ? "✓ Terminé" : "✗ Annulé" %>
                                </div>
                                <div class="action-buttons">
                                    <% if ("TERMINEE".equals(reservation.getStatut())) { %>
                                    <button class="btn btn-primary evaluer-btn" 
                                            onclick="toggleEvaluationForm('<%= reservation.getId() %>', this)">
                                        <i class="fas fa-star"></i> Évaluer
                                    </button>
                                    <% } %>
                                    <a href="reservations?action=details&reservationId=<%= reservation.getId() %>" class="btn btn-secondary">
                                        <i class="fas fa-eye"></i> Détails
                                    </a>
                                </div>
                            </div>
                            
                            <!-- Formulaire d'évaluation -->
                            <div class="evaluation-form" id="eval-form-<%= reservation.getId() %>">
                                <h4><i class="fas fa-star"></i> Évaluer le conducteur</h4>
                                <form action="evaluations" method="post">
                                    <input type="hidden" name="action" value="creer">
                                    <input type="hidden" name="trajetId" value="<%= reservation.getTrajetId() %>">
                                    <input type="hidden" name="conducteurId" value="<%= reservation.getConducteurId() %>">
                                    <input type="hidden" name="passagerId" value="<%= reservation.getPassagerId() %>">
                                    <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                                    <input type="hidden" name="note" id="note-<%= reservation.getId() %>" value="5">
                                    
                                    <div class="rating-stars" id="stars-<%= reservation.getId() %>">
                                        <% for (int i = 1; i <= 5; i++) { %>
                                        <span class="star <%= i <= 5 ? "active" : "" %>" 
                                              data-value="<%= i %>"
                                              onclick="setRating(<%= reservation.getId() %>, <%= i %>)">
                                            <i class="fas fa-star"></i>
                                        </span>
                                        <% } %>
                                    </div>
                                    
                                    <textarea name="commentaire" class="form-control" 
                                              placeholder="Laissez un commentaire sur votre expérience..." 
                                              rows="3" required></textarea>
                                    
                                    <div style="display: flex; gap: 10px; margin-top: 15px;">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-paper-plane"></i> Envoyer l'évaluation
                                        </button>
                                        <button type="button" class="btn btn-secondary" 
                                                onclick="toggleEvaluationForm('<%= reservation.getId() %>', this.closest('.trajet-card').querySelector('.evaluer-btn'))">
                                            <i class="fas fa-times"></i> Annuler
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                                <% } %>
                            <% } %>
                        <% } else if (isConducteur && trajetsPassees != null) { 
                            for (Trajet trajet : trajetsPassees) { 
                                if ("TERMINE".equals(trajet.getStatut()) || "ANNULE".equals(trajet.getStatut())) { %>
                        <div class="trajet-card">
                            <div class="card-header">
                                <div>
                                    <h4><%= trajet.getDepart() %> → <%= trajet.getDestination() %></h4>
                                    <p style="opacity: 0.9; font-size: 0.9rem;">
                                        <i class="far fa-clock"></i> <%= sdfFull.format(trajet.getDateDepart()) %>
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
                                        <i class="fas fa-users"></i>
                                        <span>Places: <%= trajet.getPlacesDisponibles() %>/4</span>
                                    </div>
                                    <div class="detail-item">
                                        <i class="fas fa-calendar-alt"></i>
                                        <span>Date: <%= sdfDate.format(trajet.getDateDepart()) %></span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="card-footer">
                                <div class="status-badge <%= "TERMINE".equals(trajet.getStatut()) ? "status-terminee" : "status-annulee" %>">
                                    <%= "TERMINE".equals(trajet.getStatut()) ? "✓ Terminé" : "✗ Annulé" %>
                                </div>
                                <div class="action-buttons">
                                    <a href="trajets?action=details&id=<%= trajet.getId() %>" class="btn btn-secondary">
                                        <i class="fas fa-eye"></i> Détails
                                    </a>
                                    <a href="passagers?action=trajet&trajetId=<%= trajet.getId() %>" class="btn btn-primary">
                                        <i class="fas fa-users"></i> Passagers
                                    </a>
                                </div>
                            </div>
                        </div>
                                <% } %>
                            <% } %>
                        <% } %>
                    </div>
                    
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-history"></i>
                        <h3>Aucun historique disponible</h3>
                        <p>Vous n'avez pas encore de trajets passés.</p>
                        <% if (isConducteur) { %>
                            <a href="creer-trajet.jsp" class="btn btn-primary" style="margin-top: 20px; display: inline-block;">
                                <i class="fas fa-plus-circle"></i> Proposer un trajet
                            </a>
                        <% } else { %>
                            <a href="rechercher-trajet.jsp" class="btn btn-primary" style="margin-top: 20px; display: inline-block;">
                                <i class="fas fa-search"></i> Rechercher un trajet
                            </a>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>
        
        <!-- Section 2: Évaluations à faire -->
        <div id="evaluations-tab" class="tab-content" style="display: none;">
            <div class="historique-section">
                <h3 class="section-title">
                    <i class="fas fa-star"></i> Évaluations en attente
                </h3>
                
                <% if (isPassager && evaluationsAFaire != null && !evaluationsAFaire.isEmpty()) { %>
                    <div class="trajets-grid">
                        <% for (Reservation reservation : evaluationsAFaire) { %>
                        <div class="trajet-card">
                            <div class="card-header">
                                <div>
                                    <h4><%= reservation.getDepart() %> → <%= reservation.getDestination() %></h4>
                                    <p style="opacity: 0.9; font-size: 0.9rem;">
                                        <i class="far fa-clock"></i> <%= sdfFull.format(reservation.getDateDepart()) %>
                                    </p>
                                </div>
                                <div class="card-price">
                                    <%= String.format("%.2f", reservation.getPrixTotal()) %> DT
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
                                            <strong><%= reservation.getDepart() %></strong>
                                        </div>
                                        <div class="route-arrivee">
                                            <i class="fas fa-flag-checkered" style="color: #f56565;"></i>
                                            <strong><%= reservation.getDestination() %></strong>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="trajet-details">
                                    <div class="detail-item">
                                        <i class="fas fa-user-tie"></i>
                                        <span>Conducteur: <%= reservation.getConducteurPrenom() %> <%= reservation.getConducteurNom() %></span>
                                    </div>
                                    <div class="detail-item">
                                        <i class="fas fa-calendar-alt"></i>
                                        <span>Date: <%= sdfDate.format(reservation.getDateDepart()) %></span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="card-footer">
                                <div class="status-badge status-terminee">
                                    ✓ En attente d'évaluation
                                </div>
                                <div class="action-buttons">
                                    <button class="btn btn-primary evaluer-btn" 
                                            onclick="toggleEvaluationForm('<%= reservation.getId() %>', this)">
                                        <i class="fas fa-star"></i> Évaluer maintenant
                                    </button>
                                </div>
                            </div>
                            
                            <!-- Formulaire d'évaluation -->
                            <div class="evaluation-form" id="eval-form-<%= reservation.getId() %>">
                                <h4><i class="fas fa-star"></i> Évaluer le conducteur</h4>
                              <form action="evaluations" method="post">
    <input type="hidden" name="action" value="creer">
    <input type="hidden" name="trajetId" value="<%= reservation.getTrajetId() %>">
    <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
    <input type="hidden" name="note" id="note-<%= reservation.getId() %>" value="5">
    
    <div class="rating-stars" id="stars-<%= reservation.getId() %>">
        <% for (int i = 1; i <= 5; i++) { %>
        <span class="star <%= i <= 5 ? "active" : "" %>" 
              data-value="<%= i %>"
              onclick="setRating(<%= reservation.getId() %>, <%= i %>)">
            <i class="fas fa-star"></i>
        </span>
        <% } %>
    </div>
    
    <textarea name="commentaire" class="form-control" 
              placeholder="Laissez un commentaire sur votre expérience..." 
              rows="3" required></textarea>
    
    <div style="display: flex; gap: 10px; margin-top: 15px;">
        <button type="submit" class="btn btn-primary">
            <i class="fas fa-paper-plane"></i> Envoyer l'évaluation
        </button>
        <button type="button" class="btn btn-secondary" 
                onclick="toggleEvaluationForm('<%= reservation.getId() %>', this.closest('.trajet-card').querySelector('.evaluer-btn'))">
            <i class="fas fa-times"></i> Annuler
        </button>
    </div>
</form>
                            </div>
                        </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-star-half-alt"></i>
                        <h3>Aucune évaluation en attente</h3>
                        <p>Vous avez évalué tous vos trajets terminés.</p>
                        <p style="font-size: 0.9rem; color: #a0aec0;">
                            <i class="fas fa-info-circle"></i> Les trajets terminés apparaissent ici pour évaluation
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
        
        <!-- Section 3: Statistiques -->
        <div id="statistiques-tab" class="tab-content" style="display: none;">
            <div class="historique-section">
                <h3 class="section-title">
                    <i class="fas fa-chart-bar"></i> Vos statistiques
                </h3>
                
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-top: 20px;">
                    <div style="background: white; padding: 25px; border-radius: 10px; box-shadow: 0 3px 15px rgba(0,0,0,0.05); text-align: center;">
                        <div style="font-size: 2.5rem; color: #4a6cf7; margin-bottom: 10px;">
                            <i class="fas fa-road"></i>
                        </div>
                        <div style="font-size: 2rem; font-weight: bold; color: #2d3748; margin-bottom: 5px;">
                            <%= (isPassager && reservationsPassees != null) ? reservationsPassees.size() : 
                                (isConducteur && trajetsPassees != null) ? trajetsPassees.size() : 0 %>
                        </div>
                        <div style="color: #718096; font-size: 0.9rem;">
                            <% if (isConducteur) { %>Trajets effectués<% } else { %>Trajets réalisés<% } %>
                        </div>
                    </div>
                    
                    <div style="background: white; padding: 25px; border-radius: 10px; box-shadow: 0 3px 15px rgba(0,0,0,0.05); text-align: center;">
                        <div style="font-size: 2.5rem; color: #48bb78; margin-bottom: 10px;">
                            <i class="fas fa-star"></i>
                        </div>
                        <div style="font-size: 2rem; font-weight: bold; color: #2d3748; margin-bottom: 5px;">
                            4.5
                        </div>
                        <div style="color: #718096; font-size: 0.9rem;">
                            Note moyenne
                        </div>
                    </div>
                    
                    <div style="background: white; padding: 25px; border-radius: 10px; box-shadow: 0 3px 15px rgba(0,0,0,0.05); text-align: center;">
                        <div style="font-size: 2.5rem; color: #f56565; margin-bottom: 10px;">
                            <i class="fas fa-times-circle"></i>
                        </div>
                        <div style="font-size: 2rem; font-weight: bold; color: #2d3748; margin-bottom: 5px;">
                            0
                        </div>
                        <div style="color: #718096; font-size: 0.9rem;">
                            Annulations
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Gestion des tabs
            const tabs = document.querySelectorAll('.tab');
            const tabContents = document.querySelectorAll('.tab-content');
            
            tabs.forEach(tab => {
                tab.addEventListener('click', function() {
                    const tabId = this.getAttribute('data-tab');
                    
                    // Mettre à jour les tabs
                    tabs.forEach(t => t.classList.remove('active'));
                    this.classList.add('active');
                    
                    // Afficher le contenu correspondant
                    tabContents.forEach(content => {
                        content.style.display = 'none';
                    });
                    
                    document.getElementById(tabId + '-tab').style.display = 'block';
                });
            });
            
            // Initialiser les statistiques
            updateStatistics();
        });
        
        // Fonction pour afficher/masquer le formulaire d'évaluation
        function toggleEvaluationForm(reservationId, button) {
            const formId = 'eval-form-' + reservationId;
            const form = document.getElementById(formId);
            const trajetCard = button.closest('.trajet-card');
            
            if (!form) {
                console.error('Formulaire non trouvé: ' + formId);
                return;
            }
            
            if (form.style.display === 'none' || form.style.display === '') {
                // Afficher le formulaire
                form.style.display = 'block';
                button.innerHTML = '<i class="fas fa-times"></i> Annuler';
                button.classList.add('btn-secondary');
                button.classList.remove('btn-primary');
                
                // Faire défiler jusqu'au formulaire
                form.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            } else {
                // Masquer le formulaire
                form.style.display = 'none';
                button.innerHTML = '<i class="fas fa-star"></i> Évaluer';
                button.classList.add('btn-primary');
                button.classList.remove('btn-secondary');
            }
        }
        
        // Fonction pour définir la note
        function setRating(reservationId, rating) {
            const stars = document.querySelectorAll('#stars-' + reservationId + ' .star');
            const noteInput = document.getElementById('note-' + reservationId);
            
            // Mettre à jour la note
            noteInput.value = rating;
            
            // Mettre à jour l'affichage des étoiles
            stars.forEach(star => {
                const value = parseInt(star.getAttribute('data-value'));
                if (value <= rating) {
                    star.classList.add('active');
                } else {
                    star.classList.remove('active');
                }
            });
        }
        
        // Fonction pour les statistiques
        function updateStatistics() {
            // Ici, vous pourriez faire un appel AJAX pour récupérer les statistiques réelles
            // fetch('api/statistiques')
            //     .then(response => response.json())
            //     .then(data => {
            //         // Mettre à jour les éléments avec les données
            //     });
        }
    </script>
</body>
</html>