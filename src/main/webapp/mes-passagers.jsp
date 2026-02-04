<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="com.covoiturage.model.Reservation" %>
<%@ page import="com.covoiturage.model.Trajet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Vérifier si l'utilisateur est connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    // Vérifier que l'utilisateur est conducteur
    if (!"CONDUCTEUR".equals(utilisateur.getRole())) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    Trajet trajet = (Trajet) request.getAttribute("trajet");
    Boolean filtreTrajet = (Boolean) request.getAttribute("filtreTrajet");
    String erreur = (String) request.getAttribute("erreur");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes passagers - Covoiturage</title>
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
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .page-header h2 {
            color: #2d3748;
            font-size: 1.8rem;
            display: flex;
            align-items: center;
            gap: 10px;
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
        
        .btn-danger {
            background: #f56565;
        }
        
        .btn-danger:hover {
            background: #e53e3e;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 0.85rem;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: #c6f6d5;
            color: #22543d;
            border-left: 4px solid #48bb78;
        }
        
        .alert-error {
            background: #fed7d7;
            color: #9b2c2c;
            border-left: 4px solid #f56565;
        }
        
        .filters {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 25px;
            box-shadow: 0 3px 15px rgba(0,0,0,0.05);
        }
        
        .filter-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .filter-title {
            color: #2d3748;
            font-weight: 500;
        }
        
        .filter-options {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .filter-btn {
            padding: 8px 16px;
            background: #e2e8f0;
            color: #4a5568;
            border: none;
            border-radius: 20px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s;
        }
        
        .filter-btn:hover, .filter-btn.active {
            background: #4a6cf7;
            color: white;
        }
        
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 3px 15px rgba(0,0,0,0.05);
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
        
        .reservations-table {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 3px 15px rgba(0,0,0,0.05);
        }
        
        .table-header {
            display: grid;
            grid-template-columns: 2fr 2fr 1fr 1fr 1fr 1fr 1fr;
            background: #f7fafc;
            padding: 15px 20px;
            border-bottom: 2px solid #e2e8f0;
            font-weight: 600;
            color: #4a5568;
        }
        
        .table-row {
            display: grid;
            grid-template-columns: 2fr 2fr 1fr 1fr 1fr 1fr 1fr;
            padding: 15px 20px;
            border-bottom: 1px solid #e2e8f0;
            align-items: center;
            transition: background 0.2s;
        }
        
        .table-row:hover {
            background: #f7fafc;
        }
        
        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
            text-align: center;
        }
        
        .status-en_attente {
            background: #fef3c7;
            color: #92400e;
        }
        
        .status-confirmee {
            background: #d1fae5;
            color: #065f46;
        }
        
        .status-annulee {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
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
        
        .passager-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .passager-avatar {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #4a6cf7, #8a63d2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 0.9rem;
        }
        
        .passager-details h4 {
            color: #2d3748;
            margin-bottom: 2px;
        }
        
        .passager-details p {
            color: #718096;
            font-size: 0.85rem;
        }
        
        .trajet-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .trajet-route {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .route-depart, .route-arrivee {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 0.9rem;
        }
        /* Styles pour les évaluations */
.evaluation-form {
    background: #f7fafc;
    border-radius: 10px;
    padding: 20px;
    margin-top: 15px;
    border-left: 4px solid #48bb78;
    display: none;
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

.evaluation-modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
}

.evaluation-modal-content {
    background-color: white;
    margin: 15% auto;
    padding: 30px;
    border-radius: 12px;
    width: 90%;
    max-width: 500px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
}

.modal-actions {
    display: flex;
    gap: 10px;
    margin-top: 20px;
}

.evaluated-badge {
    background: #c6f6d5;
    color: #22543d;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.8rem;
    display: inline-flex;
    align-items: center;
    gap: 5px;
}
        
        @media (max-width: 992px) {
            .table-header, .table-row {
                grid-template-columns: 2fr 2fr 1fr 1fr 1fr;
            }
            
            .table-header .mobile-hidden,
            .table-row .mobile-hidden {
                display: none;
            }
        }
        
        @media (max-width: 768px) {
            .header {
                padding: 15px 20px;
                flex-direction: column;
                gap: 20px;
            }
            
            .page-header {
                flex-direction: column;
                gap: 15px;
                align-items: flex-start;
            }
            
            .stats-cards {
                grid-template-columns: 1fr 1fr;
            }
            
            .table-header, .table-row {
                grid-template-columns: 1fr;
                gap: 10px;
            }
            
            .table-header {
                display: none;
            }
            
            .table-row {
                padding: 20px;
            }
            
            .actions {
                justify-content: flex-start;
            }
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="logo">
            <i class="fas fa-users"></i>
            <h1>Mes passagers</h1>
        </div>
        <div>
            <a href="dashboard.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Retour au dashboard
            </a>
        </div>
    </header>
    
    <div class="container">
        <!-- Messages -->
        <%
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
        %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> <%= successMessage %>
        </div>
        <%
                session.removeAttribute("successMessage");
            }
            
            if (erreur != null && !erreur.isEmpty()) {
        %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i> <%= erreur %>
        </div>
        <% } %>
        
        <!-- Page Header -->
        <div class="page-header">
            <h2>
                <i class="fas fa-user-friends"></i>
                <% if (trajet != null) { %>
                    Passagers du trajet : <%= trajet.getDepart() %> → <%= trajet.getDestination() %>
                <% } else { %>
                    Tous mes passagers
                <% } %>
            </h2>
            <div>
                <a href="trajets?action=mes-trajets" class="btn">
                    <i class="fas fa-road"></i> Voir mes trajets
                </a>
            </div>
        </div>
        
        <!-- Filters -->
        <div class="filters">
            <div class="filter-header">
                <div class="filter-title">
                    <i class="fas fa-filter"></i> Filtres
                </div>
                <div>
                    <% if (trajet != null) { %>
                        <a href="passagers" class="btn btn-sm">
                            Voir tous les passagers
                        </a>
                    <% } %>
                </div>
            </div>
            <div class="filter-options">
                <button class="filter-btn active" onclick="filterByStatus('all')">
                    Tous les statuts
                </button>
                <button class="filter-btn" onclick="filterByStatus('EN_ATTENTE')">
                    En attente
                </button>
                <button class="filter-btn" onclick="filterByStatus('CONFIRMEE')">
                    Confirmées
                </button>
                <button class="filter-btn" onclick="filterByStatus('ANNULEE')">
                    Annulées
                </button>
            </div>
        </div>
        
        <!-- Stats Cards -->
        <% 
            int totalReservations = reservations != null ? reservations.size() : 0;
            int enAttenteCount = 0;
            int confirmeesCount = 0;
            int annuleesCount = 0;
            
            if (reservations != null) {
                for (Reservation r : reservations) {
                    if ("EN_ATTENTE".equals(r.getStatut())) enAttenteCount++;
                    else if ("CONFIRMEE".equals(r.getStatut())) confirmeesCount++;
                    else if ("ANNULEE".equals(r.getStatut())) annuleesCount++;
                }
            }
        %>
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value"><%= totalReservations %></div>
                <div class="stat-label">Réservations totales</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= enAttenteCount %></div>
                <div class="stat-label">En attente</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= confirmeesCount %></div>
                <div class="stat-label">Confirmées</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= annuleesCount %></div>
                <div class="stat-label">Annulées</div>
            </div>
        </div>
        
        <!-- Reservations Table -->
        <div class="reservations-table">
            <div class="table-header">
                <div>Passager</div>
                <div>Trajet</div>
                <div>Date réservation</div>
                <div>Date départ</div>
                <div>Prix</div>
                <div>Statut</div>
                <div>Actions</div>
            </div>
            
            <% if (reservations != null && !reservations.isEmpty()) { %>
                <% for (Reservation reservation : reservations) { %>
                    <div class="table-row" data-status="<%= reservation.getStatut() %>">
                        <!-- Passager -->
                        <div class="passager-info">
                            <div class="passager-avatar">
                                <%= reservation.getPassagerPrenom().charAt(0) %><%= reservation.getPassagerNom().charAt(0) %>
                            </div>
                            <div class="passager-details">
                                <h4><%= reservation.getPassagerPrenom() %> <%= reservation.getPassagerNom() %></h4>
                                <p><%= reservation.getPassagerEmail() %></p>
                                <p><i class="fas fa-phone"></i> <%= reservation.getPassagerTelephone() %></p>
                            </div>
                        </div>
                        
                        <!-- Trajet -->
                        <div class="trajet-info">
                            <div class="trajet-route">
                                <div class="route-depart">
                                    <i class="fas fa-map-marker-alt" style="color: #48bb78;"></i>
                                    <span><%= reservation.getDepart() %></span>
                                </div>
                                <div class="route-arrivee">
                                    <i class="fas fa-flag-checkered" style="color: #f56565;"></i>
                                    <span><%= reservation.getDestination() %></span>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Date réservation -->
                        <div>
                            <%= sdf.format(reservation.getDateReservation()) %>
                        </div>
                        
                        <!-- Date départ -->
                        <div>
                            <%= reservation.getDateDepart() != null ? sdf.format(reservation.getDateDepart()) : "N/A" %>
                        </div>
                        
                        <!-- Prix -->
                        <div>
                            <strong><%= reservation.getPrixTotal() != null ? reservation.getPrixTotal() + " DT" : "N/A" %></strong>
                        </div>
                        
                        <!-- Statut -->
                        <div>
                            <% 
                                String statusClass = "";
                                String statusText = "";
                                switch(reservation.getStatut()) {
                                    case "EN_ATTENTE":
                                        statusClass = "status-en_attente";
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
                                    default:
                                        statusClass = "status-en_attente";
                                        statusText = reservation.getStatut();
                                }
                            %>
                            <span class="status-badge <%= statusClass %>">
                                <%= statusText %>
                            </span>
                        </div>
                        
                       <!-- Actions -->
<div class="actions">
   <a href="passagers?action=details&reservationId=<%= reservation.getId() %>" 
   class="btn btn-sm btn-secondary" title="Voir détails">
    <i class="fas fa-eye"></i>
</a>
    
    <% if ("EN_ATTENTE".equals(reservation.getStatut())) { %>
        <a href="passagers?action=confirmer&reservationId=<%= reservation.getId() %>" 
           class="btn btn-sm btn-success" 
           onclick="return confirm('Êtes-vous sûr de vouloir confirmer cette réservation ?')"
           title="Confirmer">
            <i class="fas fa-check"></i>
        </a>
        
        <a href="passagers?action=annuler&reservationId=<%= reservation.getId() %>" 
           class="btn btn-sm btn-danger"
           onclick="return confirm('Êtes-vous sûr de vouloir annuler cette réservation ?')"
           title="Refuser">
            <i class="fas fa-times"></i>
        </a>
    <% } %>
    
    <% if ("CONFIRMEE".equals(reservation.getStatut())) { %>
        <a href="passagers?action=annuler&reservationId=<%= reservation.getId() %>" 
           class="btn btn-sm btn-danger"
           onclick="return confirm('Êtes-vous sûr de vouloir annuler cette réservation confirmée ?')"
           title="Annuler">
            <i class="fas fa-ban"></i>
        </a>
    <% } %>
    
    <!-- Bouton Évaluer le passager -->
    <% 
        boolean peutEvaluer = "CONFIRMEE".equals(reservation.getStatut()) || 
                               "TERMINEE".equals(reservation.getStatut());
        boolean dejaEvalue = false; // Vous devrez vérifier avec avisDAO
        
        if (peutEvaluer) { 
    %>
        <% if (!dejaEvalue) { %>
            <button class="btn btn-sm btn-primary evaluer-passager-btn" 
                    onclick="openEvaluationModal('<%= reservation.getId() %>', 
                                                '<%= reservation.getPassagerId() %>', 
                                                '<%= reservation.getTrajetId() %>', 
                                                '<%= reservation.getPassagerPrenom() %> <%= reservation.getPassagerNom() %>')"
                    title="Évaluer le passager">
                <i class="fas fa-star"></i> Évaluer
            </button>
        <% } else { %>
            <span class="evaluated-badge">
                <i class="fas fa-check"></i> Évalué
            </span>
        <% } %>
    <% } %>
</div>

<!-- Formulaire d'évaluation du passager (caché par défaut) -->
<div class="evaluation-form" id="eval-passager-form-<%= reservation.getId() %>" style="display: none;">
    <h4><i class="fas fa-star"></i> Évaluer <%= reservation.getPassagerPrenom() %> <%= reservation.getPassagerNom() %></h4>
    <form action="evaluations" method="post">
        <input type="hidden" name="action" value="evaluerPassager">
        <input type="hidden" name="trajetId" value="<%= reservation.getTrajetId() %>">
        <input type="hidden" name="passagerId" value="<%= reservation.getPassagerId() %>">
        <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
        <input type="hidden" name="note" id="note-passager-<%= reservation.getId() %>" value="5">
        
        <p style="margin-bottom: 15px; color: #718096;">
            Évaluez le passager pour le trajet : 
            <strong><%= reservation.getDepart() %> → <%= reservation.getDestination() %></strong>
        </p>
        
        <div class="rating-stars" id="stars-passager-<%= reservation.getId() %>">
            <% for (int i = 1; i <= 5; i++) { %>
            <span class="star <%= i <= 5 ? "active" : "" %>" 
                  data-value="<%= i %>"
                  onclick="setPassagerRating('<%= reservation.getId() %>', <%= i %>)">
                <i class="fas fa-star"></i>
            </span>
            <% } %>
        </div>
        
        <textarea name="commentaire" class="form-control" 
                  placeholder="Commentaire sur le passager (poli, ponctuel, agréable...)" 
                  rows="3" required style="margin-top: 15px;"></textarea>
        
        <div style="display: flex; gap: 10px; margin-top: 20px;">
            <button type="submit" class="btn btn-primary">
                <i class="fas fa-paper-plane"></i> Envoyer l'évaluation
            </button>
            <button type="button" class="btn btn-secondary" 
                    onclick="closeEvaluationForm('<%= reservation.getId() %>')">
                <i class="fas fa-times"></i> Annuler
            </button>
        </div>
    </form>
</div>
                    </div>
                <% } %>
            <% } else { %>
                <div class="empty-state">
                    <i class="fas fa-users-slash"></i>
                    <h3>Aucune réservation trouvée</h3>
                    <p>
                        <% if (trajet != null) { %>
                            Aucun passager n'a encore réservé de place sur ce trajet.
                        <% } else { %>
                            Vous n'avez pas encore de réservations pour vos trajets.
                        <% } %>
                    </p>
                    <a href="trajets?action=mes-trajets" class="btn" style="margin-top: 15px;">
                        <i class="fas fa-road"></i> Voir mes trajets
                    </a>
                </div>
            <% } %>
        </div>
    </div>
    
    <script>
        // Filtrage par statut
        function filterByStatus(status) {
            const rows = document.querySelectorAll('.table-row');
            const filterBtns = document.querySelectorAll('.filter-btn');
            
            // Mettre à jour les boutons actifs
            filterBtns.forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
            
            // Filtrer les lignes
            rows.forEach(row => {
                if (status === 'all' || row.dataset.status === status) {
                    row.style.display = 'grid';
                } else {
                    row.style.display = 'none';
                }
            });
        }
        
        // Confirmation pour les actions critiques
        function confirmAction(message) {
            return confirm(message || 'Êtes-vous sûr de vouloir effectuer cette action ?');
        }
     // Fonctions pour les évaluations de passagers
        function openEvaluationModal(reservationId, passagerId, trajetId, passagerNom) {
            // Remplir les champs du formulaire modal
            document.getElementById('modalReservationId').value = reservationId;
            document.getElementById('modalPassagerId').value = passagerId;
            document.getElementById('modalTrajetId').value = trajetId;
            
            // Afficher les infos du passager
            document.getElementById('modalPassagerInfo').innerHTML = `
                <h4 style="margin-bottom: 5px;">${passagerNom}</h4>
                <p style="color: #718096; font-size: 0.9rem;">
                    <i class="fas fa-info-circle"></i> Évaluation du passager pour cette réservation
                </p>
            `;
            
            // Réinitialiser le formulaire
            document.getElementById('modalNote').value = 5;
            document.getElementById('modalCommentaire').value = '';
            
            // Réinitialiser les étoiles
            const stars = document.querySelectorAll('#modalStars .star');
            stars.forEach((star, index) => {
                if (index < 5) {
                    star.classList.add('active');
                } else {
                    star.classList.remove('active');
                }
            });
            
            // Afficher la modale
            document.getElementById('evaluationModal').style.display = 'block';
        }

        function closeModal() {
            document.getElementById('evaluationModal').style.display = 'none';
        }

        function setModalRating(rating) {
            const stars = document.querySelectorAll('#modalStars .star');
            const noteInput = document.getElementById('modalNote');
            
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

        // Fonctions pour les formulaires inline
        function setPassagerRating(reservationId, rating) {
            const stars = document.querySelectorAll('#stars-passager-' + reservationId + ' .star');
            const noteInput = document.getElementById('note-passager-' + reservationId);
            
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

        function openEvaluationForm(reservationId) {
            const form = document.getElementById('eval-passager-form-' + reservationId);
            const button = document.querySelector(`[onclick*="openEvaluationForm('${reservationId}')"]`);
            
            if (form && button) {
                form.style.display = 'block';
                button.innerHTML = '<i class="fas fa-times"></i> Annuler';
                button.classList.remove('btn-primary');
                button.classList.add('btn-secondary');
                button.setAttribute('onclick', `closeEvaluationForm('${reservationId}')`);
            }
        }

        function closeEvaluationForm(reservationId) {
            const form = document.getElementById('eval-passager-form-' + reservationId);
            const button = document.querySelector(`[onclick*="closeEvaluationForm('${reservationId}')"]`);
            
            if (form && button) {
                form.style.display = 'none';
                button.innerHTML = '<i class="fas fa-star"></i> Évaluer';
                button.classList.remove('btn-secondary');
                button.classList.add('btn-primary');
                button.setAttribute('onclick', `openEvaluationForm('${reservationId}')`);
            }
        }

        // Fermer la modale si on clique en dehors
        window.onclick = function(event) {
            const modal = document.getElementById('evaluationModal');
            if (event.target == modal) {
                closeModal();
            }
        }
    </script>
    <!-- Modal d'évaluation -->
<div id="evaluationModal" class="evaluation-modal">
    <div class="evaluation-modal-content">
        <h3 style="margin-bottom: 15px; color: #2d3748;">
            <i class="fas fa-star"></i> Évaluer un passager
        </h3>
        
        <div id="modalPassagerInfo" style="margin-bottom: 20px; padding: 15px; background: #f7fafc; border-radius: 8px;">
            <!-- Les infos seront injectées ici par JavaScript -->
        </div>
        
        <form id="modalEvaluationForm" action="evaluations" method="post">
            <input type="hidden" name="action" value="evaluerPassager">
            <input type="hidden" id="modalTrajetId" name="trajetId">
            <input type="hidden" id="modalPassagerId" name="passagerId">
            <input type="hidden" id="modalReservationId" name="reservationId">
            <input type="hidden" id="modalNote" name="note" value="5">
            
            <div class="rating-stars" id="modalStars">
                <% for (int i = 1; i <= 5; i++) { %>
                <span class="star <%= i <= 5 ? "active" : "" %>" 
                      data-value="<%= i %>"
                      onclick="setModalRating(<%= i %>)">
                    <i class="fas fa-star"></i>
                </span>
                <% } %>
            </div>
            
            <textarea name="commentaire" id="modalCommentaire" class="form-control" 
                      placeholder="Commentaire sur le passager (poli, ponctuel, agréable...)" 
                      rows="3" required style="margin-top: 15px;"></textarea>
            
            <div class="modal-actions">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-paper-plane"></i> Envoyer l'évaluation
                </button>
                <button type="button" class="btn btn-secondary" onclick="closeModal()">
                    <i class="fas fa-times"></i> Annuler
                </button>
            </div>
        </form>
    </div>
</div>
</body>
</html>