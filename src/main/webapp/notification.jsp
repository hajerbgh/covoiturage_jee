<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Utilisateur, java.util.List, com.covoiturage.model.Notification" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.covoiturage.dao.NotificationDAO" %>
<%@ page import="com.covoiturage.model.Notification" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    NotificationDAO notificationDAO = new NotificationDAO();
    List<Notification> notifications = notificationDAO.findByUtilisateurId(utilisateur.getId(), false);
    int notificationsNonLues = notificationDAO.countNonLues(utilisateur.getId());
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    // Gérer les actions
    String action = request.getParameter("action");
    if ("marquer-comme-lue".equals(action)) {
        String id = request.getParameter("id");
        if (id != null) {
            notificationDAO.marquerCommeLue(Long.parseLong(id));
        }
        response.sendRedirect("notification.jsp");
        return;
    }
    
    if ("marquer-toutes-lues".equals(action)) {
        notificationDAO.marquerToutesCommeLues(utilisateur.getId());
        response.sendRedirect("notification.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications - Covoiturage</title>
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
        
        .container {
            max-width: 800px;
            margin: 0 auto 40px;
            padding: 0 20px;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .page-title {
            color: #2d3748;
            font-size: 1.8rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .badge-notification {
            background: #f56565;
            color: white;
            border-radius: 50%;
            width: 25px;
            height: 25px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            font-weight: bold;
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
        
        /* Notifications */
        .notification-list {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 3px 15px rgba(0,0,0,0.05);
        }
        
        .notification-item {
            padding: 20px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            gap: 15px;
            align-items: flex-start;
            transition: background 0.3s;
        }
        
        .notification-item:last-child {
            border-bottom: none;
        }
        
        .notification-item:hover {
            background: #f7fafc;
        }
        
        .notification-item.non-lue {
            background: #f0f9ff;
        }
        
        .notification-icon {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            color: white;
            flex-shrink: 0;
        }
        
        .notification-content {
            flex-grow: 1;
        }
        
        .notification-title {
            color: #2d3748;
            font-weight: 600;
            margin-bottom: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .notification-message {
            color: #4a5568;
            line-height: 1.5;
        }
        
        .notification-date {
            color: #718096;
            font-size: 0.85rem;
            margin-top: 5px;
        }
        
        .notification-actions {
            display: flex;
            gap: 10px;
            margin-top: 10px;
        }
        
        .action-link {
            color: #4a6cf7;
            text-decoration: none;
            font-size: 0.85rem;
            cursor: pointer;
        }
        
        .action-link:hover {
            text-decoration: underline;
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
        
        .filter-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .filter-tab {
            padding: 8px 20px;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .filter-tab.active {
            background: #4a6cf7;
            color: white;
            border-color: #4a6cf7;
        }
        
        .filter-tab:hover {
            background: #f7fafc;
        }
        
        .filter-tab.active:hover {
            background: #3a5bd9;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="logo">
            <i class="fas fa-bell"></i>
            <div>
                <h1>Notifications</h1>
                <p>Restez informé de vos activités</p>
            </div>
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
            <h1 class="page-title">
                <i class="fas fa-bell"></i>
                Mes notifications
                <% if (notificationsNonLues > 0) { %>
                    <span class="badge-notification"><%= notificationsNonLues %></span>
                <% } %>
            </h1>
            
            <% if (notifications != null && !notifications.isEmpty()) { %>
                <a href="notifications?action=marquer-toutes-lues" class="btn">
                    <i class="fas fa-check-double"></i> Tout marquer comme lu
                </a>
            <% } %>
        </div>
        
        <!-- Notifications -->
        <% if (notifications != null && !notifications.isEmpty()) { %>
            <div class="notification-list">
                <% for (Notification notification : notifications) { %>
                    <div class="notification-item <%= notification.isLue() ? "" : "non-lue" %>">
                        <div class="notification-icon" style="background: <%= notification.getTypeColor() %>;">
                            <i class="<%= notification.getTypeIcon() %>"></i>
                        </div>
                        
                        <div class="notification-content">
                            <div class="notification-title">
                                <span><%= notification.getTitre() %></span>
                                <% if (!notification.isLue()) { %>
                                    <span style="color: #f56565; font-size: 0.7rem; font-weight: normal;">
                                        <i class="fas fa-circle"></i> Non lu
                                    </span>
                                <% } %>
                            </div>
                            
                            <div class="notification-message">
                                <%= notification.getMessage() %>
                            </div>
                            
                            <div class="notification-date">
                                <i class="far fa-clock"></i> <%= sdf.format(notification.getDateNotification()) %>
                            </div>
                            
                            <div class="notification-actions">
                                <% if (!notification.isLue()) { %>
                                    <a href="notifications?action=marquer-comme-lue&id=<%= notification.getId() %>" 
                                       class="action-link">
                                        <i class="fas fa-check"></i> Marquer comme lu
                                    </a>
                                <% } %>
                                
                                <% if (notification.getUrl() != null && !notification.getUrl().isEmpty()) { %>
                                    <a href="<%= notification.getUrl() %>" class="action-link">
                                        <i class="fas fa-external-link-alt"></i> Voir
                                    </a>
                                <% } %>
                                
                                <a href="notifications?action=supprimer&id=<%= notification.getId() %>" 
                                   class="action-link" 
                                   onclick="return confirm('Supprimer cette notification ?')">
                                    <i class="fas fa-trash"></i> Supprimer
                                </a>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <i class="far fa-bell-slash"></i>
                <h3>Aucune notification</h3>
                <p>Vous n'avez pas encore de notifications.</p>
                <a href="dashboard" class="btn" style="margin-top: 15px;">
                    <i class="fas fa-arrow-left"></i> Retour au dashboard
                </a>
            </div>
        <% } %>
    </div>
    
    <script>
        // Fonction pour marquer une notification comme lue via AJAX
        function marquerCommeLue(notificationId) {
            fetch('notifications?action=marquer-comme-lue&id=' + notificationId)
                .then(response => {
                    // Actualiser la page ou mettre à jour l'UI
                    location.reload();
                });
        }
        
        // Actualiser automatiquement les notifications toutes les 30 secondes
        setInterval(function() {
            const badge = document.querySelector('.badge-notification');
            if (badge) {
                // Simuler une vérification de nouvelles notifications
                fetch('notifications?action=count')
                    .then(response => response.json())
                    .then(data => {
                        if (data.count > parseInt(badge.textContent)) {
                            badge.textContent = data.count;
                            badge.style.animation = 'pulse 1s';
                            setTimeout(() => badge.style.animation = '', 1000);
                        }
                    });
            }
        }, 30000);
    </script>
</body>
</html>