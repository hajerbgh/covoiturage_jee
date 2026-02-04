package com.covoiturage.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    
    // IMPORTANT: URL pour MySQL 8+
    private static final String URL = "jdbc:mysql://localhost:3306/covoiturage_app?"
            + "useSSL=false&"
            + "allowPublicKeyRetrieval=true&"
            + "serverTimezone=UTC&"
            + "useUnicode=true&"
            + "characterEncoding=UTF-8";
    
    private static final String USER = "root";
    private static final String PASSWORD = "Hajer.2003";
    
    static {
        try {
            // DRIVER POUR MySQL 8+ et Java 17
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ Driver MySQL 8+ chargé avec succès");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ ERREUR: Driver MySQL introuvable");
            System.err.println("Solution:");
            System.err.println("1. Téléchargez mysql-connector-j-8.1.0.jar");
            System.err.println("2. Placez-le dans: WebContent/WEB-INF/lib/");
            System.err.println("3. Clic-droit → Build Path → Add to Build Path");
            e.printStackTrace();
        }
    }
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
    
    public static String testConnection() {
        try {
            Connection conn = getConnection();
            if (conn != null && !conn.isClosed()) {
                return "✅ Connecté à MySQL - Base: covoiturage_app";
            } else {
                return "❌ Connexion échouée";
            }
        } catch (SQLException e) {
            return "❌ Erreur: " + e.getMessage();
        }
    }
}