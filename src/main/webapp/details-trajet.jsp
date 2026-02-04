<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Trajet" %>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Vérifier si l'utilisateur est connecté
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    Trajet trajet = (Trajet) request.getAttribute("trajet");
    String erreur = (String) request.getAttribute("erreur");
    
    if (trajet == null && erreur == null) {
        response.sendRedirect("trajets");
        return;
    }
    
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm");
    SimpleDateFormat sdfFull = new SimpleDateFormat("dd/MM/yyyy à HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Détails du trajet - Covoiturage</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"> 
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCil5NTW0pDAwlvV5dAYrf3ejVzGTdWjlk&libraries=places&callback=initSimpleMap" async defer></script>
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
            max-width: 1000px;
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
        
        <% if (trajet != null) { %>
        /* Carte principale */
        .trajet-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .card-header {
            background: linear-gradient(135deg, #4a6cf7, #8a63d2);
            color: white;
            padding: 30px;
            position: relative;
        }
        
        .price-badge {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(255,255,255,0.2);
            padding: 10px 20px;
            border-radius: 30px;
            font-size: 1.5rem;
            font-weight: bold;
            backdrop-filter: blur(10px);
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
        
        /* Informations détaillées */
        .card-body {
            padding: 30px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .info-card {
            padding: 20px;
            background: #f7fafc;
            border-radius: 10px;
            border-left: 4px solid #4a6cf7;
        }
        
        .info-card h3 {
            color: #2d3748;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-list {
            list-style: none;
        }
        
        .info-list li {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
            color: #4a5568;
        }
        
        /* Description */
        .description-card {
            background: #ebf8ff;
            border-left: 4px solid #4299e1;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .description-card h3 {
            color: #2d3748;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .description-content {
            line-height: 1.6;
            color: #4a5568;
        }
        
        /* Restrictions */
        .restrictions-card {
            background: #fff5f5;
            border-left: 4px solid #f56565;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .restrictions-card h3 {
            color: #2d3748;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .restrictions-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .restriction-tag {
            background: #fed7d7;
            color: #c53030;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
        }
        
        /* Actions */
        .actions-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            border: 2px solid #e2e8f0;
        }
        
        .places-info {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .places-count {
            font-size: 1.2rem;
            color: #2d3748;
        }
        
        .places-badge {
            background: <%= trajet.getPlacesDisponibles() > 0 ? "#48bb78" : "#f56565" %>;
            color: white;
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: 500;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
        }
        
        .btn {
            flex: 1;
            padding: 15px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: #4a6cf7;
            color: white;
        }
        
        .btn-primary:hover {
            background: #3a5bd9;
        }
        
        .btn-secondary {
            background: #a0aec0;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #718096;
        }
        
        .btn-danger {
            background: #f56565;
            color: white;
        }
        
        .btn-danger:hover {
            background: #e53e3e;
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
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="logo">
            <i class="fas fa-car"></i>
            <h1>Covoiturage App</h1>
        </div>
        
        <nav class="nav-links">
            <a href="dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="trajets">
                <i class="fas fa-road"></i> Trajets
            </a>
            <a href="deconnexion">
                <i class="fas fa-sign-out-alt"></i> Déconnexion
            </a>
        </nav>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <a href="trajets" class="back-link">
            <i class="fas fa-arrow-left"></i> Retour aux trajets
        </a>
        
        <% if (erreur != null && !erreur.isEmpty()) { %>
            <div class="error-state">
                <i class="fas fa-exclamation-circle"></i>
                <h2>Erreur</h2>
                <p><%= erreur %></p>
                <a href="trajets" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Retour aux trajets
                </a>
            </div>
        <% } else if (trajet != null) { %>
        
        <!-- Carte du trajet -->
        <div class="trajet-card">
            <!-- En-tête -->
            <div class="card-header">
                <div class="price-badge">
                    <%= String.format("%.2f", trajet.getPrix()) %> DT
                </div>
                
                <h1 class="route-title"><%= trajet.getDepart() %> → <%= trajet.getDestination() %></h1>
                <p class="route-subtitle">
                    <i class="far fa-clock"></i> 
                    Départ prévu le <%= sdfFull.format(trajet.getDateDepart()) %>
                </p>
                
                <div class="route-display">
                    <div class="route-point depart">
                        <i class="fas fa-map-marker-alt"></i>
                        <div class="route-info">
                            <h3>Départ</h3>
                            <p><%= trajet.getDepart() %></p>
                        </div>
                    </div>
                    
                    <div class="route-arrow">
                        <i class="fas fa-long-arrow-alt-right"></i>
                    </div>
                    
                    <div class="route-point arrivee">
                        <i class="fas fa-flag-checkered"></i>
                        <div class="route-info">
                            <h3>Arrivée</h3>
                            <p><%= trajet.getDestination() %></p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Corps -->
            <div class="card-body">
                <!-- Informations détaillées -->
                <div class="info-grid">
                    <div class="info-card">
                        <h3><i class="fas fa-info-circle"></i> Informations</h3>
                        <ul class="info-list">
                            <li>
                                <i class="far fa-calendar"></i>
                                <span>Date: <strong><%= sdfDate.format(trajet.getDateDepart()) %></strong></span>
                            </li>
                            <li>
                                <i class="far fa-clock"></i>
                                <span>Heure: <strong><%= sdfTime.format(trajet.getDateDepart()) %></strong></span>
                            </li>
                            <li>
                                <i class="fas fa-tag"></i>
                                <span>Prix: <strong><%= String.format("%.2f", trajet.getPrix()) %> DT/place</strong></span>
                            </li>
                            <li>
                                <i class="fas fa-chair"></i>
                                <span>Statut: <strong><%= trajet.getStatut() %></strong></span>
                            </li>
                        </ul>
                    </div>
                    
                    <div class="info-card">
                        <h3><i class="fas fa-users"></i> Places</h3>
                        <ul class="info-list">
                            <li>
                                <i class="fas fa-user-friends"></i>
                                <span>Places disponibles: <strong><%= trajet.getPlacesDisponibles() %></strong></span>
                            </li>
                            <li>
                                <i class="fas fa-car"></i>
                                <span>Véhicule: <strong>Voiture du conducteur</strong></span>
                            </li>
                            <% if (trajet.getConducteurId().equals(utilisateur.getId())) { %>
                            <li>
                                <i class="fas fa-user-tie"></i>
                                <span>Vous êtes le conducteur</span>
                            </li>
                            <% } %>
                        </ul>
                    </div>
                </div>
                
                <!-- Description -->
                <% if (trajet.getDescription() != null && !trajet.getDescription().isEmpty()) { %>
                <div class="description-card">
                    <h3><i class="fas fa-comment-alt"></i> Description</h3>
                    <div class="description-content">
                        <%= trajet.getDescription().replace("\n", "<br>") %>
                    </div>
                </div>
                <% } %>
                
                <!-- Restrictions -->
                <% if (trajet.getRestrictions() != null && !trajet.getRestrictions().isEmpty()) { %>
                <div class="restrictions-card">
                    <h3><i class="fas fa-ban"></i> Restrictions</h3>
                    <div class="restrictions-list">
                        <% 
                            String[] restrictions = trajet.getRestrictions().split(", ");
                            for (String restriction : restrictions) {
                                if (!restriction.trim().isEmpty()) {
                        %>
                        <span class="restriction-tag"><%= restriction.trim() %></span>
                        <% 
                                }
                            } 
                        %>
                    </div>
                </div>
                <% } %>
                
                <!-- Actions -->
                <div class="actions-card">
                    <div class="places-info">
                        <div class="places-count">
                            <i class="fas fa-users"></i> 
                            <%= trajet.getPlacesDisponibles() %> place(s) disponible(s)
                        </div>
                        <div class="places-badge">
                            <%= trajet.getPlacesDisponibles() > 0 ? "DISPONIBLE" : "COMPLET" %>
                        </div>
                    </div>
                    <!-- Ajoutez dans details-trajet.jsp, après les détails du trajet -->

<div class="map-container" style="margin: 30px 0; padding: 20px; background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
    <h3><i class="fas fa-map-marked-alt"></i> Localisation du trajet</h3>
    
    <div id="map" style="height: 400px; width: 100%; border-radius: 8px;"></div>
    
    <div style="margin-top: 15px; display: flex; gap: 15px; flex-wrap: wrap;">
        <div style="background: #e8f4ff; padding: 10px 15px; border-radius: 6px;">
            <i class="fas fa-map-pin" style="color: #4CAF50;"></i>
            <strong>Départ :</strong> <%= trajet.getDepart() %>
        </div>
        <div style="background: #ffe8e8; padding: 10px 15px; border-radius: 6px;">
            <i class="fas fa-flag" style="color: #f44336;"></i>
            <strong>Arrivée :</strong> <%= trajet.getDestination() %>
        </div>
    </div>
</div>

<script>
// Fonction de callback pour Google Maps API
function initMap() {
    console.log("✅ Google Maps API chargée dans details-trajet");
    initSimpleMap();
}

// Version simplifiée pour tester
function initSimpleMap() {
    console.log("🔍 Initialisation de la carte pour le trajet...");
    
    // Vérifier si Google Maps est disponible
    if (typeof google === 'undefined') {
        console.error("Google Maps API non chargée");
        document.getElementById('map').innerHTML = 
            '<div style="padding: 50px; text-align: center; color: #666;">' +
            '<i class="fas fa-exclamation-triangle" style="font-size: 48px; margin-bottom: 20px;"></i><br>' +
            'Google Maps non chargé. Vérifiez votre connexion internet.</div>';
        return;
    }
    
    // Coordonnées par défaut (Tunis)
    const defaultPosition = { lat: 36.8065, lng: 10.1815 };
    
    // Créer la carte
    const map = new google.maps.Map(document.getElementById('map'), {
        center: defaultPosition,
        zoom: 12,
        mapTypeControl: true,
        streetViewControl: false,
        fullscreenControl: true
    });
    
    console.log("✅ Carte Google Maps créée");
    
    // Récupérer les adresses depuis la page
    const depart = "<%= trajet.getDepart() %>";
    const destination = "<%= trajet.getDestination() %>";
    
    console.log("Adresses du trajet:", depart, "→", destination);
    
    // Géocoder les deux adresses
    const geocoder = new google.maps.Geocoder();
    
    // Géocoder le départ
    if (depart) {
        geocoder.geocode({ address: depart + ', Tunisie' }, (results, status) => {
            if (status === 'OK' && results[0]) {
                console.log("📍 Marqueur départ ajouté:", results[0].geometry.location);
                
                // Marqueur vert pour le départ
                new google.maps.Marker({
                    map: map,
                    position: results[0].geometry.location,
                    title: 'Départ: ' + depart,
                    icon: {
                        url: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png'
                    }
                });
                
                // Recentrer si c'est le premier point
                map.setCenter(results[0].geometry.location);
                
                // Si nous avons aussi la destination, tracer l'itinéraire
                if (destination) {
                    geocoder.geocode({ address: destination + ', Tunisie' }, (destResults, destStatus) => {
                        if (destStatus === 'OK' && destResults[0]) {
                            console.log("📍 Marqueur destination ajouté:", destResults[0].geometry.location);
                            
                            // Marqueur rouge pour l'arrivée
                            new google.maps.Marker({
                                map: map,
                                position: destResults[0].geometry.location,
                                title: 'Arrivée: ' + destination,
                                icon: {
                                    url: 'https://maps.google.com/mapfiles/ms/icons/red-dot.png'
                                }
                            });
                            
                            // Tracer l'itinéraire
                            const directionsService = new google.maps.DirectionsService();
                            const directionsRenderer = new google.maps.DirectionsRenderer({
                                map: map,
                                suppressMarkers: true,
                                polylineOptions: {
                                    strokeColor: '#4a6cf7',
                                    strokeWeight: 4,
                                    strokeOpacity: 0.7
                                }
                            });
                            
                            const request = {
                                origin: results[0].geometry.location,
                                destination: destResults[0].geometry.location,
                                travelMode: 'DRIVING'
                            };
                            
                            directionsService.route(request, (response, routeStatus) => {
                                if (routeStatus === 'OK') {
                                    directionsRenderer.setDirections(response);
                                    console.log("✅ Itinéraire tracé");
                                    
                                    // Ajuster le zoom pour voir tout l'itinéraire
                                    const bounds = new google.maps.LatLngBounds();
                                    bounds.extend(results[0].geometry.location);
                                    bounds.extend(destResults[0].geometry.location);
                                    map.fitBounds(bounds);
                                }
                            });
                        }
                    });
                }
            } else {
                console.error("Erreur géocodage départ:", status);
            }
        });
    }
}
</script>
                    
                    <div class="action-buttons">
                        <% if (trajet.getConducteurId().equals(utilisateur.getId())) { %>
                            <!-- Actions pour le conducteur -->
                            <button class="btn btn-secondary">
                                <i class="fas fa-edit"></i> Modifier
                            </button>
                            <button class="btn btn-danger">
                                <i class="fas fa-times"></i> Annuler
                            </button>
                        <% } else { %>
                            <!-- Actions pour les passagers -->
                            <% if (trajet.getPlacesDisponibles() > 0) { %>
                                <a href="reservations?action=creer&trajetId=<%= trajet.getId() %>" class="btn btn-primary">
                                    <i class="fas fa-check-circle"></i> Réserver
                                </a>
                            <% } else { %>
                                <button class="btn btn-secondary" disabled>
                                    <i class="fas fa-times-circle"></i> Complet
                                </button>
                            <% } %>
                            <button class="btn btn-secondary">
                                <i class="fas fa-question-circle"></i> Contacter
                            </button>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        
        <% } %>
    </div>
</body>
</html>