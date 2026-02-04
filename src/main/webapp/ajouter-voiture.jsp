<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null || !"CONDUCTEUR".equals(utilisateur.getRole())) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    String erreur = (String) request.getAttribute("erreur");
    String success = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Ajouter une voiture</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input { width: 100%; padding: 8px; }
        .btn { padding: 10px 20px; background: #4CAF50; color: white; border: none; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <h2>📝 Ajouter votre voiture</h2>
        
        <% if (erreur != null) { %>
            <div style="color: red; padding: 10px; background: #ffe6e6;">
                <%= erreur %>
            </div>
        <% } %>
        
        <% if (success != null) { %>
            <div style="color: green; padding: 10px; background: #e6ffe6;">
                <%= success %>
            </div>
        <% } %>
        
        <form action="voiture" method="post">
            <div class="form-group">
                <label>Marque *</label>
                <input type="text" name="marque" placeholder="Ex: Renault" required>
            </div>
            
            <div class="form-group">
                <label>Modèle *</label>
                <input type="text" name="modele" placeholder="Ex: Clio" required>
            </div>
            
            <div class="form-group">
                <label>Matricule *</label>
                <input type="text" name="matricule" placeholder="Ex: TN-123-456" required>
            </div>
            
            <div class="form-group">
                <label>Nombre de places *</label>
                <input type="number" name="nombrePlaces" min="2" max="8" value="5" required>
            </div>
            
            <button type="submit" class="btn">Enregistrer la voiture</button>
            <a href="creer-trajet.jsp" style="margin-left: 20px;">Retour</a>
        </form>
    </div>
</body>
</html>