package com.covoiturage.dao;

import java.sql.*;
import java.util.*;
import com.covoiturage.model.Reservation;
import com.covoiturage.util.DatabaseConnection;

public class ReservationDAO {
    
    // Créer une réservation
    public boolean create(Reservation reservation) {
        String sql = "INSERT INTO reservation (trajet_id, passager_id, statut, date_reservation) " +
                     "VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setLong(1, reservation.getTrajetId());
            pstmt.setLong(2, reservation.getPassagerId());
            pstmt.setString(3, reservation.getStatut() != null ? reservation.getStatut() : "EN_ATTENTE");
            java.util.Date now = new java.util.Date();
            pstmt.setTimestamp(4, new Timestamp(now.getTime()));
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        reservation.setId(generatedKeys.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur création réservation: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Récupérer les réservations d'un passager
    public List<Reservation> findByPassagerId(Long passagerId) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, t.depart, t.destination, t.date_depart, t.prix, " +
                "u.nom as conducteur_nom, u.prenom as conducteur_prenom, " +
                "u.email as conducteur_email, u.telephone as conducteur_telephone " +
                "FROM reservation r " +
                "JOIN trajet t ON r.trajet_id = t.id " +
                "JOIN utilisateur u ON t.conducteur_id = u.id " +
                "WHERE r.passager_id = ? " +
                "ORDER BY r.date_reservation DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, passagerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche réservations passager: " + e.getMessage());
        }
        return reservations;
    }
    
    // NOUVELLE MÉTHODE : Récupérer le nombre de places déjà réservées par un passager sur un trajet
    public int getNombrePlacesReservees(Long trajetId, Long passagerId) {
        String sql = "SELECT COUNT(*) as nb_places FROM reservation " +
                     "WHERE trajet_id = ? AND passager_id = ? AND statut IN ('EN_ATTENTE', 'CONFIRMEE')";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, trajetId);
            pstmt.setLong(2, passagerId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("nb_places");
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur getNombrePlacesReservees: " + e.getMessage());
        }
        return 0;
    }
    
    
    
    public int countTotalPassagersByConducteur(Long conducteurId) {
        String sql = "SELECT COUNT(*) as total_passagers " +
                     "FROM reservation r " +
                     "JOIN trajet t ON r.trajet_id = t.id " +
                     "WHERE t.conducteur_id = ? AND r.statut IN ('CONFIRMEE', 'EN_ATTENTE', 'TERMINEE') " +
                     "AND t.statut IN ('ACTIF', 'TERMINE')";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, conducteurId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_passagers");
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur countTotalPassagersByConducteur: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    
    
    
    // Récupérer les réservations d'un conducteur (tous ses trajets)
    public List<Reservation> findByConducteurId(Long conducteurId) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, t.depart, t.destination, t.date_depart, t.prix, " +
                     "u.nom as conducteur_nom, u.prenom as conducteur_prenom, " +
                     "up.nom as passager_nom, up.prenom as passager_prenom, " +
                     "up.email as passager_email, up.telephone as passager_telephone " +
                     "FROM reservation r " +
                     "JOIN trajet t ON r.trajet_id = t.id " +
                     "JOIN utilisateur u ON t.conducteur_id = u.id " +
                     "JOIN utilisateur up ON r.passager_id = up.id " +
                     "WHERE t.conducteur_id = ? " +
                     "ORDER BY r.date_reservation DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, conducteurId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche réservations conducteur: " + e.getMessage());
        }
        return reservations;
    }
    
    public int countByPassagerId(Long passagerId) {
        String sql = "SELECT COUNT(*) FROM reservation WHERE passager_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, passagerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Erreur countByPassagerId: " + e.getMessage());
        }
        return 0;
    }

    public int countByConducteurId(Long conducteurId) {
        String sql = "SELECT COUNT(DISTINCT r.id) FROM reservation r " +
                     "JOIN trajet t ON r.trajet_id = t.id " +
                     "WHERE t.conducteur_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, conducteurId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Erreur countByConducteurId: " + e.getMessage());
        }
        return 0;
    }
    
    // Récupérer les réservations d'un trajet spécifique
    public List<Reservation> findByTrajetId(Long trajetId) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, t.depart, t.destination, t.date_depart, t.prix, " +
                     "u.nom as conducteur_nom, u.prenom as conducteur_prenom, " +
                     "up.nom as passager_nom, up.prenom as passager_prenom, " +
                     "up.email as passager_email, up.telephone as passager_telephone " +
                     "FROM reservation r " +
                     "JOIN trajet t ON r.trajet_id = t.id " +
                     "JOIN utilisateur u ON t.conducteur_id = u.id " +
                     "JOIN utilisateur up ON r.passager_id = up.id " +
                     "WHERE r.trajet_id = ? " +
                     "ORDER BY r.date_reservation DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, trajetId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche réservations trajet: " + e.getMessage());
        }
        return reservations;
    }
    
    // Récupérer une réservation par ID
    public Reservation findById(Long id) {
        String sql = "SELECT r.*, t.depart, t.destination, t.date_depart, t.prix, " +
                 "u.nom as conducteur_nom, u.prenom as conducteur_prenom, " +
                 "u.email as conducteur_email, u.telephone as conducteur_telephone, " +
                 "up.nom as passager_nom, up.prenom as passager_prenom, " +
                 "up.email as passager_email, up.telephone as passager_telephone " +
                 "FROM reservation r " +
                 "JOIN trajet t ON r.trajet_id = t.id " +
                 "JOIN utilisateur u ON t.conducteur_id = u.id " +
                 "JOIN utilisateur up ON r.passager_id = up.id " +
                 "WHERE r.id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToReservation(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche réservation: " + e.getMessage());
        }
        return null;
    }
    
    // Annuler une réservation
    public boolean annulerReservation(Long reservationId) {
        String sql = "UPDATE reservation SET statut = 'ANNULEE' WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, reservationId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur annulation réservation: " + e.getMessage());
        }
        return false;
    }
    
    // Vérifier si un passager a déjà réservé ce trajet
    public boolean existeReservation(Long trajetId, Long passagerId) {
        return getNombrePlacesReservees(trajetId, passagerId) > 0;
    }
    
    // Mettre à jour le statut d'une réservation
    public boolean updateStatut(Long reservationId, String statut) {
        String sql = "UPDATE reservation SET statut = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, statut);
            pstmt.setLong(2, reservationId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Erreur mise à jour statut réservation: " + e.getMessage());
        }
        return false;
    }
    
    // Compter le nombre de places réservées sur un trajet
    public int countPlacesReservees(Long trajetId) {
        String sql = "SELECT COUNT(*) as places_reservees FROM reservation WHERE trajet_id = ? AND statut IN ('EN_ATTENTE', 'CONFIRMEE')";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, trajetId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("places_reservees");
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur comptage places réservées: " + e.getMessage());
        }
        return 0;
    }
    
    // Mapper ResultSet → Reservation
    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        
        reservation.setId(rs.getLong("id"));
        reservation.setTrajetId(rs.getLong("trajet_id"));
        reservation.setPassagerId(rs.getLong("passager_id"));
        reservation.setStatut(rs.getString("statut"));
        reservation.setDateReservation(rs.getTimestamp("date_reservation"));
        
        // Infos trajet
        reservation.setDepart(rs.getString("depart"));
        reservation.setDestination(rs.getString("destination"));
        reservation.setDateDepart(rs.getTimestamp("date_depart"));
        reservation.setPrixParPlace(rs.getDouble("prix"));
        
        // Calculer prix total (1 place par réservation dans votre structure)
        reservation.setPrixTotal(rs.getDouble("prix"));
        
        // Infos conducteur
        reservation.setConducteurNom(rs.getString("conducteur_nom"));
        reservation.setConducteurPrenom(rs.getString("conducteur_prenom"));
        
        try {
            reservation.setConducteurEmail(rs.getString("conducteur_email"));
            reservation.setConducteurTelephone(rs.getString("conducteur_telephone"));
        } catch (SQLException e) {
            System.out.println("Info: Champs conducteur_email/conducteur_telephone non trouvés");
        }
        
        // Infos passager (si présentes)
        try {
            reservation.setPassagerNom(rs.getString("passager_nom"));
            reservation.setPassagerPrenom(rs.getString("passager_prenom"));
            reservation.setPassagerEmail(rs.getString("passager_email"));
            reservation.setPassagerTelephone(rs.getString("passager_telephone"));
        } catch (SQLException e) {
            // Ces colonnes peuvent ne pas être présentes
        }
        
        return reservation;
    }
}