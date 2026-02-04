<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Reservation" %>
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
    
    // Vérifier si c'est un passager
    if (!"PASSAGER".equals(utilisateur.getRole())) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    String erreur = (String) request.getAttribute("erreur");
    String successMessage = (String) session.getAttribute("successMessage");
    
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm");
    SimpleDateFormat sdfFull = new SimpleDateFormat("dd/MM/yyyy à HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes réservations - Covoiturage</title>
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
        
        /* Messages */
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-success {
            background: #c6f6d5;
            border: 1px solid #9ae6b4;
            color: #22543d;
        }
        
        .alert-error {
            background: #fed7d7;
            border: 1px solid #fc8181;
            color: #c53030;
        }
        
        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 3px 15px rgba(0,0,0,0.05);
        }
        
        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 15px;
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
        
        /* Reservations Table */
        .reservations-container {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }
        
        .table-header {
            padding: 25px 30px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .table-header h3 {
            color: #2d3748;
            font-size: 1.3rem;
        }
        
        .table-controls {
            display: flex;
            gap: 10px;
        }
        
        .filter-select {
            padding: 8px 15px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            color: #4a5568;
        }
        
        .reservations-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .reservations-table thead {
            background: #f7fafc;
        }
        
        .reservations-table th {
            padding: 18px 20px;
            text-align: left;
            color: #4a5568;
            font-weight: 600;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .reservations-table tbody tr {
            border-bottom: 1px solid #e2e8f0;
            transition: background 0.2s;
        }
        
        .reservations-table tbody tr:hover {
            background: #f7fafc;
        }
        
        .reservations-table td {
            padding: 20px;
            color: #4a5568;
        }
        
        /* Status Badges */
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
            display: inline-block;
        }
        
        .status-en-attente {
            background: #feebc8;
            color: #c05621;
        }
        
        .status-confirmee {
            background: #c6f6d5;
            color: #22543d;
        }
        
        .status-annulee {
            background: #fed7d7;
            color: #c53030;
        }
        
        .status-terminee {
            background: #e9d8fd;
            color: #553c9a;
        }
        
        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 8px;
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
        
        .btn-details {
            background: #4299e1;
            color: white;
        }
        
        .btn-details:hover {
            background: #3182ce;
        }
        
        .btn-cancel {
            background: #fc8181;
            color: white;
        }
        
        .btn-cancel:hover {
            background: #f56565;
        }
        
        .btn-view {
            background: #48bb78;
            color: white;
        }
        
        .btn-view:hover {
            background: #38a169;
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }
        
        .empty-state i {
            font-size: 4rem;
            color: #cbd5e0;
            margin-bottom: 20px;
        }
        
        .empty-state h3 {
            color: #2d3748;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: #718096;
            margin-bottom: 30px;
        }
        
        .btn-primary {
            padding: 12px 25px;
            background: #4a6cf7;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary:hover {
            background: #3a5bd9;
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
            
            .table-header {
                flex-direction: column;
                gap: 15px;
                align-items: stretch;
            }
            
            .reservations-table {
                display: block;
                overflow-x: auto;
            }
            
            .reservations-table th,
            .reservations-table td {
                white-space: nowrap;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="logo">
            <i class="fas fa-calendar-check"></i>
            <h1>Mes réservations</h1>
        </div>
        
        <nav class="nav-links">
            <a href="dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="trajets">
                <i class="fas fa-road"></i> Rechercher trajet
            </a>
            <a href="mes-reservations.jsp" class="active">
                <i class="fas fa-calendar-alt"></i> Mes réservations
            </a>
            <a href="deconnexion">
                <i class="fas fa-sign-out-alt"></i> Déconnexion
            </a>
        </nav>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <div class="page-header">
            <h2><i class="fas fa-history"></i> Historique de vos réservations</h2>
            <p>Consultez et gérez toutes vos réservations de covoiturage</p>
        </div>
        
        <!-- Messages de succès/erreur -->
        <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= successMessage %>
                <%
                    // Supprimer le message après affichage
                    session.removeAttribute("successMessage");
                %>
            </div>
        <% } %>
        
        <% if (erreur != null && !erreur.isEmpty()) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= erreur %>
            </div>
        <% } %>
        
        <!-- Statistiques -->
        <% if (reservations != null && !reservations.isEmpty()) { 
            int totalReservations = reservations.size();
            int enAttente = 0;
            int confirmees = 0;
            int annulees = 0;
            int terminees = 0;
            
            for (Reservation r : reservations) {
                switch (r.getStatut()) {
                    case "EN_ATTENTE": enAttente++; break;
                    case "CONFIRMEE": confirmees++; break;
                    case "ANNULEE": annulees++; break;
                    case "TERMINEE": terminees++; break;
                }
            }
        %>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon" style="color: #4a6cf7;">
                    <i class="fas fa-list-alt"></i>
                </div>
                <div class="stat-value"><%= totalReservations %></div>
                <div class="stat-label">Réservations totales</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon" style="color: #48bb78;">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-value"><%= confirmees %></div>
                <div class="stat-label">Confirmées</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon" style="color: #ed8936;">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-value"><%= enAttente %></div>
                <div class="stat-label">En attente</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon" style="color: #f56565;">
                    <i class="fas fa-times-circle"></i>
                </div>
                <div class="stat-value"><%= annulees %></div>
                <div class="stat-label">Annulées</div>
            </div>
        </div>
        <% } %>
        
        <!-- Tableau des réservations -->
        <div class="reservations-container">
            <div class="table-header">
                <h3>Liste de vos réservations</h3>
                <div class="table-controls">
                    <select class="filter-select" id="statusFilter">
                        <option value="">Tous les statuts</option>
                        <option value="EN_ATTENTE">En attente</option>
                        <option value="CONFIRMEE">Confirmées</option>
                        <option value="ANNULEE">Annulées</option>
                        <option value="TERMINEE">Terminées</option>
                    </select>
                </div>
            </div>
            
            <% if (reservations != null && !reservations.isEmpty()) { %>
            <div style="overflow-x: auto;">
                <table class="reservations-table">
                    <thead>
                        <tr>
                            <th>Trajet</th>
                            <th>Date du trajet</th>
                            <th>Date réservation</th>
                            <th>Prix</th>
                            <th>Statut</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Reservation reservation : reservations) { 
                            String statusClass = "";
                            String statusText = "";
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
                        %>
                        <tr>
                            <td>
                                <strong><%= reservation.getDepart() %> → <%= reservation.getDestination() %></strong><br>
                                <small style="color: #718096;">
                                    <i class="fas fa-user-tie"></i> 
                                    Conducteur: <%= reservation.getConducteurPrenom() %> <%= reservation.getConducteurNom() %>
                                </small>
                            </td>
                            <td>
                                <i class="far fa-calendar"></i> <%= sdfDate.format(reservation.getDateDepart()) %><br>
                                <i class="far fa-clock"></i> <%= sdfTime.format(reservation.getDateDepart()) %>
                            </td>
                            <td>
                                <%= sdfFull.format(reservation.getDateReservation()) %>
                            </td>
                            <td>
                                <strong><%= String.format("%.2f", reservation.getPrixTotal()) %> DT</strong>
                            </td>
                            <td>
                                <span class="status-badge <%= statusClass %>">
                                    <%= statusText %>
                                </span>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="reservations?action=details&reservationId=<%= reservation.getId() %>" 
                                       class="btn btn-details">
                                        <i class="fas fa-eye"></i> Détails
                                    </a>
                                    
                                    <% if (!"ANNULEE".equals(reservation.getStatut()) && !"TERMINEE".equals(reservation.getStatut())) { %>
                                    <a href="reservations?action=annuler&reservationId=<%= reservation.getId() %>" 
                                       class="btn btn-cancel"
                                       onclick="return confirm('Êtes-vous sûr de vouloir annuler cette réservation ?')">
                                        <i class="fas fa-times"></i> Annuler
                                    </a>
                                    <% } %>
                                    
                                    <% if ("CONFIRMEE".equals(reservation.getStatut())) { %>
                                    <a href="trajets?action=details&id=<%= reservation.getTrajetId() %>" 
                                       class="btn btn-view">
                                        <i class="fas fa-road"></i> Voir trajet
                                    </a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } else { %>
            <div class="empty-state">
                <i class="fas fa-calendar-times"></i>
                <h3>Aucune réservation</h3>
                <p>Vous n'avez pas encore effectué de réservation.</p>
                <a href="trajets" class="btn-primary">
                    <i class="fas fa-search"></i> Rechercher un trajet
                </a>
            </div>
            <% } %>
        </div>
    </div>
    
    <!-- JavaScript pour le filtrage -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const statusFilter = document.getElementById('statusFilter');
            const tableRows = document.querySelectorAll('.reservations-table tbody tr');
            
            if (statusFilter && tableRows.length > 0) {
                statusFilter.addEventListener('change', function() {
                    const selectedStatus = this.value;
                    
                    tableRows.forEach(row => {
                        const statusCell = row.querySelector('.status-badge');
                        if (statusCell) {
                            const rowStatus = statusCell.textContent.trim();
                            
                            // Mapping entre le texte affiché et les valeurs du filtre
                            const statusMapping = {
                                'En attente': 'EN_ATTENTE',
                                'Confirmée': 'CONFIRMEE',
                                'Annulée': 'ANNULEE',
                                'Terminée': 'TERMINEE'
                            };
                            
                            if (selectedStatus === '' || statusMapping[rowStatus] === selectedStatus) {
                                row.style.display = '';
                            } else {
                                row.style.display = 'none';
                            }
                        }
                    });
                });
            }
            
            // Confirmation pour l'annulation
            const cancelButtons = document.querySelectorAll('.btn-cancel');
            cancelButtons.forEach(button => {
                button.addEventListener('click', function(e) {
                    if (!confirm('Êtes-vous sûr de vouloir annuler cette réservation ?')) {
                        e.preventDefault();
                    }
                });
            });
        });
    </script>
</body>
</html>