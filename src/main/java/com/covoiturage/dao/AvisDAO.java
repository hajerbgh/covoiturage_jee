package com.covoiturage.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.covoiturage.model.Avis;
import com.covoiturage.model.Utilisateur;
import com.covoiturage.util.DatabaseConnection;

public class AvisDAO {
    
    // Vérifier si un utilisateur a déjà évalué un trajet
    public boolean aDejaEvalue(Long trajetId, Long evaluateurId) {
        String sql = "SELECT COUNT(*) FROM avis WHERE trajet_id = ? AND evaluateur_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, trajetId);
            pstmt.setLong(2, evaluateurId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur vérification évaluation: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
 // Dans AvisDAO.java, ajoutez cette méthode
    public boolean aDejaEvaluePassager(Long trajetId, Long passagerId) {
        String sql = "SELECT COUNT(*) FROM avis WHERE trajet_id = ? AND evalue_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, trajetId);
            pstmt.setLong(2, passagerId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur vérification évaluation passager: " + e.getMessage());
        }
        return false;
    }
    public double getNoteMoyenneConducteur(Long conducteurId) {
        String sql = "SELECT AVG(note) FROM avis WHERE evalue_id = ? AND note IS NOT NULL";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, conducteurId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Erreur getNoteMoyenneConducteur: " + e.getMessage());
        }
        return 0.0;
    }

    public double getNoteMoyennePassager(Long passagerId) {
        String sql = "SELECT AVG(note) FROM avis WHERE evalue_id = ? AND note IS NOT NULL";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, passagerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Erreur getNoteMoyennePassager: " + e.getMessage());
        }
        return 0.0;
    }

   
    // Créer un avis

 // Dans AvisDAO, modifiez la méthode create() pour ajouter :
    public boolean create(Avis avis) {
        String sql = "INSERT INTO avis (note, commentaire, date_avis, evaluateur_id, evalue_id, trajet_id) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, avis.getNote());
            pstmt.setString(2, avis.getCommentaire());
            pstmt.setTimestamp(3, new Timestamp(avis.getDateAvis().getTime()));
            pstmt.setLong(4, avis.getEvaluateurId());
            pstmt.setLong(5, avis.getEvalueId());
            pstmt.setLong(6, avis.getTrajetId());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        avis.setId(generatedKeys.getLong(1));
                    }
                }
                
                // 🔥 AJOUTEZ CETTE PARTIE : Créer une notification
                NotificationDAO notificationDAO = new NotificationDAO();
                // Récupérer le nom de l'évaluateur
                UtilisateurDAO utilisateurDAO = new UtilisateurDAO();
                Utilisateur evaluateur = utilisateurDAO.findById(avis.getEvaluateurId());
                
                if (evaluateur != null) {
                    notificationDAO.notifierNouvelAvis(
                        avis.getEvalueId(),
                        evaluateur.getPrenom() + " " + evaluateur.getNom(),
                        avis.getNote(),
                        avis.getTrajetId()
                    );
                }
                
                return true;
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur création avis: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Récupérer les avis donnés à un utilisateur
    public List<Avis> findByEvalueId(Long evalueId) {
        List<Avis> avisList = new ArrayList<>();
        String sql = "SELECT a.*, " +
                    "u_evaluateur.nom as evaluateur_nom, u_evaluateur.prenom as evaluateur_prenom, " +
                    "u_evalue.nom as evalue_nom, u_evalue.prenom as evalue_prenom, " +
                    "t.depart, t.destination, t.date_depart " +
                    "FROM avis a " +
                    "JOIN utilisateur u_evaluateur ON a.evaluateur_id = u_evaluateur.id " +
                    "JOIN utilisateur u_evalue ON a.evalue_id = u_evalue.id " +
                    "JOIN trajet t ON a.trajet_id = t.id " +
                    "WHERE a.evalue_id = ? " +
                    "ORDER BY a.date_avis DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, evalueId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    avisList.add(mapResultSetToAvis(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur récupération avis: " + e.getMessage());
            e.printStackTrace();
        }
        return avisList;
    }
    
    // Récupérer les avis donnés par un utilisateur
    public List<Avis> findByEvaluateurId(Long evaluateurId) {
        List<Avis> avisList = new ArrayList<>();
        String sql = "SELECT a.*, " +
                    "u_evaluateur.nom as evaluateur_nom, u_evaluateur.prenom as evaluateur_prenom, " +
                    "u_evalue.nom as evalue_nom, u_evalue.prenom as evalue_prenom, " +
                    "t.depart, t.destination " +
                    "FROM avis a " +
                    "JOIN utilisateur u_evaluateur ON a.evaluateur_id = u_evaluateur.id " +
                    "JOIN utilisateur u_evalue ON a.evalue_id = u_evalue.id " +
                    "JOIN trajet t ON a.trajet_id = t.id " +
                    "WHERE a.evaluateur_id = ? " +
                    "ORDER BY a.date_avis DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, evaluateurId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    avisList.add(mapResultSetToAvis(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur récupération avis: " + e.getMessage());
            e.printStackTrace();
        }
        return avisList;
    }
    
    // Récupérer les avis d'un trajet spécifique
    public List<Avis> findByTrajetId(Long trajetId) {
        List<Avis> avisList = new ArrayList<>();
        String sql = "SELECT a.*, " +
                    "u_evaluateur.nom as evaluateur_nom, u_evaluateur.prenom as evaluateur_prenom, " +
                    "u_evalue.nom as evalue_nom, u_evalue.prenom as evalue_prenom, " +
                    "t.depart, t.destination " +
                    "FROM avis a " +
                    "JOIN utilisateur u_evaluateur ON a.evaluateur_id = u_evaluateur.id " +
                    "JOIN utilisateur u_evalue ON a.evalue_id = u_evalue.id " +
                    "JOIN trajet t ON a.trajet_id = t.id " +
                    "WHERE a.trajet_id = ? " +
                    "ORDER BY a.date_avis DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, trajetId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    avisList.add(mapResultSetToAvis(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur récupération avis trajet: " + e.getMessage());
            e.printStackTrace();
        }
        return avisList;
    }
    
    // Calculer la note moyenne d'un utilisateur
    public double getNoteMoyenne(Long evalueId) {
        String sql = "SELECT AVG(note) FROM avis WHERE evalue_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, evalueId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur calcul note moyenne: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Compter le nombre d'avis pour un utilisateur
    public int countByEvalueId(Long evalueId) {
        String sql = "SELECT COUNT(*) FROM avis WHERE evalue_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, evalueId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur comptage avis: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    // Récupérer un avis par son ID
    public Avis findById(Long id) {
        String sql = "SELECT a.*, " +
                    "u_evaluateur.nom as evaluateur_nom, u_evaluateur.prenom as evaluateur_prenom, " +
                    "u_evalue.nom as evalue_nom, u_evalue.prenom as evalue_prenom, " +
                    "t.depart, t.destination " +
                    "FROM avis a " +
                    "JOIN utilisateur u_evaluateur ON a.evaluateur_id = u_evaluateur.id " +
                    "JOIN utilisateur u_evalue ON a.evalue_id = u_evalue.id " +
                    "JOIN trajet t ON a.trajet_id = t.id " +
                    "WHERE a.id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setLong(1, id);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAvis(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Erreur recherche avis: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    // Mapper ResultSet vers Avis
    private Avis mapResultSetToAvis(ResultSet rs) throws SQLException {
        Avis avis = new Avis();
        
        avis.setId(rs.getLong("id"));
        avis.setNote(rs.getInt("note"));
        avis.setCommentaire(rs.getString("commentaire"));
        avis.setDateAvis(rs.getTimestamp("date_avis"));
        avis.setEvaluateurId(rs.getLong("evaluateur_id"));
        avis.setEvalueId(rs.getLong("evalue_id"));
        avis.setTrajetId(rs.getLong("trajet_id"));
        
        // Ajouter les informations supplémentaires
        avis.setEvaluateurNom(rs.getString("evaluateur_nom"));
        avis.setEvaluateurPrenom(rs.getString("evaluateur_prenom"));
        avis.setEvalueNom(rs.getString("evalue_nom"));
        avis.setEvaluePrenom(rs.getString("evalue_prenom"));
        avis.setTrajetDepart(rs.getString("depart"));
        avis.setTrajetDestination(rs.getString("destination"));
        avis.setTrajetDateDepart(rs.getTimestamp("date_depart"));
        
        return avis;
    }
    public List<Avis> getAvisByUtilisateurId(int userId) {
        // Simplement appeler la méthode existante
        return findByEvalueId((long) userId);
    }
    
}