<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Trajet" %>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    Trajet trajet = (Trajet) request.getAttribute("trajet");
    if (trajet == null) {
        response.sendRedirect("mes-trajets.jsp");
        return;
    }
    
    // Vérifier que l'utilisateur est bien le conducteur
    if (!trajet.getConducteurId().equals(utilisateur.getId())) {
        response.sendRedirect("details-trajet.jsp?id=" + trajet.getId());
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modifier trajet - Covoiturage</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Utilisez le même style que creer-trajet.jsp */
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
        
        .form-container {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }
        
        .form-group {
            margin-bottom: 25px;
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
        
        .btn {
            padding: 14px 25px;
            background: #4a6cf7;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
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
        
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="logo">
            <i class="fas fa-car"></i>
            <h1>Covoiturage App</h1>
        </div>
        <div>
            <a href="details-trajet.jsp?id=<%= trajet.getId() %>" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Retour
            </a>
        </div>
    </header>
    
    <div class="container">
        <div class="page-header">
            <h2><i class="fas fa-edit"></i> Modifier le trajet</h2>
            <p><%= trajet.getDepart() %> → <%= trajet.getDestination() %></p>
        </div>
        
        <% 
            // Vérifier les messages de session EN PREMIER
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
        %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> <%= successMessage %>
        </div>
        <%
                session.removeAttribute("successMessage"); // Nettoyer après affichage
            }
            
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i> <%= errorMessage %>
        </div>
        <%
                session.removeAttribute("errorMessage");
            }
            
            // Puis vérifier les messages de requête
            String success = (String) request.getAttribute("success");
            String erreur = (String) request.getAttribute("erreur");
            
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
        
        <div class="form-container">
            <form action="trajets" method="post">
                <input type="hidden" name="action" value="modifier">
                <input type="hidden" name="id" value="<%= trajet.getId() %>">
                
                <div class="form-group">
                    <label><i class="fas fa-map-marker-alt"></i> Ville de départ</label>
                    <input type="text" name="villeDepart" class="form-control" 
                           value="<%= trajet.getDepart() %>" required>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-flag-checkered"></i> Ville de destination</label>
                    <input type="text" name="villeDestination" class="form-control" 
                           value="<%= trajet.getDestination() %>" required>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-calendar-alt"></i> Date et heure de départ</label>
                    <input type="datetime-local" name="dateDepart" class="form-control" 
                           value="<%= sdf.format(trajet.getDateDepart()) %>" required>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-users"></i> Nombre de places disponibles</label>
                    <input type="number" name="placesDisponibles" class="form-control" 
                           value="<%= trajet.getPlacesDisponibles() %>" min="1" max="8" required>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-tag"></i> Prix par place (DT)</label>
                    <input type="number" name="prixParPlace" class="form-control" 
                           value="<%= trajet.getPrix() %>" step="0.5" min="0" required>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-align-left"></i> Description (optionnel)</label>
                    <textarea name="description" class="form-control" rows="4"><%= 
                        trajet.getDescription() != null ? trajet.getDescription() : "" 
                    %></textarea>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-ban"></i> Restrictions (optionnel)</label>
                    <textarea name="restrictions" class="form-control" rows="3" 
                        placeholder="Ex: non-fumeur, bagage limité..."><%= 
                        trajet.getRestrictions() != null ? trajet.getRestrictions() : "" 
                    %></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn">
                        <i class="fas fa-save"></i> Enregistrer les modifications
                    </button>
                    <a href="details-trajet.jsp?id=<%= trajet.getId() %>" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Annuler
                    </a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>