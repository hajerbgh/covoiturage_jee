package com.covoiturage.util;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Filtre d'authentification qui protège les pages privées
 * Redirige vers la page de connexion si l'utilisateur n'est pas authentifié
 */
public class AuthenticationFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("✅ AuthenticationFilter initialisé");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        System.out.println("🔍 AuthenticationFilter - URL demandée: " + requestURI);
        
        // ==================== LISTE DES PAGES PUBLIQUES ====================
        // Ces pages sont accessibles sans être connecté
        
        String[] publicPages = {
            "/connexion",           // Page de connexion
            "/inscription",         // Page d'inscription
            "/deconnexion",         // Déconnexion
            "/accueil",             // Page d'accueil
            "/test",                // Page de test
            "/"                     // Racine
        };
        
        // Ressources statiques (CSS, JS, images, etc.)
        boolean isStaticResource = 
            requestURI.endsWith(".css") || 
            requestURI.endsWith(".js") ||
            requestURI.endsWith(".jpg") || 
            requestURI.endsWith(".jpeg") ||
            requestURI.endsWith(".png") || 
            requestURI.endsWith(".gif") ||
            requestURI.endsWith(".ico") || 
            requestURI.endsWith(".woff") ||
            requestURI.endsWith(".woff2") || 
            requestURI.endsWith(".ttf") ||
            requestURI.endsWith(".svg");
        
        // Vérifier si c'est une page publique
        boolean isPublicPage = false;
        for (String page : publicPages) {
            if (requestURI.equals(contextPath + page)) {
                isPublicPage = true;
                break;
            }
        }
        
        // Vérifier les pages JSP d'erreur
        boolean isErrorPage = requestURI.contains("/erreur/") || 
                             requestURI.endsWith("404.jsp") || 
                             requestURI.endsWith("500.jsp");
        
        // ==================== LOGIQUE D'AUTHENTIFICATION ====================
        
        // SI c'est une ressource statique OU une page publique OU une page d'erreur
        // OU SI l'utilisateur est connecté (session existe et contient "utilisateur")
        if (isStaticResource || isPublicPage || isErrorPage || 
            (session != null && session.getAttribute("utilisateur") != null)) {
            
            System.out.println("✅ Accès autorisé à: " + requestURI);
            chain.doFilter(request, response); // Laisser passer
            
        } else {
            // SINON, l'utilisateur n'est pas connecté et essaie d'accéder à une page protégée
            
            System.out.println("⛔ Accès refusé à: " + requestURI + " - Redirection vers connexion");
            
            // Sauvegarder l'URL demandée pour rediriger après connexion
            if (session == null) {
                session = httpRequest.getSession(true);
            }
            session.setAttribute("redirectAfterLogin", requestURI);
            
            // Rediriger vers la page de connexion
            httpResponse.sendRedirect(contextPath + "/connexion");
        }
    }
    
    @Override
    public void destroy() {
        System.out.println("❌ AuthenticationFilter détruit");
    }
    
    /**
     * Méthode utilitaire pour vérifier si un utilisateur a un rôle spécifique
     */
    public static boolean hasRole(HttpSession session, String role) {
        if (session == null) return false;
        
        String userRole = (String) session.getAttribute("utilisateurRole");
        return role != null && role.equals(userRole);
    }
    
    /**
     * Méthode utilitaire pour vérifier si un utilisateur est connecté
     */
    public static boolean isLoggedIn(HttpSession session) {
        return session != null && session.getAttribute("utilisateur") != null;
    }
}