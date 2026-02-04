<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="com.covoiturage.model.Trajet" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Vérifier si l'utilisateur est connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    // Vérifier que l'utilisateur est passager
    if (!"PASSAGER".equals(utilisateur.getRole())) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    Trajet trajet = (Trajet) request.getAttribute("trajet");
    if (trajet == null) {
        response.sendRedirect("liste-trajets.jsp");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Réserver un trajet - Covoiturage</title>
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
            line-height: 1.6;
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
            max-width: 800px;
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
        
        .btn-success {
            background: #48bb78;
        }
        
        .btn-success:hover {
            background: #38a169;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .alert-error {
            background: #fed7d7;
            color: #9b2c2c;
            border-left: 4px solid #f56565;
        }
        
        .reservation-container {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }
        
        .trajet-summary {
            background: #f7fafc;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
            border-left: 4px solid #4a6cf7;
        }
        
        .route-display {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        
        .route-point {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .route-point i {
            font-size: 1.5rem;
        }
        
        .route-point.depart i {
            color: #48bb78;
        }
        
        .route-point.arrivee i {
            color: #f56565;
        }
        
        .route-line {
            flex: 1;
            height: 2px;
            background: #cbd5e0;
            margin: 0 20px;
            position: relative;
        }
        
        .route-line::after {
            content: '→';
            position: absolute;
            top: -10px;
            left: 50%;
            transform: translateX(-50%);
            background: white;
            padding: 0 10px;
            color: #4a5568;
        }
        
        .trajet-details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .detail-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px;
            background: white;
            border-radius: 8px;
        }
        
        .detail-item i {
            color: #4a6cf7;
        }
        
        .reservation-form {
            padding: 30px;
            background: #f7fafc;
            border-radius: 12px;
        }
        
        .form-section {
            margin-bottom: 30px;
        }
        
        .section-title {
            color: #2d3748;
            font-size: 1.2rem;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .info-box {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid #e2e8f0;
        }
        
        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e2e8f0;
        }
        
        .info-item:last-child {
            border-bottom: none;
        }
        
        .info-label {
            color: #718096;
        }
        
        .info-value {
            color: #2d3748;
            font-weight: 500;
        }
        
        .price-display {
            text-align: center;
            padding: 20px;
            background: linear-gradient(135deg, #4a6cf7, #8a63d2);
            color: white;
            border-radius: 12px;
            margin: 30px 0;
        }
        
        .price-label {
            font-size: 1rem;
            opacity: 0.9;
        }
        
        .price-value {
            font-size: 2.5rem;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .confirmation-message {
            text-align: center;
            padding: 20px;
            background: #c6f6d5;
            color: #22543d;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #48bb78;
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="logo">
            <i class="fas fa-calendar-check"></i>
            <h1>Réserver un trajet</h1>
        </div>
        <div>
            <a href="trajets?action=details&id=<%= trajet.getId() %>" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Retour aux détails
            </a>
        </div>
    </header>
    
    <div class="container">
        <% 
            String erreur = (String) request.getAttribute("erreur");
            if (erreur != null && !erreur.isEmpty()) {
        %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= erreur %>
            </div>
        <% } %>
        
        <div class="reservation-container">
            <div class="page-header">
                <h2>Confirmer votre réservation</h2>
                <p>Veuillez vérifier les détails du trajet avant de confirmer</p>
            </div>
            
            <!-- Résumé du trajet -->
            <div class="trajet-summary">
                <div class="route-display">
                    <div class="route-point depart">
                        <i class="fas fa-map-marker-alt"></i>
                        <div>
                            <h3>Départ</h3>
                            <p><%= trajet.getDepart() %></p>
                        </div>
                    </div>
                    
                    <div class="route-line"></div>
                    
                    <div class="route-point arrivee">
                        <i class="fas fa-flag-checkered"></i>
                        <div>
                            <h3>Arrivée</h3>
                            <p><%= trajet.getDestination() %></p>
                        </div>
                    </div>
                </div>
                
                <div class="trajet-details-grid">
                    <div class="detail-item">
                        <i class="far fa-calendar"></i>
                        <div>
                            <strong>Date</strong>
                            <p><%= sdf.format(trajet.getDateDepart()) %></p>
                        </div>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-chair"></i>
                        <div>
                            <strong>Places disponibles</strong>
                            <p><%= trajet.getPlacesDisponibles() %></p>
                        </div>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-tag"></i>
                        <div>
                            <strong>Prix par place</strong>
                            <p><%= String.format("%.2f DT", trajet.getPrix()) %></p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Formulaire de réservation -->
            <form action="reservations" method="post" class="reservation-form">
                <input type="hidden" name="action" value="creer">
                <input type="hidden" name="trajetId" value="<%= trajet.getId() %>">
                
                <div class="section-title">
                    <i class="fas fa-user-circle"></i> Vos informations
                </div>
                
                <div class="info-box">
                    <div class="info-item">
                        <span class="info-label">Nom complet</span>
                        <span class="info-value"><%= utilisateur.getPrenom() %> <%= utilisateur.getNom() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Email</span>
                        <span class="info-value"><%= utilisateur.getEmail() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Téléphone</span>
                        <span class="info-value"><%= utilisateur.getTelephone() != null ? utilisateur.getTelephone() : "Non renseigné" %></span>
                    </div>
                </div>
                
                <div class="section-title">
                    <i class="fas fa-receipt"></i> Récapitulatif de la réservation
                </div>
                
                <div class="info-box">
                    <div class="info-item">
                        <span class="info-label">Trajet</span>
                        <span class="info-value"><%= trajet.getDepart() %> → <%= trajet.getDestination() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Date de départ</span>
                        <span class="info-value"><%= sdf.format(trajet.getDateDepart()) %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Nombre de places</span>
                        <span class="info-value">1 place</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Prix unitaire</span>
                        <span class="info-value"><%= String.format("%.2f DT", trajet.getPrix()) %></span>
                    </div>
                    <div class="info-item" style="border-top: 2px solid #4a6cf7; padding-top: 15px;">
                        <span class="info-label" style="font-size: 1.1rem;">Prix total</span>
                        <span class="info-value" style="font-size: 1.3rem; color: #4a6cf7; font-weight: bold;">
                            <%= String.format("%.2f DT", trajet.getPrix()) %>
                        </span>
                    </div>
                </div>
                
                <div class="price-display">
                    <div class="price-label">Montant total à payer</div>
                    <div class="price-value"><%= String.format("%.2f DT", trajet.getPrix()) %></div>
                    <p><small>Paiement au conducteur le jour du trajet</small></p>
                </div>
                
                <div class="confirmation-message">
                    <i class="fas fa-info-circle"></i>
                    <p>Le conducteur devra confirmer votre réservation avant qu'elle ne soit définitive.</p>
                </div>
                
                <div class="form-actions">
                    <a href="trajets?action=details&id=<%= trajet.getId() %>" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Annuler
                    </a>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-check-circle"></i> Confirmer la réservation
                    </button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>