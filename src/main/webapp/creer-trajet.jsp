<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.covoiturage.model.Utilisateur" %>
<%
    // Vérifier si l'utilisateur est connecté ET conducteur
    Utilisateur utilisateur = (Utilisateur) session.getAttribute("utilisateur");
    
    if (utilisateur == null) {
        response.sendRedirect("connexion.jsp");
        return;
    }
    
    // Vérifier si c'est un conducteur
    if (!"CONDUCTEUR".equals(utilisateur.getRole())) {
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proposer un trajet - Covoiturage</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Changement : remplacez initMap par initMapPreview -->
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCil5NTW0pDAwlvV5dAYrf3ejVzGTdWjlk&libraries=places&callback=initMapPreview" async defer></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: #f5f7fa;
            min-height: 100vh;
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
            font-size: 2rem;
            color: #4a6cf7;
        }
        
        .logo h1 {
            color: #2d3748;
            font-size: 1.5rem;
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
        
        /* Main Content */
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
        
        .page-header p {
            color: #718096;
        }
        
        /* Form Card */
        .form-card {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }
        
        /* Messages */
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 25px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
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
        
        /* Form Styles */
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            color: #4a5568;
            font-weight: 500;
        }
        
        .form-label i {
            margin-right: 8px;
            color: #4a6cf7;
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
            border-color: #4a6cf7;
        }
        
        .form-control[type="datetime-local"] {
            font-family: inherit;
        }
        
        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }
        
        /* Checkbox Group */
        .checkbox-group {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 10px;
            margin-top: 10px;
        }
        
        .checkbox-option {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .checkbox-option input[type="checkbox"] {
            width: 18px;
            height: 18px;
        }
        
        /* Price Input */
        .price-input {
            position: relative;
        }
        
        .price-input .prefix {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #718096;
        }
        
        .price-input .form-control {
            padding-left: 35px;
        }
        
        .price-input .suffix {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #718096;
        }
        
        /* Form Actions */
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            padding-top: 25px;
            border-top: 1px solid #e2e8f0;
        }
        
        .btn {
            padding: 14px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: #4a6cf7;
            color: white;
            flex: 1;
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
        
        /* Info Box */
        .info-box {
            background: #ebf8ff;
            border-left: 4px solid #4299e1;
            padding: 20px;
            border-radius: 8px;
            margin-top: 30px;
        }
        
        .info-box h4 {
            color: #2d3748;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-box ul {
            color: #4a5568;
            margin-left: 20px;
            line-height: 1.8;
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
            
            .form-card {
                padding: 25px 20px;
            }
            
            .form-actions {
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
            <a href="creer-trajet.jsp" class="active">
                <i class="fas fa-plus-circle"></i> Proposer trajet
            </a>
            <a href="mes-trajets.jsp">
                <i class="fas fa-list"></i> Mes trajets
            </a>
            <a href="deconnexion">
                <i class="fas fa-sign-out-alt"></i> Déconnexion
            </a>
        </nav>
    </header>
    
    <!-- Main Content -->
    <div class="container">
        <div class="page-header">
            <h2><i class="fas fa-road"></i> Proposer un nouveau trajet</h2>
            <p>Remplissez les informations ci-dessous pour partager votre trajet avec d'autres utilisateurs.</p>
        </div>
        
        <!-- Messages d'erreur/succès -->
        <% if (erreur != null && !erreur.isEmpty()) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= erreur %>
            </div>
        <% } %>
        
        <% if (success != null && !success.isEmpty()) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= success %>
            </div>
        <% } %>
        
        <div class="form-card">
            <form action="trajets" method="post">
                <!-- Informations de base -->
                <div class="form-group">
                    <h3 style="color: #2d3748; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #e2e8f0;">
                        <i class="fas fa-info-circle"></i> Informations du trajet
                    </h3>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-map-marker-alt"></i> Ville de départ
                            </label>
                            <input type="text" name="villeDepart" class="form-control" required 
                                   placeholder="Ex: Tunis">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-map-marker-alt"></i> Ville de destination
                            </label>
                            <input type="text" name="villeDestination" class="form-control" required
                                   placeholder="Ex: Sousse">
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-road"></i> Adresse de départ (optionnel)
                            </label>
                            <input type="text" name="adresseDepart" class="form-control"
                                   placeholder="Adresse précise ou point de rendez-vous">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-flag-checkered"></i> Adresse d'arrivée (optionnel)
                            </label>
                            <input type="text" name="adresseDestination" class="form-control"
                                   placeholder="Adresse précise à destination">
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-calendar-alt"></i> Date et heure de départ
                            </label>
                            <input type="datetime-local" name="dateDepart" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-chair"></i> Nombre de places disponibles
                            </label>
                            <input type="number" name="placesDisponibles" class="form-control" 
                                   min="1" max="8" value="3" required>
                            <small style="color: #718096; font-size: 0.9rem;">
                                Nombre maximum de passagers que vous pouvez prendre
                            </small>
                        </div>
                    </div>
                </div>
                
                <!-- Prix et options -->
                <div class="form-group">
                    <h3 style="color: #2d3748; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #e2e8f0;">
                        <i class="fas fa-money-bill-wave"></i> Tarif et options
                    </h3>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-tag"></i> Prix par place (DT)
                            </label>
                            <div class="price-input">
                                <span class="prefix">DT</span>
                                <input type="number" name="prixParPlace" class="form-control" 
                                       step="0.5" min="0" value="10.0" required>
                                <span class="suffix">par personne</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-comment-alt"></i> Description (optionnel)
                        </label>
                        <textarea name="description" class="form-control" 
                                  placeholder="Informations supplémentaires sur le trajet..."></textarea>
                    </div>
                </div>
                
                <!-- Restrictions -->
                <div class="form-group">
                    <h3 style="color: #2d3748; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #e2e8f0;">
                        <i class="fas fa-ban"></i> Restrictions (optionnel)
                    </h3>
                    
                    <div class="checkbox-group">
                        <div class="checkbox-option">
                            <input type="checkbox" id="nonFumeur" name="restrictions" value="non-fumeur">
                            <label for="nonFumeur">🚭 Non-fumeur</label>
                        </div>
                        
                        <div class="checkbox-option">
                            <input type="checkbox" id="pasAnimaux" name="restrictions" value="pas-animaux">
                            <label for="pasAnimaux">🐕 Pas d'animaux</label>
                        </div>
                        
                        <div class="checkbox-option">
                            <input type="checkbox" id="bagageLimite" name="restrictions" value="bagage-limite">
                            <label for="bagageLimite">🎒 Bagage limité</label>
                        </div>
                        
                        <div class="checkbox-option">
                            <input type="checkbox" id="musiqueAutorisee" name="restrictions" value="musique-autorisee">
                            <label for="musiqueAutorisee">🎵 Musique autorisée</label>
                        </div>
                        
                        <div class="checkbox-option">
                            <input type="checkbox" id="discussionAutorisee" name="restrictions" value="discussion-autorisee">
                            <label for="discussionAutorisee">💬 Discussion autorisée</label>
                        </div>
                        
                        <div class="checkbox-option">
                            <input type="checkbox" id="climatisation" name="restrictions" value="climatisation">
                            <label for="climatisation">❄️ Climatisation</label>
                        </div>
                    </div>
                    
                    <div class="form-group" style="margin-top: 15px;">
                        <label class="form-label">
                            <i class="fas fa-sticky-note"></i> Autres restrictions
                        </label>
                        <input type="text" name="autresRestrictions" class="form-control"
                               placeholder="Autres conditions spécifiques...">
                    </div>
                </div>
                <!-- Ajoutez après votre formulaire existant -->

<div class="map-section" style="margin-top: 30px;">
    <h3><i class="fas fa-map"></i> Prévisualisation sur la carte</h3>
    
    <div id="map-preview" style="height: 300px; width: 100%; border: 2px dashed #ddd; border-radius: 8px; margin: 15px 0;"></div>
    
    <div style="display: flex; gap: 10px; margin-top: 10px;">
        <button type="button" id="btn-locate" class="btn btn-outline-secondary">
            <i class="fas fa-location-arrow"></i> Me localiser
        </button>
        <button type="button" id="btn-test-route" class="btn btn-outline-primary">
            <i class="fas fa-route"></i> Tester l'itinéraire
        </button>
    </div>
    
    <!-- Champs cachés pour les coordonnées -->
    <input type="hidden" id="depart-lat" name="departLat">
    <input type="hidden" id="depart-lng" name="departLng">
    <input type="hidden" id="destination-lat" name="destinationLat">
    <input type="hidden" id="destination-lng" name="destinationLng">
</div>

<script>
function initMap() {
    console.log("✅ Google Maps API a appelé initMap()");
    if (typeof initMapPreview === 'function') {
        initMapPreview();
    } else {
        console.error("❌ initMapPreview() non trouvée");
    }
}
let map;
let departMarker;
let destinationMarker;

// Initialiser la carte
function initMapPreview() {
    console.log("Initialisation de la carte...");
    
    // Vérifier si Google Maps est disponible
    if (typeof google === 'undefined') {
        console.error("Google Maps API non chargée");
        document.getElementById('map-preview').innerHTML = 
            '<div style="padding: 20px; text-align: center; color: #666;">' +
            '<i class="fas fa-exclamation-triangle"></i> ' +
            'Google Maps non chargé. Vérifiez votre connexion internet.</div>';
        return;
    }
    
    if (typeof google.maps === 'undefined') {
        console.error("google.maps non défini");
        return;
    }
    
    try {
        map = new google.maps.Map(document.getElementById('map-preview'), {
            center: { lat: 36.8065, lng: 10.1815 },
            zoom: 12,
            mapTypeControl: true,
            streetViewControl: false,
            fullscreenControl: true
        });
        
        console.log("Carte Google Maps créée avec succès");
        
        // Écouter les changements dans les champs d'adresse
        const departInput = document.querySelector('input[name="villeDepart"]');
        const destinationInput = document.querySelector('input[name="villeDestination"]');
        
        if (!departInput || !destinationInput) {
            console.error("Champs d'adresse non trouvés");
            return;
        }
        
        // Autocomplete pour les champs
        try {
            const autocompleteDepart = new google.maps.places.Autocomplete(departInput);
            const autocompleteDestination = new google.maps.places.Autocomplete(destinationInput);
            
            console.log("Autocomplete initialisé");
            
            // Quand une adresse est sélectionnée
            autocompleteDepart.addListener('place_changed', function() {
                const place = autocompleteDepart.getPlace();
                if (place.geometry) {
                    console.log("Adresse départ sélectionnée:", place.formatted_address);
                    updateDepartMarker(place.geometry.location);
                    updateHiddenCoords('depart', place.geometry.location);
                }
            });
            
            autocompleteDestination.addListener('place_changed', function() {
                const place = autocompleteDestination.getPlace();
                if (place.geometry) {
                    console.log("Adresse destination sélectionnée:", place.formatted_address);
                    updateDestinationMarker(place.geometry.location);
                    updateHiddenCoords('destination', place.geometry.location);
                }
            });
            
        } catch (error) {
            console.error("Erreur autocomplete:", error);
        }
        
        // Bouton de localisation
        document.getElementById('btn-locate').addEventListener('click', function() {
            console.log("Bouton localisation cliqué");
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    const pos = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude
                    };
                    console.log("Position obtenue:", pos);
                    map.setCenter(pos);
                    map.setZoom(14);
                    
                    // Remplir le champ départ
                    reverseGeocode(pos, 'depart');
                }, function(error) {
                    console.error("Erreur géolocalisation:", error);
                    alert("Impossible d'obtenir votre position. Vérifiez les permissions de géolocalisation.");
                });
            } else {
                alert("La géolocalisation n'est pas supportée par votre navigateur.");
            }
        });
        
        // Bouton test itinéraire
        document.getElementById('btn-test-route').addEventListener('click', function() {
            const depart = departInput.value;
            const destination = destinationInput.value;
            
            console.log("Test itinéraire:", depart, "->", destination);
            
            if (depart && destination) {
                calculateRoute(depart, destination);
            } else {
                alert('Veuillez remplir les deux adresses');
            }
        });
        
    } catch (error) {
        console.error("Erreur création carte:", error);
        document.getElementById('map-preview').innerHTML = 
            '<div style="padding: 20px; text-align: center; color: #666;">' +
            '<i class="fas fa-exclamation-triangle"></i> ' +
            'Erreur création carte: ' + error.message + '</div>';
    }
}

function updateDepartMarker(position) {
    if (departMarker) departMarker.setMap(null);
    
    departMarker = new google.maps.Marker({
        position: position,
        map: map,
        title: 'Départ',
        icon: {
            url: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png'
        },
        draggable: true
    });
    
    // Écouter le drag
    departMarker.addListener('dragend', function() {
        const newPos = departMarker.getPosition();
        updateHiddenCoords('depart', newPos);
        reverseGeocode(newPos, 'depart');
    });
    
    map.panTo(position);
    console.log("Marqueur départ mis à jour:", position);
}

function updateDestinationMarker(position) {
    if (destinationMarker) destinationMarker.setMap(null);
    
    destinationMarker = new google.maps.Marker({
        position: position,
        map: map,
        title: 'Arrivée',
        icon: {
            url: 'https://maps.google.com/mapfiles/ms/icons/red-dot.png'
        },
        draggable: true
    });
    
    // Écouter le drag
    destinationMarker.addListener('dragend', function() {
        const newPos = destinationMarker.getPosition();
        updateHiddenCoords('destination', newPos);
        reverseGeocode(newPos, 'destination');
    });
    
    console.log("Marqueur destination mis à jour:", position);
}

function updateHiddenCoords(type, position) {
    const lat = position.lat();
    const lng = position.lng();
    
    console.log("Coordonnées mises à jour:", type, lat, lng);
    
    if (type === 'depart') {
        document.getElementById('depart-lat').value = lat;
        document.getElementById('depart-lng').value = lng;
    } else {
        document.getElementById('destination-lat').value = lat;
        document.getElementById('destination-lng').value = lng;
    }
}

function reverseGeocode(position, fieldType) {
    const geocoder = new google.maps.Geocoder();
    geocoder.geocode({ location: position }, function(results, status) {
        if (status === 'OK' && results[0]) {
            const fieldName = fieldType === 'depart' ? 'villeDepart' : 'villeDestination';
            const inputField = document.querySelector('input[name="' + fieldName + '"]');
            inputField.value = results[0].formatted_address;
            updateHiddenCoords(fieldType, position);
            
            if (fieldType === 'depart') {
                updateDepartMarker(position);
            } else {
                updateDestinationMarker(position);
            }
            console.log("Reverse geocode réussi:", results[0].formatted_address);
        } else {
            console.error("Reverse geocode échoué:", status);
        }
    });
}

function calculateRoute(depart, destination) {
    console.log("Calcul itinéraire en cours...");
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
        origin: depart + ', Tunisie',
        destination: destination + ', Tunisie',
        travelMode: 'DRIVING',
        unitSystem: google.maps.UnitSystem.METRIC
    };
    
    directionsService.route(request, function(response, status) {
        if (status === 'OK') {
            directionsRenderer.setDirections(response);
            
            // Récupérer les coordonnées du tracé
            const route = response.routes[0];
            if (route.legs[0]) {
                const startLocation = route.legs[0].start_location;
                const endLocation = route.legs[0].end_location;
                
                // Mettre à jour les champs cachés
                updateHiddenCoords('depart', startLocation);
                updateHiddenCoords('destination', endLocation);
                
                // Mettre à jour les marqueurs
                updateDepartMarker(startLocation);
                updateDestinationMarker(endLocation);
                
                // Afficher la distance et durée
                const distance = route.legs[0].distance.text;
                const duration = route.legs[0].duration.text;
                
                // Utiliser la concaténation
                alert('Itinéraire trouvé !\nDistance: ' + distance + '\nDurée: ' + duration);
                
                console.log("Itinéraire calculé:", distance, duration);
            }
        } else {
            console.error("Erreur calcul itinéraire:", status);
            alert('Impossible de calculer l\'itinéraire. Vérifiez les adresses.');
        }
    });
}

// Initialiser quand la page est prête
document.addEventListener('DOMContentLoaded', function() {
    console.log("Page chargée, initialisation de la carte...");
    
    // Vérifier si Google Maps est chargé
    if (typeof google !== 'undefined') {
        console.log("Google Maps API détectée");
        // Petit délai pour s'assurer que tout est chargé
        setTimeout(initMapPreview, 500);
    } else {
        console.error("Google Maps API non détectée");
        document.getElementById('map-preview').innerHTML = 
            '<div style="padding: 20px; text-align: center; color: #666;">' +
            '<i class="fas fa-exclamation-triangle"></i> ' +
            'Google Maps API non chargée. Vérifiez votre connexion internet.</div>';
    }
});
</script>
                
                <!-- Boutons -->
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-paper-plane"></i> Proposer le trajet
                    </button>
                    <a href="dashboard.jsp" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Annuler
                    </a>
                </div>
            </form>
        </div>
        
        <!-- Info Box -->
        <div class="info-box">
            <h4><i class="fas fa-lightbulb"></i> Conseils pour un bon trajet</h4>
            <ul>
                <li>Indiquez des informations claires et précises sur les lieux de départ et d'arrivée</li>
                <li>Fixez un prix raisonnable qui couvre vos frais sans être excessif</li>
                <li>Précisez vos préférences et restrictions pour éviter les malentendus</li>
                <li>Assurez-vous que votre véhicule est en bon état et dispose de toutes les assurances nécessaires</li>
                <li>Soyez ponctuel et communiquez clairement avec vos passagers</li>
            </ul>
        </div>
    </div>
    
    <!-- JavaScript pour améliorer l'expérience utilisateur -->
    <script>
        // Pré-remplir la date et heure (maintenant + 1 heure)
        function setDefaultDateTime() {
            const now = new Date();
            now.setHours(now.getHours() + 1);
            now.setMinutes(0);
            now.setSeconds(0);
            
            const formatted = now.toISOString().slice(0, 16);
            document.querySelector('input[name="dateDepart"]').value = formatted;
        }
        
        // Calcul automatique du prix suggéré basé sur la distance
        document.querySelector('input[name="villeDepart"]').addEventListener('blur', function() {
            const depart = this.value.trim();
            const destination = document.querySelector('input[name="villeDestination"]').value.trim();
            
            if (depart && destination) {
                // Ici, vous pourriez appeler une API pour calculer la distance
                // et suggérer un prix en fonction de la distance
                console.log("Calcul du prix pour " + depart + " → " + destination);
            }
        });
        
        // Initialisation
        document.addEventListener('DOMContentLoaded', function() {
            setDefaultDateTime();
            
            // Afficher un message de confirmation avant soumission
         // Afficher un message de confirmation avant soumission
            const form = document.querySelector('form');
            form.addEventListener('submit', function(e) {
                const places = document.querySelector('input[name="placesDisponibles"]').value;
                const prix = document.querySelector('input[name="prixParPlace"]').value;
                
                // concaténation au lieu de template literal
                const confirmation = 'Vous êtes sur le point de proposer un trajet avec ' + places + 
                                   ' place(s) au prix de ' + prix + ' DT par personne. Continuer ?';
                
                if (!confirm(confirmation)) {
                    e.preventDefault();
                }
            });
        });
    </script>
</body>
</html>