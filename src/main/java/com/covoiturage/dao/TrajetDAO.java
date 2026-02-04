package com.covoiturage.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.covoiturage.model.Trajet;
import com.covoiturage.util.DatabaseConnection;

public class TrajetDAO {
    
    // Créer un trajet
	public boolean create(Trajet trajet) {
	    String sql = "INSERT INTO trajet (depart, destination, date_depart, prix, places_disponibles, " +
	                 "description, restrictions, statut, conducteur_id, voiture_id, " +
	                 "depart_lat, depart_lng, destination_lat, destination_lng) " +
	                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	    
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
	        
	        pstmt.setString(1, trajet.getDepart());
	        pstmt.setString(2, trajet.getDestination());
	        pstmt.setTimestamp(3, new Timestamp(trajet.getDateDepart().getTime()));
	        pstmt.setDouble(4, trajet.getPrix());
	        pstmt.setInt(5, trajet.getPlacesDisponibles());
	        pstmt.setString(6, trajet.getDescription());
	        pstmt.setString(7, trajet.getRestrictions());
	        pstmt.setString(8, trajet.getStatut());
	        pstmt.setLong(9, trajet.getConducteurId());
	        pstmt.setLong(10, trajet.getVoitureId());
	        
	        // Ajoutez les coordonnées (peuvent être null)
	        pstmt.setObject(11, trajet.getDepartLat());
	        pstmt.setObject(12, trajet.getDepartLng());
	        pstmt.setObject(13, trajet.getDestinationLat());
	        pstmt.setObject(14, trajet.getDestinationLng());
	        
	        int rowsAffected = pstmt.executeUpdate();
	        
	        if (rowsAffected > 0) {
	            ResultSet rs = pstmt.getGeneratedKeys();
	            if (rs.next()) {
	                trajet.setId(rs.getLong(1));
	            }
	            return true;
	        }
	        
	    } catch (SQLException e) {
	        System.err.println("❌ Erreur création trajet: " + e.getMessage());
	        e.printStackTrace();
	    }
	    return false;
	}
    
    // Trouver par ID
    public Trajet findById(Long id) {
        String sql = "SELECT * FROM trajet WHERE id = ?";
        Trajet trajet = null;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                trajet = mapResultSetToTrajet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche trajet: " + e.getMessage());
        }
        
        return trajet;
    }
    
    // Rechercher des trajets
    public List<Trajet> search(String depart, String destination, String date, Double prixMax) {
        StringBuilder sql = new StringBuilder("SELECT * FROM trajet WHERE statut = 'ACTIF' AND places_disponibles > 0");
        List<Object> params = new ArrayList<>();
        
        if (depart != null && !depart.isEmpty()) {
            sql.append(" AND depart LIKE ?");
            params.add("%" + depart + "%");
        }
        
        if (destination != null && !destination.isEmpty()) {
            sql.append(" AND destination LIKE ?");
            params.add("%" + destination + "%");
        }
        
        if (date != null && !date.isEmpty()) {
            sql.append(" AND DATE(date_depart) = ?");
            params.add(date);
        }
        
        if (prixMax != null && prixMax > 0) {
            sql.append(" AND prix <= ?");
            params.add(prixMax);
        }
        
        sql.append(" ORDER BY date_depart ASC");
        
        List<Trajet> trajets = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                trajets.add(mapResultSetToTrajet(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche trajets: " + e.getMessage());
        }
        
        return trajets;
    }
    //trajets par conducteur
    public int countByConducteur(Long conducteurId) {
        String sql = "SELECT COUNT(*) FROM trajet WHERE conducteur_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, conducteurId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Erreur countByConducteur: " + e.getMessage());
        }
        return 0;
    }
   
        
        
    
    // Trouver les trajets d'un conducteur
    public List<Trajet> findByConducteur(Long conducteurId) {
        String sql = "SELECT * FROM trajet WHERE conducteur_id = ? ORDER BY date_depart DESC";
        List<Trajet> trajets = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, conducteurId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                trajets.add(mapResultSetToTrajet(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche trajets conducteur: " + e.getMessage());
        }
        
        return trajets;
    }
    
    // Mettre à jour les places disponibles
    public boolean updatePlaces(Long trajetId, int nouvellesPlaces) {
        String sql = "UPDATE trajet SET places_disponibles = ?, statut = CASE WHEN ? = 0 THEN 'COMPLET' ELSE statut END WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, nouvellesPlaces);
            pstmt.setInt(2, nouvellesPlaces);
            pstmt.setLong(3, trajetId);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur mise à jour places: " + e.getMessage());
        }
        return false;
    }
    
    // Mapper ResultSet → Trajet
    private Trajet mapResultSetToTrajet(ResultSet rs) throws SQLException {
        Trajet trajet = new Trajet();
        
        trajet.setId(rs.getLong("id"));
        trajet.setDepart(rs.getString("depart"));
        trajet.setDestination(rs.getString("destination"));
        trajet.setDateDepart(rs.getTimestamp("date_depart"));
        trajet.setPrix(rs.getDouble("prix"));
        trajet.setPlacesDisponibles(rs.getInt("places_disponibles"));
        trajet.setDescription(rs.getString("description"));
        trajet.setRestrictions(rs.getString("restrictions"));
        trajet.setStatut(rs.getString("statut"));
        trajet.setConducteurId(rs.getLong("conducteur_id"));
        trajet.setVoitureId(rs.getLong("voiture_id"));
        
        // Ajoutez les coordonnées
        trajet.setDepartLat(rs.getDouble("depart_lat"));
        trajet.setDepartLng(rs.getDouble("depart_lng"));
        trajet.setDestinationLat(rs.getDouble("destination_lat"));
        trajet.setDestinationLng(rs.getDouble("destination_lng"));
        
        // Vérifiez si les valeurs sont null
        if (rs.wasNull()) {
            trajet.setDepartLat(null);
            trajet.setDepartLng(null);
            trajet.setDestinationLat(null);
            trajet.setDestinationLng(null);
        }
        
        return trajet;
    }
}