<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%
    // Vérifier si l'utilisateur est connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    String role = utilisateur.getRole();
    boolean isConducteur = "CONDUCTEUR".equals(role);
    boolean isPassager = "PASSAGER".equals(role);
    
    //  pour obtenir le contexte
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - Covoiturage</title>
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
        
        /* Header */
        .header {
            background: white;
            padding: 20px 40px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
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
            background: <%= isConducteur ? "#4CAF50" : "#2196F3" %>;
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
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .welcome-section {
            background: white;
            border-radius: 15px;
            padding: 40px;
            margin-bottom: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }
        
        .welcome-section h2 {
            color: #2d3748;
            font-size: 2rem;
            margin-bottom: 15px;
        }
        
        .welcome-section p {
            color: #718096;
            font-size: 1.1rem;
            margin-bottom: 10px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 3px 15px rgba(0,0,0,0.05);
            transition: transform 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 15px;
        }
        
        .stat-card.conducteur .stat-icon { color: #4CAF50; }
        .stat-card.passager .stat-icon { color: #2196F3; }
        .stat-card.trajets .stat-icon { color: #FF9800; }
        .stat-card.avis .stat-icon { color: #9C27B0; }
        
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
        
        /* Actions Section */
        .actions-section {
            margin: 40px 0;
        }
        
        .section-title {
            color: #2d3748;
            font-size: 1.5rem;
            margin-bottom: 25px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
        }
        
        .action-card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            transition: all 0.3s;
            border-left: 4px solid #4a6cf7;
        }
        
        .action-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }
        
        .action-icon {
            font-size: 2.5rem;
            color: #4a6cf7;
            margin-bottom: 20px;
        }
        
        .action-card h3 {
            color: #2d3748;
            font-size: 1.3rem;
            margin-bottom: 10px;
        }
        
        .action-card p {
            color: #718096;
            margin-bottom: 20px;
            font-size: 0.95rem;
        }
        
        .action-btn {
            display: inline-block;
            padding: 12px 25px;
            background: #4a6cf7;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            transition: background 0.3s;
        }
        
        .action-btn:hover {
            background: #3a5bd9;
        }
        
        .action-btn.secondary {
            background: #718096;
        }
        
        .action-btn.secondary:hover {
            background: #5a6c82;
        }
        
        /* Quick Links */
        .quick-links {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-top: 40px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }
        
        .links-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        
        .link-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 15px;
            background: #f7fafc;
            border-radius: 8px;
            text-decoration: none;
            color: #4a5568;
            transition: all 0.3s;
        }
        
        .link-item:hover {
            background: #edf2f7;
            color: #2d3748;
            transform: translateX(5px);
        }
        
        .link-item i {
            color: #4a6cf7;
        }
         
         
         
         .notification-link {
    position: relative;
    padding: 10px;
    border-radius: 50%;
    transition: all 0.3s;
}

.notification-link:hover {
    background: #f7fafc;
}

.notification-link:hover i {
    color: #4a6cf7 !important;
    transform: scale(1.1);
}

.notification-badge {
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.1); }
    100% { transform: scale(1); }
}

.notification-badge {
    animation: pulse 2s infinite;
    position: absolute;
    top: 5px;
    right: 5px;
    background: #f56565;
    color: white;
    border-radius: 50%;
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.7rem;
    font-weight: bold;
}

@keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.1); }
    100% { transform: scale(1); }
}

@keyframes bellRing {
    0% { transform: rotate(0deg); }
    10% { transform: rotate(15deg); }
    20% { transform: rotate(-15deg); }
    30% { transform: rotate(10deg); }
    40% { transform: rotate(-10deg); }
    50% { transform: rotate(5deg); }
    60% { transform: rotate(-5deg); }
    100% { transform: rotate(0deg); }
}

.bell-ring {
    animation: bellRing 1s ease-in-out;
}

.new-notification {
    position: relative;
}

.new-notification::after {
    content: '';
    position: absolute;
    top: 2px;
    right: 2px;
    width: 8px;
    height: 8px;
    background: #ff4757;
    border-radius: 50%;
    border: 2px solid white;
    animation: blink 1.5s infinite;
}

@keyframes blink {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.3; }
}
         
         
         
        /* Responsive */
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
            
            .container {
                padding: 0 15px;
            }
            
            .welcome-section {
                padding: 25px;
            }
            
            .actions-grid {
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
            <div class="logo-text">
                <h1>Covoiturage App</h1>
                <p>Partagez vos trajets, économisez ensemble</p>
            </div>
        </div>
        
<!-- Dans le header, corrigez la déclaration : -->
<div class="user-info">
    <div class="user-avatar">
        <%=Character.toUpperCase(utilisateur.getPrenom().charAt(0)) %><%=Character.toUpperCase(utilisateur.getNom().charAt(0))%>
    </div>
    <div class="user-details">
        <h3><%= utilisateur.getPrenom() %> <%= utilisateur.getNom() %></h3>
        <p><%= utilisateur.getEmail() %></p>
        <span class="role-badge">
            <%= isConducteur ? "🚗 Conducteur" : "👤 Passager" %>
        </span>
    </div>
    
    
    <% 
        Integer nbNotifs = (Integer) request.getAttribute("notificationsNonLues");
    %>
    
    <!-- BADGE DE NOTIFICATION -->
    <a href="notification.jsp" class="notification-link" 
       style="position: relative; padding: 10px; text-decoration: none;">
        <i class="fas fa-bell <%= nbNotifs != null && nbNotifs > 0 ? "bell-ring" : "" %>" 
           id="notificationBell"
           style="font-size: 1.5rem; color: #718096;"></i>
        <% if (nbNotifs != null && nbNotifs > 0) { %>
            <span class="notification-badge" id="notificationCount">
                <%= nbNotifs > 9 ? "9+" : nbNotifs %>
            </span>
            
            <!-- Indicateur visuel supplémentaire -->
            <span class="new-notification-indicator" 
                  style="position: absolute; top: 8px; right: 8px; width: 6px; height: 6px; 
                         background: #ff4757; border-radius: 50%; border: 2px solid white;">
            </span>
        <% } %>
    </a>
    
    <a href="deconnexion" class="logout-btn">
        <i class="fas fa-sign-out-alt"></i> Déconnexion
    </a>
</div>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <!-- Welcome Section -->
        <section class="welcome-section">
            <h2>Bonjour, <%= utilisateur.getPrenom() %> ! 👋</h2>
            <p>Bienvenue sur votre tableau de bord de covoiturage.</p>
            <p>Vous êtes connecté en tant que <strong><%= isConducteur ? "conducteur" : "passager" %></strong>.</p>
            
            <!-- statistiques : -->
<div class="stats-grid">
    <% if (isConducteur) { %>
        <!-- Statistiques pour Conducteur -->
        <div class="stat-card conducteur">
            <div class="stat-icon">
                <i class="fas fa-road"></i>
            </div>
            <div class="stat-value">
                <%= request.getAttribute("trajetsProposes") != null ? 
                    request.getAttribute("trajetsProposes") : "0" %>
            </div>
            <div class="stat-label">Trajets proposés</div>
        </div>
        
        <div class="stat-card passager">
            <div class="stat-icon">
                <i class="fas fa-calendar-check"></i>
            </div>
            <div class="stat-value">
                <%= request.getAttribute("reservations") != null ? 
                    request.getAttribute("reservations") : "0" %>
            </div>
            <div class="stat-label">Réservations reçues</div>
        </div>
        
        <div class="stat-card trajets">
            <div class="stat-icon">
                <i class="fas fa-star"></i>
            </div>
            <div class="stat-value">
                <% 
                    Double noteMoyenne = (Double) request.getAttribute("noteMoyenne");
                    if (noteMoyenne != null && noteMoyenne > 0) {
                        out.print(String.format("%.1f", noteMoyenne));
                    } else {
                        out.print("0.0");
                    }
                %>
            </div>
            <div class="stat-label">Note moyenne</div>
        </div>
        
        <!-- Carte des avis (CLIQUABLE) -->
        <a href="mes-avis" style="text-decoration: none; color: inherit; display: block;">
            <div class="stat-card avis" style="cursor: pointer;">
                <div class="stat-icon">
                    <i class="fas fa-comments"></i>
                </div>
                <div class="stat-value">
                    <%= request.getAttribute("avisRecus") != null ? 
                        request.getAttribute("avisRecus") : "0" %>
                </div>
                <div class="stat-label">
                    Avis reçus <i class="fas fa-external-link-alt" style="font-size: 0.7em;"></i>
                </div>
            </div>
        </a>
        
    <% } else if (isPassager) { %>
        <!-- Statistiques pour Passager -->
        <div class="stat-card passager">
            <div class="stat-icon">
                <i class="fas fa-calendar-check"></i>
            </div>
            <div class="stat-value">
                <%= request.getAttribute("reservations") != null ? 
                    request.getAttribute("reservations") : "0" %>
            </div>
            <div class="stat-label">Réservations</div>
        </div>
        
        <div class="stat-card trajets">
            <div class="stat-icon">
                <i class="fas fa-star"></i>
            </div>
            <div class="stat-value">
                <% 
                    Double noteMoyenne = (Double) request.getAttribute("noteMoyenne");
                    if (noteMoyenne != null && noteMoyenne > 0) {
                        out.print(String.format("%.1f", noteMoyenne));
                    } else {
                        out.print("0.0");
                    }
                %>
            </div>
            <div class="stat-label">Note moyenne</div>
        </div>
        
        <!-- Carte des avis (CLIQUABLE) pour passager aussi -->
        <a href="mes-avis" style="text-decoration: none; color: inherit; display: block;">
            <div class="stat-card avis" style="cursor: pointer;">
                <div class="stat-icon">
                    <i class="fas fa-comments"></i>
                </div>
                <div class="stat-value">
                    <%= request.getAttribute("avisRecus") != null ? 
                        request.getAttribute("avisRecus") : "0" %>
                </div>
                <div class="stat-label">
                    Avis reçus <i class="fas fa-external-link-alt" style="font-size: 0.7em;"></i>
                </div>
            </div>
        </a>
        
       
        <div class="stat-card conducteur">
            <div class="stat-icon">
                <i class="fas fa-heart"></i>
            </div>
            <div class="stat-value">0</div>
            <div class="stat-label">Trajets favoris</div>
        </div>
    <% } %>
</div>
        </section>
        
        <!-- Actions Section -->
        <section class="actions-section">
            <h2 class="section-title">Actions rapides</h2>
            
            <div class="actions-grid">
                <% if (isConducteur) { %>
                    <!-- Actions pour Conducteur -->
                    <div class="action-card">
                        <div class="action-icon">
                            <i class="fas fa-plus-circle"></i>
                        </div>
                        <h3>Proposer un trajet</h3>
                        <p>Partagez votre trajet avec d'autres utilisateurs et économisez sur vos déplacements.</p>
                        <a href="creer-trajet.jsp" class="action-btn">
                            <i class="fas fa-plus"></i> Nouveau trajet
                        </a>
                    </div>
                    
                    <div class="action-card">
                        <div class="action-icon">
                            <i class="fas fa-list-ul"></i>
                        </div>
                        <h3>Mes trajets</h3>
                        <p>Consultez et gérez tous les trajets que vous avez proposés.</p>
<a href="trajets?action=mes-trajets" class="action-btn secondary">
    <i class="fas fa-eye"></i> Voir mes trajets
</a>
                    </div>
                    
                    <div class="action-card">
                        <div class="action-icon">
                            <i class="fas fa-users"></i>
                        </div>
                        <h3>Mes passagers</h3>
                        <p>Gérez les réservations et communiquez avec vos passagers.</p>
                        <a href="passagers" class="action-btn secondary">
        <i class="fas fa-user-friends"></i> Voir passagers
    </a>
                    </div>
                <% } %>
                
                <% if (isPassager) { %>
                    <!-- Actions pour Passager -->
                    <div class="action-card">
                        <div class="action-icon">
                            <i class="fas fa-search"></i>
                        </div>
                        <h3>Rechercher un trajet</h3>
                        <p>Trouvez un trajet qui correspond à votre destination et à vos horaires.</p>
                        <a href="trajets?action=rechercher" class="action-btn">
                            <i class="fas fa-search"></i> Rechercher
                        </a>
                    </div>
                    
                    <div class="action-card">
                        <div class="action-icon">
                            <i class="fas fa-calendar-alt"></i>
                        </div>
                        <h3>Mes réservations</h3>
                        <p>Consultez et gérez toutes vos réservations de covoiturage.</p>
<a href="reservations" class="action-btn secondary">
    <i class="fas fa-list"></i> Voir réservations
</a>               </div>
                    
                    <div class="action-card">
                        <div class="action-icon">
                            <i class="fas fa-history"></i>
                        </div>
                        <h3>Historique</h3>
                        <p>Retrouvez tous vos trajets passés et vos évaluations.</p>
                        <a href="historique" class="action-btn secondary">
                            <i class="fas fa-history"></i> Voir historique
                        </a>
                    </div>
                <% } %>
                
                <!-- Actions communes -->
<div class="action-card">
    <div class="action-icon">
        <i class="fas fa-user-cog"></i>
    </div>
    <h3>Mon profil</h3>
    <p>Modifiez vos informations personnelles et vos préférences.</p>
    <!-- MODIFIEZ LE LIEN POUR UTILISER LA VARIABLE -->
    <a href="<%= contextPath %>/profil" class="action-btn secondary">
        <i class="fas fa-edit"></i> Modifier profil
    </a>
</div>
            </div>
        </section>
        
        <!-- Quick Links -->
        <section class="quick-links">
            <h2 class="section-title">Accès rapide</h2>
            <div class="links-grid">
                <a href="dashboard" class="link-item">
    <i class="fas fa-home"></i>
    <span>Dashboard</span>
</a>
                
                <% if (isConducteur) { %>
                    <a href="creer-trajet.jsp" class="link-item">
                        <i class="fas fa-road"></i>
                        <span>Proposer trajet</span>
                    </a>
                <% } %>
                
                <% if (isPassager) { %>
                    <a href="rechercher-trajet.jsp" class="link-item">
                        <i class="fas fa-search"></i>
                        <span>Rechercher</span>
                    </a>
                <% } %>
                
                <a href="messages.jsp" class="link-item">
                    <i class="fas fa-envelope"></i>
                    <span>Messages</span>
                </a>
                
                <a href="notification.jsp" class="link-item">
                    <i class="fas fa-bell"></i>
                    <span>Notifications</span>
                </a>
                
                <a href="aide.jsp" class="link-item">
                    <i class="fas fa-question-circle"></i>
                    <span>Aide</span>
                </a>
                
                <a href="parametres.jsp" class="link-item">
                    <i class="fas fa-cog"></i>
                    <span>Paramètres</span>
                </a>
            </div>
        </section>
    </div>
    
    <!-- JavaScript pour les notifications  -->
  <script>
    // DÉCLAREZ lastNotificationCount AVEC LA VARIABLE JSP
    let lastNotificationCount = <%= nbNotifs != null ? nbNotifs : 0 %>;
    
    function checkNewNotifications() {
        fetch('dashboard?action=check-notifications')
            .then(response => response.text())
            .then(data => {
                const newCount = parseInt(data);
                const badge = document.getElementById('notificationCount');
                const bell = document.getElementById('notificationBell');
                
                if (!isNaN(newCount) && newCount > lastNotificationCount) {
                    // Nouvelles notifications !
                    
                    // 1. Animer la cloche
                    bell.classList.remove('bell-ring');
                    void bell.offsetWidth; // Trigger reflow
                    bell.classList.add('bell-ring');
                    
                    // 2. Mettre à jour le badge
                    if (badge) {
                        badge.textContent = newCount > 9 ? "9+" : newCount;
                        badge.style.animation = 'pulse 1s';
                    } else {
                        // Créer le badge s'il n'existe pas
                        const link = document.querySelector('.notification-link');
                        const newBadge = document.createElement('span');
                        newBadge.className = 'notification-badge';
                        newBadge.id = 'notificationCount';
                        newBadge.textContent = newCount > 9 ? "9+" : newCount;
                        link.appendChild(newBadge);
                        
                        // Ajouter l'indicateur
                        const indicator = document.createElement('span');
                        indicator.className = 'new-notification-indicator';
                        indicator.style.cssText = 'position: absolute; top: 8px; right: 8px; width: 6px; height: 6px; background: #ff4757; border-radius: 50%; border: 2px solid white;';
                        link.appendChild(indicator);
                    }
                    
                    // 3. Afficher une notification toast
                    showNotificationToast("Vous avez " + (newCount - lastNotificationCount) + " nouvelle(s) notification(s)");
                    
                    lastNotificationCount = newCount;
                } else if (newCount < lastNotificationCount) {
                    // Moins de notifications (marquées comme lues ailleurs)
                    lastNotificationCount = newCount;
                    if (badge) {
                        badge.textContent = newCount > 9 ? "9+" : newCount;
                        if (newCount === 0) {
                            badge.remove();
                            document.querySelector('.new-notification-indicator')?.remove();
                        }
                    }
                }
            })
            .catch(error => console.error('Erreur vérification notifications:', error));
    }
    
    // Fonction pour afficher une notification toast
    function showNotificationToast(message) {
        // Créer le toast
        const toast = document.createElement('div');
        toast.className = 'notification-toast';
        toast.innerHTML = `
            <div style="display: flex; align-items: center; gap: 10px;">
                <i class="fas fa-bell" style="color: #4a6cf7;"></i>
                <span>${message}</span>
            </div>
            <button onclick="this.parentElement.remove()" style="background: none; border: none; color: #718096; cursor: pointer;">
                <i class="fas fa-times"></i>
            </button>
        `;
        
        // Styles du toast
        toast.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: white;
            padding: 15px 20px;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            justify-content: space-between;
            z-index: 1000;
            animation: slideIn 0.3s ease-out;
            min-width: 300px;
            border-left: 4px solid #4a6cf7;
        `;
        
        document.body.appendChild(toast);
        
        // Supprimer automatiquement après 5 secondes
        setTimeout(() => {
            if (toast.parentElement) {
                toast.style.animation = 'slideOut 0.3s ease-out';
                setTimeout(() => toast.remove(), 300);
            }
        }, 5000);
    }
    
    // Animation CSS pour les toasts
    const toastStyle = document.createElement('style');
    toastStyle.textContent = `
        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        @keyframes slideOut {
            from { transform: translateX(0); opacity: 1; }
            to { transform: translateX(100%); opacity: 0; }
        }
    `;
    document.head.appendChild(toastStyle);
    
    // Vérifier toutes les 30 secondes
    setInterval(checkNewNotifications, 30000);
    
    // Vérifier aussi quand la page redevient visible
    document.addEventListener('visibilitychange', function() {
        if (!document.hidden) {
            checkNewNotifications();
        }
    });
    
    // Vérifier immédiatement au chargement de la page
    checkNewNotifications();
</script>
</body>
</html>