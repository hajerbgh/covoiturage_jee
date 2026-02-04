package com.covoiturage.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.covoiturage.model.Notification;
import com.covoiturage.util.DatabaseConnection;

public class NotificationDAO {
    
    // Créer une notification
    public boolean create(Notification notification) {
        String sql = "INSERT INTO notifications (utilisateur_id, type, titre, message, url, lue, date_notification) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setLong(1, notification.getUtilisateurId());
            pstmt.setString(2, notification.getType());
            pstmt.setString(3, notification.getTitre());
            pstmt.setString(4, notification.getMessage());
            pstmt.setString(5, notification.getUrl());
            pstmt.setBoolean(6, notification.isLue());
            pstmt.setTimestamp(7, new Timestamp(notification.getDateNotification().getTime()));
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        notification.setId(generatedKeys.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur création notification: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Notifier quand un avis est reçu
    public boolean notifierNouvelAvis(Long utilisateurId, String evaluateurNom, int note, Long trajetId) {
        Notification notification = new Notification(
            utilisateurId,
            "AVIS",
            "Nouvel avis reçu",
            evaluateurNom + " vous a évalué avec " + note + "/5 étoiles",
            "mes-avis"
        );
        return create(notification);
    }
    
    // Récupérer les notifications d'un utilisateur
    public List<Notification> findByUtilisateurId(Long utilisateurId, boolean nonLuesSeulement) {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE utilisateur_id = ?";
        
        if (nonLuesSeulement) {
            sql += " AND lue = FALSE";
        }
        
        sql += " ORDER BY date_notification DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, utilisateurId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapResultSetToNotification(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur récupération notifications: " + e.getMessage());
            e.printStackTrace();
        }
        return notifications;
    }
    
    // Compter les notifications non lues
    public int countNonLues(Long utilisateurId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE utilisateur_id = ? AND lue = FALSE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, utilisateurId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur comptage notifications: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    // Marquer une notification comme lue
    public boolean marquerCommeLue(Long notificationId) {
        String sql = "UPDATE notifications SET lue = TRUE WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, notificationId);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Erreur marquer notification lue: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Marquer toutes les notifications comme lues
    public boolean marquerToutesCommeLues(Long utilisateurId) {
        String sql = "UPDATE notifications SET lue = TRUE WHERE utilisateur_id = ? AND lue = FALSE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, utilisateurId);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Erreur marquer toutes notifications lues: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Supprimer une notification
    public boolean delete(Long notificationId) {
        String sql = "DELETE FROM notifications WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, notificationId);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Erreur suppression notification: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Mapper ResultSet vers Notification
    private Notification mapResultSetToNotification(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        
        notification.setId(rs.getLong("id"));
        notification.setUtilisateurId(rs.getLong("utilisateur_id"));
        notification.setType(rs.getString("type"));
        notification.setTitre(rs.getString("titre"));
        notification.setMessage(rs.getString("message"));
        notification.setUrl(rs.getString("url"));
        notification.setLue(rs.getBoolean("lue"));
        notification.setDateNotification(rs.getTimestamp("date_notification"));
        
        return notification;
    }
}