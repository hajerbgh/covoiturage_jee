<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Trajet" %>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Vérifier si l'utilisateur est connecté et est conducteur
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    if (!"CONDUCTEUR".equals(utilisateur.getRole())) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    // DEBUG: Afficher dans la console serveur
    System.out.println("=== JSP MES-TRAJETS ===");
    System.out.println("Utilisateur ID: " + utilisateur.getId());
    System.out.println("Utilisateur nom: " + utilisateur.getNom() + " " + utilisateur.getPrenom());
    System.out.println("Utilisateur rôle: " + utilisateur.getRole());
    
    // Vérifier TOUS les attributs de la requête
    java.util.Enumeration<String> attribs = request.getAttributeNames();
    System.out.println("Attributs disponibles dans la requête:");
    while (attribs.hasMoreElements()) {
        String attrName = attribs.nextElement();
        Object attrValue = request.getAttribute(attrName);
        System.out.println("  - " + attrName + " = " + attrValue);
        if (attrValue instanceof java.util.List) {
            System.out.println("    (Liste de " + ((java.util.List<?>) attrValue).size() + " éléments)");
        }
    }
    
    // Essayer plusieurs noms d'attributs possibles
    List<Trajet> mesTrajets = null;
    
    // Essayer "trajets" (nom utilisé dans le servlet)
    mesTrajets = (List<Trajet>) request.getAttribute("trajets");
    System.out.println("Attribut 'trajets' trouvé? " + (mesTrajets != null));
    if (mesTrajets != null) {
        System.out.println("Nombre de trajets dans 'trajets': " + mesTrajets.size());
    }
    
    // Si "trajets" est null, essayer "mesTrajets"
    if (mesTrajets == null) {
        mesTrajets = (List<Trajet>) request.getAttribute("mesTrajets");
        System.out.println("Attribut 'mesTrajets' trouvé? " + (mesTrajets != null));
        if (mesTrajets != null) {
            System.out.println("Nombre de trajets dans 'mesTrajets': " + mesTrajets.size());
        }
    }
    
    // Si toujours null, essayer d'autres noms
    if (mesTrajets == null) {
        mesTrajets = (List<Trajet>) request.getAttribute("listTrajets");
        System.out.println("Attribut 'listTrajets' trouvé? " + (mesTrajets != null));
    }
    
    // DEBUG dans la page HTML
    out.println("<!-- DEBUG: Utilisateur ID = " + utilisateur.getId() + " -->");
    out.println("<!-- DEBUG: Attribut 'trajets' = " + (request.getAttribute("trajets") != null) + " -->");
    out.println("<!-- DEBUG: mesTrajets variable = " + (mesTrajets != null) + " -->");
    out.println("<!-- DEBUG: Nombre trajets = " + (mesTrajets != null ? mesTrajets.size() : 0) + " -->");
    
    // TEST: Créer un trajet de test si aucun n'est trouvé
    if (mesTrajets == null) {
        System.out.println("⚠️ Aucun attribut de trajet trouvé - création liste vide");
        mesTrajets = new java.util.ArrayList<>();
    }
    
    String message = (String) request.getAttribute("message");
    String erreur = (String) request.getAttribute("erreur");
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    Integer totalPassagersAttr = (Integer) request.getAttribute("totalPassagers");
    // Statistiques
    int totalTrajets = mesTrajets != null ? mesTrajets.size() : 0;
    int trajetsActifs = 0;
    int trajetsComplets = 0;
    int trajetsAnnules = 0;
    int placesReserveesTotal = totalPassagersAttr != null ? totalPassagersAttr : 0;
    
    if (mesTrajets != null) {
        for (Trajet trajet : mesTrajets) {
            if ("ACTIF".equals(trajet.getStatut())) trajetsActifs++;
            if ("TERMINE".equals(trajet.getStatut())) trajetsComplets++;
            if ("ANNULE".equals(trajet.getStatut())) trajetsAnnules++;
            // Note: Vous devrez ajouter une méthode pour calculer les places réservées
        }
    }
    
    System.out.println("=== FIN DEBUG JSP ===");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes Trajets - Covoiturage</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Styles hérités du dashboard */
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
        
        /* Header identique au dashboard */
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
        
        .logo-text h1 {
            color: #2d3748;
            font-size: 1.8rem;
            margin-bottom: 5px;
        }
        
        .logo-text p {
            color: #718096;
            font-size: 0.9rem;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .user-avatar {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #4a6cf7, #8a63d2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.3rem;
            font-weight: bold;
        }
        
        .user-details h3 {
            color: #2d3748;
            margin-bottom: 5px;
        }
        
        .user-details p {
            color: #718096;
            font-size: 0.9rem;
        }
        
        .role-badge {
            display: inline-block;
            padding: 4px 12px;
            background: #4CAF50;
            color: white;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .logout-btn {
            padding: 10px 25px;
            background: #f56565;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 500;
            transition: background 0.3s;
        }
        
        .logout-btn:hover {
            background: #e53e3e;
        }
        
        /* Main Content */
        .container {
            max-width: 1400px;
            margin: 0 auto 40px;
            padding: 0 20px;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .page-header h1 {
            color: #2d3748;
            font-size: 2rem;
        }
        
        .page-header .actions {
            display: flex;
            gap: 15px;
        }
        
        .btn {
            padding: 12px 25px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: #4a6cf7;
            color: white;
        }
        
        .btn-primary:hover {
            background: #3a5bd9;
            transform: translateY(-2px);
        }
        
        .btn-secondary {
            background: #718096;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #5a6c82;
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
            box-shadow: 0 3px 15px rgba(0,0,0,0.05);
            text-align: center;
            transition: transform 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-3px);
        }
        
        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 15px;
        }
        
        .stat-card.total .stat-icon { color: #4a6cf7; }
        .stat-card.active .stat-icon { color: #4CAF50; }
        .stat-card.complete .stat-icon { color: #FF9800; }
        .stat-card.cancelled .stat-icon { color: #f56565; }
        .stat-card.passengers .stat-icon { color: #9C27B0; }
        
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
            color: #22543d;
            border-left: 4px solid #48bb78;
        }
        
        .alert-error {
            background: #fed7d7;
            color: #9b2c2c;
            border-left: 4px solid #f56565;
        }
        
        /* Table des trajets */
        .trajets-table-container {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            margin-top: 20px;
        }
        
        .table-header {
            background: #f7fafc;
            padding: 20px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .table-header h3 {
            color: #2d3748;
            font-size: 1.3rem;
        }
        
        .search-box {
            position: relative;
        }
        
        .search-box input {
            padding: 10px 15px 10px 40px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            width: 250px;
            font-size: 14px;
        }
        
        .search-box i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #a0aec0;
        }
        
        .trajets-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .trajets-table th {
            background: #f7fafc;
            padding: 15px 20px;
            text-align: left;
            color: #4a5568;
            font-weight: 600;
            font-size: 0.9rem;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .trajets-table td {
            padding: 15px 20px;
            border-bottom: 1px solid #e2e8f0;
            color: #4a5568;
        }
        
        .trajets-table tr:hover {
            background: #f7fafc;
        }
        
        /* Status badges */
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .status-active {
            background: #c6f6d5;
            color: #22543d;
        }
        
        .status-complete {
            background: #feebc8;
            color: #744210;
        }
        
        .status-cancelled {
            background: #fed7d7;
            color: #9b2c2c;
        }
        
        .status-finished {
            background: #e9d8fd;
            color: #44337a;
        }
        
        /* Action buttons */
        .action-buttons {
            display: flex;
            gap: 8px;
        }
        
        .btn-small {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.85rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.2s;
        }
        
        .btn-view {
            background: #4a6cf7;
            color: white;
        }
        
        .btn-view:hover {
            background: #3a5bd9;
        }
        
        .btn-edit {
            background: #38b2ac;
            color: white;
        }
        
        .btn-edit:hover {
            background: #319795;
        }
        
        .btn-cancel {
            background: #f56565;
            color: white;
        }
        
        .btn-cancel:hover {
            background: #e53e3e;
        }
        
        .btn-passengers {
            background: #9C27B0;
            color: white;
        }
        
        .btn-passengers:hover {
            background: #822a90;
        }
        
        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 50px 20px;
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
        
        /* Filter tabs */
        .filter-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .filter-tab {
            padding: 10px 20px;
            background: white;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .filter-tab:hover {
            border-color: #4a6cf7;
            color: #4a6cf7;
        }
        
        .filter-tab.active {
            background: #4a6cf7;
            color: white;
            border-color: #4a6cf7;
        }
        
        /* Responsive */
        @media (max-width: 1024px) {
            .trajets-table {
                display: block;
                overflow-x: auto;
            }
            
            .table-header {
                flex-direction: column;
                gap: 15px;
                align-items: stretch;
            }
            
            .search-box input {
                width: 100%;
            }
        }
        
        @media (max-width: 768px) {
            .header {
                padding: 15px 20px;
                flex-direction: column;
                gap: 20px;
            }
            
            .user-info {
                flex-direction: column;
                text-align: center;
            }
            
            .page-header {
                flex-direction: column;
                align-items: stretch;
            }
            
            .page-header .actions {
                justify-content: center;
            }
            
            .action-buttons {
                flex-wrap: wrap;
            }
        }
    </style>
</head>
<body>
    <!-- Header identique au dashboard -->
    <header class="header">
        <div class="logo">
            <i class="fas fa-car"></i>
            <div class="logo-text">
                <h1>Covoiturage App</h1>
                <p>Partagez vos trajets, économisez ensemble</p>
            </div>
        </div>
        
        <div class="user-info">
            <div class="user-avatar">
                <%= utilisateur.getPrenom().charAt(0) %><%= utilisateur.getNom().charAt(0) %>
            </div>
            <div class="user-details">
                <h3><%= utilisateur.getPrenom() %> <%= utilisateur.getNom() %></h3>
                <p><%= utilisateur.getEmail() %></p>
                <span class="role-badge">
                    🚗 Conducteur
                </span>
            </div>
            <a href="deconnexion" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i> Déconnexion
            </a>
        </div>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1><i class="fas fa-road"></i> Mes Trajets</h1>
            <div class="actions">
                <a href="dashboard.jsp" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Retour au dashboard
                </a>
                <a href="trajets?action=creer" class="btn btn-primary">
                    <i class="fas fa-plus-circle"></i> Nouveau trajet
                </a>
            </div>
        </div>
        
        <!-- Messages -->
        <% if (message != null && !message.isEmpty()) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> <%= message %>
        </div>
        <% } %>
        
        <% if (erreur != null && !erreur.isEmpty()) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i> <%= erreur %>
        </div>
        <% } %>
        
        <!-- Statistiques -->
        <div class="stats-grid">
            <div class="stat-card total">
                <div class="stat-icon">
                    <i class="fas fa-road"></i>
                </div>
                <div class="stat-value"><%= totalTrajets %></div>
                <div class="stat-label">Trajets totaux</div>
            </div>
            
            <div class="stat-card active">
                <div class="stat-icon">
                    <i class="fas fa-play-circle"></i>
                </div>
                <div class="stat-value"><%= trajetsActifs %></div>
                <div class="stat-label">Trajets actifs</div>
            </div>
            
            <div class="stat-card complete">
                <div class="stat-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-value"><%= trajetsComplets %></div>
                <div class="stat-label">Trajets complets</div>
            </div>
            
            <div class="stat-card cancelled">
                <div class="stat-icon">
                    <i class="fas fa-times-circle"></i>
                </div>
                <div class="stat-value"><%= trajetsAnnules %></div>
                <div class="stat-label">Trajets annulés</div>
            </div>
            
            <div class="stat-card passengers">
                <div class="stat-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-value"><%= placesReserveesTotal %></div>
                <div class="stat-label">Passagers totaux</div>
            </div>
        </div>
        
        <!-- Filtres -->
        <div class="filter-tabs">
            <div class="filter-tab active" onclick="filterTrajets('all')">
                <i class="fas fa-list"></i> Tous (<%= totalTrajets %>)
            </div>
            <div class="filter-tab" onclick="filterTrajets('ACTIF')">
                <i class="fas fa-play-circle"></i> Actifs (<%= trajetsActifs %>)
            </div>
            <div class="filter-tab" onclick="filterTrajets('COMPLET')">
                <i class="fas fa-check-circle"></i> Complets (<%= trajetsComplets %>)
            </div>
            <div class="filter-tab" onclick="filterTrajets('ANNULE')">
                <i class="fas fa-times-circle"></i> Annulés (<%= trajetsAnnules %>)
            </div>
        </div>
        
        <!-- Table des trajets -->
        <div class="trajets-table-container">
            <div class="table-header">
                <h3><i class="fas fa-list-ul"></i> Liste de mes trajets</h3>
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Rechercher un trajet...">
                </div>
            </div>
            
            <% if (mesTrajets != null && !mesTrajets.isEmpty()) { %>
            <table class="trajets-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Itinéraire</th>
                        <th>Date/Heure</th>
                        <th>Prix</th>
                        <th>Places</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="trajetsTableBody">
                    <% for (Trajet trajet : mesTrajets) { %>
                    <tr class="trajet-row" data-status="<%= trajet.getStatut() %>">
                        <td>#<%= trajet.getId() %></td>
                        <td>
                            <div style="font-weight: 500;"><%= trajet.getDepart() %></div>
                            <div style="font-size: 0.9rem; color: #718096;">
                                <i class="fas fa-long-arrow-alt-right"></i> <%= trajet.getDestination() %>
                            </div>
                        </td>
                        <td>
                            <%= sdf.format(trajet.getDateDepart()) %>
                        </td>
                        <td style="font-weight: bold; color: #2d3748;">
                            <%= String.format("%.2f", trajet.getPrix()) %> DT
                        </td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 5px;">
                                <i class="fas fa-users" style="color: #718096;"></i>
                                <span><%= trajet.getPlacesDisponibles() %> places</span>
                            </div>
                        </td>
                        <td>
                            <% 
                                String statusClass = "";
                                String statusIcon = "";
                                switch(trajet.getStatut()) {
                                    case "ACTIF":
                                        statusClass = "status-active";
                                        statusIcon = "fas fa-play-circle";
                                        break;
                                    case "COMPLET":
                                        statusClass = "status-complete";
                                        statusIcon = "fas fa-check-circle";
                                        break;
                                    case "ANNULE":
                                        statusClass = "status-cancelled";
                                        statusIcon = "fas fa-times-circle";
                                        break;
                                    case "TERMINE":
                                        statusClass = "status-finished";
                                        statusIcon = "fas fa-flag-checkered";
                                        break;
                                }
                            %>
                            <span class="status-badge <%= statusClass %>">
                                <i class="<%= statusIcon %>"></i> <%= trajet.getStatut() %>
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                               <a href="passagers?action=trajet&trajetId=<%= trajet.getId() %>" class="btn-small btn-passengers" title="Voir passagers">
    <i class="fas fa-user-friends"></i>
</a>
                                <% if ("ACTIF".equals(trajet.getStatut())) { %>
                                <a href="trajets?action=modifier&id=<%= trajet.getId() %>" class="btn-small btn-edit" title="Modifier">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="trajets?action=annuler&id=<%= trajet.getId() %>" 
                                   class="btn-small btn-cancel" 
                                   title="Annuler"
                                   onclick="return confirm('Êtes-vous sûr de vouloir annuler ce trajet ?')">
                                    <i class="fas fa-times"></i>
                                </a>
                                <% } %>
                                
                                
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="empty-state">
                <i class="fas fa-road"></i>
                <h3>Vous n'avez pas encore proposé de trajet</h3>
                <p>Commencez par proposer votre premier trajet pour partager vos déplacements.</p>
                <a href="trajets?action=creer" class="btn btn-primary">
                    <i class="fas fa-plus-circle"></i> Proposer un trajet
                </a>
            </div>
            <% } %>
        </div>
    </div>
    
    <script>
        // Filtrage des trajets
        function filterTrajets(status) {
            const rows = document.querySelectorAll('.trajet-row');
            const tabs = document.querySelectorAll('.filter-tab');
            
            // Mettre à jour les onglets actifs
            tabs.forEach(tab => {
                tab.classList.remove('active');
                if (tab.textContent.includes(status === 'all' ? 'Tous' : status)) {
                    tab.classList.add('active');
                }
            });
            
            // Filtrer les lignes
            rows.forEach(row => {
                if (status === 'all' || row.getAttribute('data-status') === status) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
        
        // Recherche en temps réel
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            const rows = document.querySelectorAll('.trajet-row');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                if (text.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
        
        // Confirmation pour les actions sensibles
        function confirmAction(message) {
            return confirm(message);
        }
        
        // Initialiser les filtres
        document.addEventListener('DOMContentLoaded', function() {
            // Activer le premier filtre
            filterTrajets('all');
        });
    </script>
</body>
</html>