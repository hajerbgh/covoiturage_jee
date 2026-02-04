package com.covoiturage.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.covoiturage.model.Utilisateur;
import com.covoiturage.util.DatabaseConnection;

public class UtilisateurDAO {
    
    // Créer un utilisateur
    public boolean create(Utilisateur user) {
        String sql = "INSERT INTO utilisateur (nom, prenom, email, mot_de_passe, telephone, role) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, user.getNom());
            pstmt.setString(2, user.getPrenom());
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getMotDePasse());
            pstmt.setString(5, user.getTelephone());
            pstmt.setString(6, user.getRole());
            
            int rows = pstmt.executeUpdate();
            
            if (rows > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    user.setId(rs.getLong(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur création utilisateur: " + e.getMessage());
        }
        return false;
    }
    
    // Trouver par ID
    public Utilisateur findById(Long id) {
        String sql = "SELECT * FROM utilisateur WHERE id = ?";
        Utilisateur user = null;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                user = mapResultSetToUtilisateur(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche utilisateur par ID: " + e.getMessage());
        }
        
        return user;
    }
    
    // Trouver par email
    public Utilisateur findByEmail(String email) {
        String sql = "SELECT * FROM utilisateur WHERE email = ?";
        Utilisateur user = null;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                user = mapResultSetToUtilisateur(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche utilisateur par email: " + e.getMessage());
        }
        
        return user;
    }
    
    // Vérifier login
    public Utilisateur checkLogin(String email, String password) {
        String sql = "SELECT * FROM utilisateur WHERE email = ? AND mot_de_passe = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUtilisateur(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur login: " + e.getMessage());
        }
        
        return null;
    }
    
    // Vérifier le mot de passe
    public boolean verifierMotDePasse(String email, String motDePasse) {
        String sql = "SELECT COUNT(*) FROM utilisateur WHERE email = ? AND mot_de_passe = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            pstmt.setString(2, motDePasse);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur vérification mot de passe: " + e.getMessage());
        }
        
        return false;
    }
    
    // Mettre à jour un utilisateur
    public boolean update(Utilisateur utilisateur) {
        String sql = "UPDATE utilisateur SET nom = ?, prenom = ?, email = ?, telephone = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, utilisateur.getNom());
            pstmt.setString(2, utilisateur.getPrenom());
            pstmt.setString(3, utilisateur.getEmail());
            pstmt.setString(4, utilisateur.getTelephone());
            pstmt.setLong(5, utilisateur.getId());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur mise à jour utilisateur: " + e.getMessage());
            return false;
        }
    }
    
    // Changer le mot de passe
    public boolean updateMotDePasse(Long userId, String nouveauMotDePasse) {
        String sql = "UPDATE utilisateur SET mot_de_passe = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Dans un projet réel, vous devriez hacher le mot de passe
            pstmt.setString(1, nouveauMotDePasse); // À remplacer par un hash sécurisé
            pstmt.setLong(2, userId);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur changement mot de passe: " + e.getMessage());
            return false;
        }
    }
    
    // Mapper ResultSet → Utilisateur
    private Utilisateur mapResultSetToUtilisateur(ResultSet rs) throws SQLException {
        Utilisateur user = new Utilisateur();
        user.setId(rs.getLong("id"));
        user.setNom(rs.getString("nom"));
        user.setPrenom(rs.getString("prenom"));
        user.setEmail(rs.getString("email"));
        user.setMotDePasse(rs.getString("mot_de_passe"));
        user.setTelephone(rs.getString("telephone"));
        user.setRole(rs.getString("role"));
        user.setDateCreation(rs.getTimestamp("date_creation"));
        user.setNoteConducteur(rs.getDouble("note_conducteur"));
        user.setNotePassager(rs.getDouble("note_passager"));
        return user;
    }
}