<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accueil - Covoiturage Écologique</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Reset et styles de base */
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
            font-family: 'Poppins', 'Segoe UI', sans-serif; 
        }
        
        body { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
            overflow-x: hidden;
        }
        
        /* Effet de particules animées */
        .particles {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 0;
        }
        
        .particle {
            position: absolute;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            animation: float 15s infinite linear;
        }
        
        @keyframes float {
            0% { transform: translateY(0) translateX(0); }
            25% { transform: translateY(-100px) translateX(100px); }
            50% { transform: translateY(-200px) translateX(0); }
            75% { transform: translateY(-100px) translateX(-100px); }
            100% { transform: translateY(0) translateX(0); }
        }
        
        /* Container principal */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            position: relative;
            z-index: 1;
        }
        
        /* Header */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 0;
            margin-bottom: 40px;
        }
        
        .logo {
            display: flex;
            align-items: center;
            gap: 15px;
            color: white;
            text-decoration: none;
            transition: transform 0.3s;
        }
        
        .logo:hover {
            transform: scale(1.05);
        }
        
        .logo-icon {
            font-size: 2.5rem;
            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.2));
        }
        
        .logo-text h1 {
            font-size: 1.8rem;
            font-weight: 700;
            letter-spacing: -0.5px;
        }
        
        .logo-text p {
            font-size: 0.9rem;
            opacity: 0.9;
            font-weight: 300;
        }
        
        /* Navigation */
        .nav-links {
            display: flex;
            gap: 30px;
        }
        
        .nav-link {
            color: white;
            text-decoration: none;
            font-weight: 500;
            padding: 8px 16px;
            border-radius: 25px;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .nav-link:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
        }
        
        /* Section héros */
        .hero-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 60px;
            align-items: center;
            margin-bottom: 60px;
        }
        
        .hero-content h2 {
            font-size: 3.5rem;
            color: white;
            margin-bottom: 20px;
            line-height: 1.2;
            font-weight: 800;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }
        
        .hero-content p {
            font-size: 1.1rem;
            color: rgba(255, 255, 255, 0.9);
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        .highlight {
            color: #ffd166;
            font-weight: 700;
        }
        
        /* Carte de connexion */
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            border: 1px solid rgba(255, 255, 255, 0.2);
            transform: translateY(0);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .login-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 30px 80px rgba(0,0,0,0.2);
        }
        
        .card-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .card-icon {
            font-size: 3rem;
            color: #667eea;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .card-header h3 {
            font-size: 1.8rem;
            color: #2d3748;
            margin-bottom: 10px;
        }
        
        .card-header p {
            color: #718096;
        }
        
        /* Boutons */
        .btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;
            padding: 16px;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }
        
        .btn::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 5px;
            height: 5px;
            background: rgba(255, 255, 255, 0.5);
            opacity: 0;
            border-radius: 100%;
            transform: scale(1, 1) translate(-50%);
            transform-origin: 50% 50%;
        }
        
        .btn:focus:not(:active)::after {
            animation: ripple 1s ease-out;
        }
        
        @keyframes ripple {
            0% { transform: scale(0, 0); opacity: 0.5; }
            100% { transform: scale(20, 20); opacity: 0; }
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            margin-bottom: 15px;
        }
        
        .btn-primary:hover {
            background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
            transform: translateY(-2px);
        }
        
        .btn-secondary {
            background: #48bb78;
            color: white;
            margin-bottom: 15px;
        }
        
        .btn-secondary:hover {
            background: #38a169;
            box-shadow: 0 10px 30px rgba(72, 187, 120, 0.4);
            transform: translateY(-2px);
        }
        
        /* Message de bienvenue */
        .welcome-message {
            margin: 20px 0;
            padding: 15px;
            background: linear-gradient(135deg, #c6f6d5 0%, #9ae6b4 100%);
            border-radius: 12px;
            color: #22543d;
            text-align: center;
            animation: slideIn 0.5s ease-out;
        }
        
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .welcome-message i {
            margin-right: 10px;
        }
        
        /* Statistiques */
        .stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-top: 40px;
        }
        
        .stat-item {
            text-align: center;
            padding: 20px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .stat-number {
            display: block;
            font-size: 2.5rem;
            font-weight: 700;
            color: white;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: rgba(255, 255, 255, 0.8);
            font-size: 0.9rem;
        }
        
        /* Footer */
        .footer {
            margin-top: 60px;
            padding-top: 40px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            text-align: center;
            color: rgba(255, 255, 255, 0.7);
        }
        
        .footer-links {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin-bottom: 20px;
        }
        
        .footer-link {
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            transition: color 0.3s;
        }
        
        .footer-link:hover {
            color: white;
        }
        
        .copyright {
            font-size: 0.9rem;
        }
        
        /* Responsive */
        @media (max-width: 992px) {
            .hero-section {
                grid-template-columns: 1fr;
                text-align: center;
            }
            
            .hero-content h2 {
                font-size: 2.8rem;
            }
            
            .stats {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 20px;
            }
            
            .nav-links {
                flex-wrap: wrap;
                justify-content: center;
            }
            
            .hero-content h2 {
                font-size: 2.2rem;
            }
            
            .stats {
                grid-template-columns: 1fr;
            }
            
            .login-card {
                padding: 30px;
            }
        }
        
        @media (max-width: 480px) {
            .hero-content h2 {
                font-size: 1.8rem;
            }
            
            .card-header h3 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <!-- Effet de particules -->
    <div class="particles" id="particles"></div>
    
    <div class="container">
        <!-- Header -->
        <header class="header">
            <a href="#" class="logo">
                <div class="logo-icon">
                    <i class="fas fa-leaf"></i>
                </div>
                <div class="logo-text">
                    <h1>EcoRide</h1>
                    <p>Partage écologique</p>
                </div>
            </a>
            
            <nav class="nav-links">
                <a href="#features" class="nav-link">
                    <i class="fas fa-star"></i> Avantages
                </a>
                <a href="#how-it-works" class="nav-link">
                    <i class="fas fa-question-circle"></i> Comment ça marche
                </a>
                <a href="#contact" class="nav-link">
                    <i class="fas fa-envelope"></i> Contact
                </a>
            </nav>
        </header>
        
        <!-- Section principale -->
        <section class="hero-section">
            <div class="hero-content">
                <h2>Partagez votre trajet, <span class="highlight">économisez la planète</span></h2>
                <p>Rejoignez notre communauté de covoitureurs engagés. Réduisez vos dépenses, vos émissions CO₂ et faites de nouvelles rencontres sur vos trajets quotidiens.</p>
                
                <!-- Statistiques -->
                <div class="stats">
                    <div class="stat-item">
                        <span class="stat-number">5 000+</span>
                        <span class="stat-label">Utilisateurs</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">25 000+</span>
                        <span class="stat-label">Trajets réalisés</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">150T</span>
                        <span class="stat-label">CO₂ économisé</span>
                    </div>
                </div>
            </div>
            
            <!-- Carte de connexion -->
            <div class="login-card">
                <div class="card-header">
                    <div class="card-icon">
                        <i class="fas fa-car"></i>
                    </div>
                    <h3>Commencez l'aventure</h3>
                    <p>Rejoignez notre plateforme en quelques clics</p>
                </div>
                
                <%-- Message si déconnexion récente --%>
                <% if (request.getParameter("deconnecte") != null) { %>
                    <div class="welcome-message">
                        <i class="fas fa-check-circle"></i> Vous avez été déconnecté avec succès
                    </div>
                <% } %>
                
                <a href="connexion.jsp" class="btn btn-primary">
                    <i class="fas fa-sign-in-alt"></i> Se connecter
                </a>
                
                <a href="inscription.jsp" class="btn btn-secondary">
                    <i class="fas fa-user-plus"></i> Créer un compte
                </a>
                
                <div style="margin-top: 20px; color: #718096; font-size: 0.9rem; text-align: center;">
                    <p>En vous inscrivant, vous acceptez nos <a href="#" style="color: #667eea;">conditions d'utilisation</a></p>
                </div>
            </div>
        </section>
        
        <!-- Footer -->
        <footer class="footer">
            <div class="footer-links">
                <a href="#about" class="footer-link">À propos</a>
                <a href="#privacy" class="footer-link">Confidentialité</a>
                <a href="#terms" class="footer-link">Conditions</a>
                <a href="#help" class="footer-link">Aide</a>
            </div>
            <div class="copyright">
                <p>&copy; 2023 EcoRide - Covoiturage écologique. Tous droits réservés.</p>
            </div>
        </footer>
    </div>
    
    <script>
        // Création des particules animées
        function createParticles() {
            const particlesContainer = document.getElementById('particles');
            const particleCount = 20;
            
            for (let i = 0; i < particleCount; i++) {
                const particle = document.createElement('div');
                particle.className = 'particle';
                
                // Taille aléatoire
                const size = Math.random() * 60 + 10;
                particle.style.width = `${size}px`;
                particle.style.height = `${size}px`;
                
                // Position aléatoire
                particle.style.left = `${Math.random() * 100}%`;
                particle.style.top = `${Math.random() * 100}%`;
                
                // Opacité aléatoire
                particle.style.opacity = Math.random() * 0.3 + 0.1;
                
                // Animation delay
                particle.style.animationDelay = `${Math.random() * 15}s`;
                
                particlesContainer.appendChild(particle);
            }
        }
        
        // Effet de parallaxe sur le header
        window.addEventListener('scroll', () => {
            const scrolled = window.pageYOffset;
            const parallax = document.querySelector('.header');
            parallax.style.transform = `translateY(${scrolled * 0.3}px)`;
        });
        
        // Animation au chargement
        window.addEventListener('load', () => {
            createParticles();
            
            // Animation d'entrée
            const elements = document.querySelectorAll('.hero-content, .login-card, .stats');
            elements.forEach((el, index) => {
                el.style.opacity = '0';
                el.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    el.style.transition = 'opacity 0.8s ease, transform 0.8s ease';
                    el.style.opacity = '1';
                    el.style.transform = 'translateY(0)';
                }, index * 200);
            });
        });
        
        // Effet de survol amélioré pour les boutons
        document.querySelectorAll('.btn').forEach(button => {
            button.addEventListener('mouseenter', function(e) {
                const x = e.pageX - this.offsetLeft;
                const y = e.pageY - this.offsetTop;
                
                this.style.setProperty('--x', `${x}px`);
                this.style.setProperty('--y', `${y}px`);
            });
        });
    </script>
</body>
</html>