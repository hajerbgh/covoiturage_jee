package com.covoiturage.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.covoiturage.model.Voiture;
import com.covoiturage.util.DatabaseConnection;

public class VoitureDAO {
    
    // Créer une voiture
    public boolean create(Voiture voiture) {
        String sql = "INSERT INTO voiture (marque, modele, matricule, nombre_places, conducteur_id) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, voiture.getMarque());
            pstmt.setString(2, voiture.getModele());
            pstmt.setString(3, voiture.getMatricule());
            pstmt.setInt(4, voiture.getNombrePlaces());
            pstmt.setLong(5, voiture.getConducteurId());
            
            int rows = pstmt.executeUpdate();
            
            if (rows > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    voiture.setId(rs.getLong(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur création voiture: " + e.getMessage());
        }
        return false;
    }
    
    // Trouver par ID
    public Voiture findById(Long id) {
        String sql = "SELECT * FROM voiture WHERE id = ?";
        Voiture voiture = null;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                voiture = mapResultSetToVoiture(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche voiture: " + e.getMessage());
        }
        
        return voiture;
    }
    
    // Trouver toutes les voitures d'un conducteur
    public List<Voiture> findByConducteurId(Long conducteurId) {
        String sql = "SELECT * FROM voiture WHERE conducteur_id = ?";
        List<Voiture> voitures = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, conducteurId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                voitures.add(mapResultSetToVoiture(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche voitures conducteur: " + e.getMessage());
        }
        
        return voitures;
    }
    
    // Supprimer une voiture
    public boolean delete(Long id) {
        String sql = "DELETE FROM voiture WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, id);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur suppression voiture: " + e.getMessage());
        }
        return false;
    }
    
    // Mapper ResultSet → Voiture
    private Voiture mapResultSetToVoiture(ResultSet rs) throws SQLException {
        Voiture voiture = new Voiture();
        voiture.setId(rs.getLong("id"));
        voiture.setMarque(rs.getString("marque"));
        voiture.setModele(rs.getString("modele"));
        voiture.setMatricule(rs.getString("matricule"));
        voiture.setNombrePlaces(rs.getInt("nombre_places"));
        voiture.setConducteurId(rs.getLong("conducteur_id"));
        return voiture;
    }
}