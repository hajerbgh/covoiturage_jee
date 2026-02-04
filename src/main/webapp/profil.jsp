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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mon profil - Covoiturage</title>
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
            max-width: 1000px;
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
        
        .profile-content {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 30px;
        }
        
        @media (max-width: 768px) {
            .profile-content {
                grid-template-columns: 1fr;
            }
        }
        
        .profile-sidebar {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            height: fit-content;
        }
        
        .profile-avatar {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, #4a6cf7, #8a63d2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2.5rem;
            font-weight: bold;
            margin: 0 auto 20px;
        }
        
        .profile-info {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .profile-info h3 {
            color: #2d3748;
            font-size: 1.5rem;
            margin-bottom: 5px;
        }
        
        .profile-info p {
            color: #718096;
            margin-bottom: 10px;
        }
        
        .role-badge {
            display: inline-block;
            padding: 6px 16px;
            background: <%= isConducteur ? "#4CAF50" : "#2196F3" %>;
            color: white;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 500;
            margin-top: 10px;
        }
        
        .profile-stats {
            border-top: 2px solid #e2e8f0;
            padding-top: 20px;
        }
        
        .stat-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #e2e8f0;
        }
        
        .stat-item:last-child {
            border-bottom: none;
        }
        
        .stat-label {
            color: #718096;
        }
        
        .stat-value {
            color: #2d3748;
            font-weight: 500;
        }
        
        .profile-forms {
            display: flex;
            flex-direction: column;
            gap: 30px;
        }
        
        .form-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }
        
        .section-title {
            color: #2d3748;
            font-size: 1.3rem;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e2e8f0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .form-group {
            margin-bottom: 20px;
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
        
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .required {
            color: #f56565;
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="logo">
            <i class="fas fa-user-circle"></i>
            <h1>Mon profil</h1>
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
            String success = (String) request.getAttribute("success");
            String erreur = (String) request.getAttribute("erreur");
            String successMotDePasse = (String) request.getAttribute("successMotDePasse");
            String erreurMotDePasse = (String) request.getAttribute("erreurMotDePasse");
            
            if (success != null && !success.isEmpty()) {
        %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> <%= success %>
        </div>
        <% } %>
        
        <% if (erreur != null && !erreur.isEmpty()) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i> <%= erreur %>
        </div>
        <% } %>
        
        <% if (successMotDePasse != null && !successMotDePasse.isEmpty()) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> <%= successMotDePasse %>
        </div>
        <% } %>
        
        <% if (erreurMotDePasse != null && !erreurMotDePasse.isEmpty()) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i> <%= erreurMotDePasse %>
        </div>
        <% } %>
        
        <div class="page-header">
            <h2>
                <i class="fas fa-user-cog"></i>
                Gérer votre profil
            </h2>
            <p>Mettez à jour vos informations personnelles et vos préférences</p>
        </div>
        
        <div class="profile-content">
            <!-- Sidebar avec informations du profil -->
            <div class="profile-sidebar">
                <div class="profile-avatar">
                    <%= utilisateur.getPrenom().charAt(0) %><%= utilisateur.getNom().charAt(0) %>
                </div>
                
                <div class="profile-info">
                    <h3><%= utilisateur.getPrenom() %> <%= utilisateur.getNom() %></h3>
                    <p><%= utilisateur.getEmail() %></p>
                    <% if (utilisateur.getTelephone() != null && !utilisateur.getTelephone().isEmpty()) { %>
                        <p><i class="fas fa-phone"></i> <%= utilisateur.getTelephone() %></p>
                    <% } %>
                    <span class="role-badge">
                        <%= isConducteur ? "🚗 Conducteur" : "👤 Passager" %>
                    </span>
                </div>
                
                <div class="profile-stats">
                    <div class="stat-item">
                        <span class="stat-label">Membre depuis</span>
                        <span class="stat-value">
                            <% 
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                if (utilisateur.getDateCreation() != null) {
                                    out.print(sdf.format(utilisateur.getDateCreation()));
                                } else {
                                    out.print("N/A");
                                }
                            %>
                        </span>
                    </div>
                    
                    <% if (isConducteur) { %>
                        <div class="stat-item">
                            <span class="stat-label">Note conducteur</span>
                            <span class="stat-value">
                                <%= utilisateur.getNoteConducteur() != null ? 
                                    String.format("%.1f", utilisateur.getNoteConducteur()) : "0.0" %>
                                <i class="fas fa-star" style="color: #FFD700;"></i>
                            </span>
                        </div>
                    <% } %>
                    
                    <% if (isPassager) { %>
                        <div class="stat-item">
                            <span class="stat-label">Note passager</span>
                            <span class="stat-value">
                                <%= utilisateur.getNotePassager() != null ? 
                                    String.format("%.1f", utilisateur.getNotePassager()) : "0.0" %>
                                <i class="fas fa-star" style="color: #FFD700;"></i>
                            </span>
                        </div>
                    <% } %>
                    
                    <div class="stat-item">
                        <span class="stat-label">Statut</span>
                        <span class="stat-value" style="color: #48bb78;">
                            <i class="fas fa-check-circle"></i> Actif
                        </span>
                    </div>
                </div>
            </div>
            
            <!-- Formulaires de modification -->
            <div class="profile-forms">
                <!-- Formulaire d'informations personnelles -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-user-edit"></i>
                        Informations personnelles
                    </h3>
                    
                    <form action="profil" method="post">
                        <input type="hidden" name="action" value="modifier">
                        
                        <div class="form-group">
                            <label for="nom">
                                <i class="fas fa-user"></i> Nom 
                                <span class="required">*</span>
                            </label>
                            <input type="text" id="nom" name="nom" class="form-control" 
                                   value="<%= utilisateur.getNom() %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="prenom">
                                <i class="fas fa-user"></i> Prénom 
                                <span class="required">*</span>
                            </label>
                            <input type="text" id="prenom" name="prenom" class="form-control" 
                                   value="<%= utilisateur.getPrenom() %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="email">
                                <i class="fas fa-envelope"></i> Email 
                                <span class="required">*</span>
                            </label>
                            <input type="email" id="email" name="email" class="form-control" 
                                   value="<%= utilisateur.getEmail() %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="telephone">
                                <i class="fas fa-phone"></i> Téléphone
                            </label>
                            <input type="tel" id="telephone" name="telephone" class="form-control" 
                                   value="<%= utilisateur.getTelephone() != null ? utilisateur.getTelephone() : "" %>">
                        </div>
                        
                        <div class="form-actions">
                            <button type="submit" class="btn">
                                <i class="fas fa-save"></i> Enregistrer les modifications
                            </button>
                        </div>
                    </form>
                </div>
                
                <!-- Formulaire de changement de mot de passe -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-lock"></i>
                        Sécurité du compte
                    </h3>
                    
                    <form action="profil" method="post">
                        <input type="hidden" name="action" value="changer-motdepasse">
                        
                        <div class="form-group">
                            <label for="motDePasseActuel">
                                <i class="fas fa-key"></i> Mot de passe actuel 
                                <span class="required">*</span>
                            </label>
                            <input type="password" id="motDePasseActuel" name="motDePasseActuel" 
                                   class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="nouveauMotDePasse">
                                <i class="fas fa-key"></i> Nouveau mot de passe 
                                <span class="required">*</span>
                            </label>
                            <input type="password" id="nouveauMotDePasse" name="nouveauMotDePasse" 
                                   class="form-control" required>
                            <small style="color: #718096; font-size: 0.85rem; display: block; margin-top: 5px;">
                                Minimum 6 caractères
                            </small>
                        </div>
                        
                        <div class="form-group">
                            <label for="confirmerMotDePasse">
                                <i class="fas fa-key"></i> Confirmer le nouveau mot de passe 
                                <span class="required">*</span>
                            </label>
                            <input type="password" id="confirmerMotDePasse" name="confirmerMotDePasse" 
                                   class="form-control" required>
                        </div>
                        
                        <div class="form-actions">
                            <button type="submit" class="btn">
                                <i class="fas fa-sync-alt"></i> Changer le mot de passe
                            </button>
                        </div>
                    </form>
                </div>
                
                <!-- Section pour les conducteurs (si applicable) -->
                <% if (isConducteur) { %>
                    <div class="form-section">
                        <h3 class="section-title">
                            <i class="fas fa-car"></i>
                            Informations conducteur
                        </h3>
                        
                        <div style="text-align: center; padding: 20px;">
                            <i class="fas fa-car" style="font-size: 3rem; color: #718096; margin-bottom: 15px;"></i>
                            <p style="color: #718096; margin-bottom: 20px;">
                                Pour gérer votre véhicule, rendez-vous sur la page dédiée.
                            </p>
                            <a href="voiture.jsp" class="btn btn-secondary">
                                <i class="fas fa-cog"></i> Gérer mon véhicule
                            </a>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <script>
        // Validation du formulaire côté client
        document.addEventListener('DOMContentLoaded', function() {
            const forms = document.querySelectorAll('form');
            
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    // Validation du mot de passe
                    if (form.querySelector('#nouveauMotDePasse')) {
                        const nouveauMotDePasse = document.getElementById('nouveauMotDePasse').value;
                        const confirmerMotDePasse = document.getElementById('confirmerMotDePasse').value;
                        
                        if (nouveauMotDePasse.length < 6) {
                            e.preventDefault();
                            alert('Le mot de passe doit contenir au moins 6 caractères.');
                            return;
                        }
                        
                        if (nouveauMotDePasse !== confirmerMotDePasse) {
                            e.preventDefault();
                            alert('Les mots de passe ne correspondent pas.');
                            return;
                        }
                    }
                });
            });
        });
    </script>
</body>
</html>