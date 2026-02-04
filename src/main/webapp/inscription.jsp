<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    // Récupération des attributs et paramètres
    String erreur = (String) request.getAttribute("erreur");
    String success = (String) request.getAttribute("success");
    
    // Récupération des paramètres du formulaire (pour pré-remplissage)
    String nomParam = request.getParameter("nom");
    String prenomParam = request.getParameter("prenom");
    String emailParam = request.getParameter("email");
    String telephoneParam = request.getParameter("telephone");
    String roleParam = request.getParameter("role");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription - Covoiturage</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            width: 100%;
            max-width: 500px;
        }
        
        .card {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }
        
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .logo i {
            font-size: 3rem;
            color: #667eea;
        }
        
        .logo h1 {
            color: #2d3748;
            margin-top: 10px;
            font-size: 1.8rem;
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
            font-size: 16px;
            transition: border-color 0.3s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .btn {
            display: block;
            width: 100%;
            padding: 14px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s;
            margin-top: 10px;
        }
        
        .btn:hover {
            background: #5a67d8;
        }
        
        .alert {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .alert-error {
            background: #fed7d7;
            border: 1px solid #fc8181;
            color: #c53030;
        }
        
        .alert-success {
            background: #c6f6d5;
            border: 1px solid #9ae6b4;
            color: #22543d;
        }
        
        .links {
            text-align: center;
            margin-top: 25px;
            color: #718096;
        }
        
        .links a {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }
        
        .links a:hover {
            text-decoration: underline;
        }
        
        .radio-group {
            display: flex;
            gap: 20px;
            margin-top: 10px;
        }
        
        .radio-option {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        @media (max-width: 768px) {
            .card {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <div class="logo">
                <i class="fas fa-car"></i>
                <h1>Inscription</h1>
            </div>
            
            <%-- Affichage des messages d'erreur --%>
            <% if (erreur != null && !erreur.isEmpty()) { %>
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> <%= erreur %>
                </div>
            <% } %>
            
            <%-- Affichage des messages de succès --%>
            <% if (success != null && !success.isEmpty()) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <%= success %>
                </div>
            <% } %>
            
            <form action="inscription" method="post">
                <div class="form-group">
                    <label for="nom"><i class="fas fa-user"></i> Nom</label>
                    <input type="text" id="nom" name="nom" class="form-control" required 
                           value="<%= nomParam != null ? nomParam : "" %>" placeholder="Votre nom">
                </div>
                
                <div class="form-group">
                    <label for="prenom"><i class="fas fa-user"></i> Prénom</label>
                    <input type="text" id="prenom" name="prenom" class="form-control" required 
                           value="<%= prenomParam != null ? prenomParam : "" %>" placeholder="Votre prénom">
                </div>
                
                <div class="form-group">
                    <label for="email"><i class="fas fa-envelope"></i> Email</label>
                    <input type="email" id="email" name="email" class="form-control" required 
                           value="<%= emailParam != null ? emailParam : "" %>" placeholder="votre@email.com">
                </div>
                
                <div class="form-group">
                    <label for="mot_de_passe"><i class="fas fa-lock"></i> Mot de passe</label>
                    <input type="password" id="mot_de_passe" name="mot_de_passe" class="form-control" required 
                           placeholder="••••••••">
                </div>
                
                <div class="form-group">
                    <label for="telephone"><i class="fas fa-phone"></i> Téléphone (optionnel)</label>
                    <input type="tel" id="telephone" name="telephone" class="form-control" 
                           value="<%= telephoneParam != null ? telephoneParam : "" %>" placeholder="06 12 34 56 78">
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-users"></i> Je suis :</label>
                    <div class="radio-group">
                        <div class="radio-option">
                            <input type="radio" id="conducteur" name="role" value="CONDUCTEUR" 
                                   <%= "CONDUCTEUR".equals(roleParam) ? "checked" : "" %> required>
                            <label for="conducteur">Conducteur</label>
                        </div>
                        <div class="radio-option">
                            <input type="radio" id="passager" name="role" value="PASSAGER" 
                                   <%= "PASSAGER".equals(roleParam) ? "checked" : "" %>>
                            <label for="passager">Passager</label>
                        </div>
                    </div>
                </div>
                
                <button type="submit" class="btn">
                    <i class="fas fa-user-plus"></i> S'inscrire
                </button>
            </form>
            
            <div class="links">
                <p>Déjà un compte ? <a href="connexion.jsp">Se connecter</a></p>
                <p><a href="accueil.jsp">← Retour à l'accueil</a></p>
            </div>
        </div>
    </div>
</body>
</html>