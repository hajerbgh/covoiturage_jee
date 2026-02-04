<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Reservation" %>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Vérifier si l'utilisateur est connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    // Vérifier si c'est un passager
    if (!"PASSAGER".equals(utilisateur.getRole())) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    Reservation reservation = (Reservation) request.getAttribute("reservation");
    String erreur = (String) request.getAttribute("erreur");
    
    if (reservation == null && erreur == null) {
        response.sendRedirect("reservations");
        return;
    }
    
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm");
    SimpleDateFormat sdfFull = new SimpleDateFormat("dd/MM/yyyy à HH:mm");
    
    String statusClass = "";
    String statusText = "";
    if (reservation != null) {
        switch (reservation.getStatut()) {
            case "EN_ATTENTE": 
                statusClass = "status-en-attente";
                statusText = "En attente";
                break;
            case "CONFIRMEE": 
                statusClass = "status-confirmee";
                statusText = "Confirmée";
                break;
            case "ANNULEE": 
                statusClass = "status-annulee";
                statusText = "Annulée";
                break;
            case "TERMINEE": 
                statusClass = "status-terminee";
                statusText = "Terminée";
                break;
            default:
                statusClass = "status-en-attente";
                statusText = reservation.getStatut();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Détails de la réservation - Covoiturage</title>
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
            max-width: 900px;
            margin: 0 auto 40px;
            padding: 0 20px;
        }
        
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #4a5568;
            text-decoration: none;
            margin-bottom: 20px;
            padding: 10px 15px;
            border-radius: 6px;
            transition: background 0.3s;
        }
        
        .back-link:hover {
            background: #edf2f7;
        }
        
        <% if (reservation != null) { %>
        /* Carte principale */
        .reservation-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .card-header {
            background: linear-gradient(135deg, #4a6cf7, #8a63d2);
            color: white;
            padding: 30px;
            position: relative;
        }
        
        .status-badge {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(255,255,255,0.2);
            padding: 10px 20px;
            border-radius: 30px;
            font-weight: 500;
            backdrop-filter: blur(10px);
        }
        
        .status-en-attente {
            background: rgba(254, 235, 200, 0.8);
            color: #c05621;
        }
        
        .status-confirmee {
            background: rgba(198, 246, 213, 0.8);
            color: #22543d;
        }
        
        .status-annulee {
            background: rgba(254, 215, 215, 0.8);
            color: #c53030;
        }
        
        .status-terminee {
            background: rgba(233, 216, 253, 0.8);
            color: #553c9a;
        }
        
        .route-title {
            font-size: 1.8rem;
            margin-bottom: 10px;
        }
        
        .route-subtitle {
            opacity: 0.9;
            font-size: 1rem;
        }
        
        .route-display {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-top: 20px;
            padding: 20px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        
        .route-point {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 1;
        }
        
        .route-point i {
            font-size: 1.5rem;
        }
        
        .route-point.depart i { color: #48bb78; }
        .route-point.arrivee i { color: #f56565; }
        
        .route-info h3 {
            margin-bottom: 5px;
        }
        
        .route-info p {
            opacity: 0.8;
            font-size: 0.9rem;
        }
        
        .route-arrow {
            font-size: 1.5rem;
            opacity: 0.7;
        }
        
        /* Corps */
        .card-body {
            padding: 30px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .info-card {
            padding: 25px;
            background: #f7fafc;
            border-radius: 10px;
        }
        
        .info-card h3 {
            color: #2d3748;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e2e8f0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #e2e8f0;
        }
        
        .info-item:last-child {
            border-bottom: none;
        }
        
        .info-label {
            color: #718096;
            font-weight: 500;
        }
        
        .info-value {
            color: #2d3748;
            font-weight: 500;
            text-align: right;
        }
        
        .info-value strong {
            color: #4a6cf7;
            font-size: 1.2rem;
        }
        
        /* Conducteur info */
        .conducteur-card {
            background: #ebf8ff;
            border-left: 4px solid #4299e1;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .conducteur-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .conducteur-avatar {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #4299e1, #63b3ed);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            font-weight: bold;
        }
        
        .conducteur-info h3 {
            color: #2d3748;
            margin-bottom: 5px;
        }
        
        .conducteur-info p {
            color: #718096;
        }
        
        .contact-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .contact-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px;
            background: white;
            border-radius: 8px;
        }
        
        .contact-item i {
            color: #4299e1;
        }
        
        /* Actions */
        .actions-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            border: 2px solid #e2e8f0;
            margin-top: 30px;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
        }
        
        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
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
        
        .btn-danger {
            background: #f56565;
            color: white;
        }
        
        .btn-danger:hover {
            background: #e53e3e;
        }
        
        .btn-success {
            background: #48bb78;
            color: white;
        }
        
        .btn-success:hover {
            background: #38a169;
        }
        <% } %>
        
        /* État d'erreur */
        .error-state {
            background: white;
            border-radius: 15px;
            padding: 50px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .error-state i {
            font-size: 4rem;
            color: #f56565;
            margin-bottom: 20px;
        }
        
        .error-state h2 {
            color: #2d3748;
            margin-bottom: 15px;
        }
        
        .error-state p {
            color: #718096;
            margin-bottom: 30px;
        }
        
        @media (max-width: 768px) {
            .header {
                padding: 15px 20px;
                flex-direction: column;
                gap: 20px;
            }
            
            .route-display {
                flex-direction: column;
                text-align: center;
            }
            
            .route-arrow {
                transform: rotate(90deg);
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="logo">
            <i class="fas fa-calendar-check"></i>
            <h1>Détails de la réservation</h1>
        </div>
        
        <nav class="nav-links">
            <a href="dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="reservations">
                <i class="fas fa-calendar-alt"></i> Mes réservations
            </a>
            <a href="deconnexion">
                <i class="fas fa-sign-out-alt"></i> Déconnexion
            </a>
        </nav>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <a href="reservations" class="back-link">
            <i class="fas fa-arrow-left"></i> Retour aux réservations
        </a>
        
        <% if (erreur != null && !erreur.isEmpty()) { %>
            <div class="error-state">
                <i class="fas fa-exclamation-circle"></i>
                <h2>Erreur</h2>
                <p><%= erreur %></p>
                <a href="reservations" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Retour aux réservations
                </a>
            </div>
        <% } else if (reservation != null) { %>
        
        <!-- Carte de réservation -->
        <div class="reservation-card">
            <!-- En-tête -->
            <div class="card-header">
                <div class="status-badge <%= statusClass %>">
                    <%= statusText %>
                </div>
                
                <h1 class="route-title"><%= reservation.getDepart() %> → <%= reservation.getDestination() %></h1>
                <p class="route-subtitle">
                    <i class="far fa-clock"></i> 
                    Départ prévu le <%= sdfFull.format(reservation.getDateDepart()) %>
                </p>
                
                <div class="route-display">
                    <div class="route-point depart">
                        <i class="fas fa-map-marker-alt"></i>
                        <div class="route-info">
                            <h3>Départ</h3>
                            <p><%= reservation.getDepart() %></p>
                        </div>
                    </div>
                    
                    <div class="route-arrow">
                        <i class="fas fa-long-arrow-alt-right"></i>
                    </div>
                    
                    <div class="route-point arrivee">
                        <i class="fas fa-flag-checkered"></i>
                        <div class="route-info">
                            <h3>Arrivée</h3>
                            <p><%= reservation.getDestination() %></p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Corps -->
            <div class="card-body">
                <!-- Informations générales -->
                <div class="info-grid">
                    <div class="info-card">
                        <h3><i class="fas fa-info-circle"></i> Informations du trajet</h3>
                        <div class="info-item">
                            <span class="info-label">Date de départ</span>
                            <span class="info-value"><%= sdfDate.format(reservation.getDateDepart()) %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Heure de départ</span>
                            <span class="info-value"><%= sdfTime.format(reservation.getDateDepart()) %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Prix par place</span>
                            <span class="info-value"><%= String.format("%.2f", reservation.getPrixParPlace()) %> DT</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Date de réservation</span>
                            <span class="info-value"><%= sdfFull.format(reservation.getDateReservation()) %></span>
                        </div>
                    </div>
                    
                    <div class="info-card">
                        <h3><i class="fas fa-money-bill-wave"></i> Informations de paiement</h3>
                        <div class="info-item">
                            <span class="info-label">Prix unitaire</span>
                            <span class="info-value"><%= String.format("%.2f", reservation.getPrixParPlace()) %> DT</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Nombre de places</span>
                            <span class="info-value">1 place</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Total à payer</span>
                            <span class="info-value">
                                <strong><%= String.format("%.2f", reservation.getPrixTotal()) %> DT</strong>
                            </span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Mode de paiement</span>
                            <span class="info-value">Au conducteur</span>
                        </div>
                    </div>
                </div>
                
                <!-- Informations conducteur -->
                <div class="conducteur-card">
                    <div class="conducteur-header">
                        <div class="conducteur-avatar">
                            <%= reservation.getConducteurPrenom().charAt(0) %><%= reservation.getConducteurNom().charAt(0) %>
                        </div>
                        <div class="conducteur-info">
                            <h3><%= reservation.getConducteurPrenom() %> <%= reservation.getConducteurNom() %></h3>
                            <p>Votre conducteur</p>
                        </div>
                    </div>
                    
                   <div class="contact-info">
    <% if (reservation.getConducteurEmail() != null && !reservation.getConducteurEmail().isEmpty()) { %>
    <div class="contact-item">
        <i class="fas fa-envelope"></i>
        <div>
            <small>Email</small>
            <div><%= reservation.getConducteurEmail() %></div>
        </div>
    </div>
    <% } %>
    
    <% if (reservation.getConducteurTelephone() != null && !reservation.getConducteurTelephone().isEmpty()) { %>
    <div class="contact-item">
        <i class="fas fa-phone"></i>
        <div>
            <small>Téléphone</small>
            <div><%= reservation.getConducteurTelephone() %></div>
        </div>
    </div>
    <% } %>
</div>
                </div>
                
                <!-- Actions -->
                <div class="actions-card">
                    <div class="action-buttons">
                        <% if ("EN_ATTENTE".equals(reservation.getStatut()) || "CONFIRMEE".equals(reservation.getStatut())) { %>
                            <a href="reservations?action=annuler&reservationId=<%= reservation.getId() %>" 
                               class="btn btn-danger"
                               onclick="return confirm('Êtes-vous sûr de vouloir annuler cette réservation ?')">
                                <i class="fas fa-times"></i> Annuler la réservation
                            </a>
                        <% } %>
                        
                        <a href="trajets?action=details&id=<%= reservation.getTrajetId() %>" class="btn btn-secondary">
                            <i class="fas fa-road"></i> Voir le trajet
                        </a>
                        
                        <% if ("CONFIRMEE".equals(reservation.getStatut())) { %>
                            <button class="btn btn-primary">
                                <i class="fas fa-comment"></i> Contacter le conducteur
                            </button>
                        <% } %>
                        
                        <a href="reservations" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Retour
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <% } %>
    </div>
    
    <script>
        // Confirmation pour l'annulation
        document.addEventListener('DOMContentLoaded', function() {
            const cancelBtn = document.querySelector('.btn-danger');
            if (cancelBtn) {
                cancelBtn.addEventListener('click', function(e) {
                    if (!confirm('Êtes-vous sûr de vouloir annuler cette réservation ?')) {
                        e.preventDefault();
                    }
                });
            }
        });
    </script>
</body>
</html>