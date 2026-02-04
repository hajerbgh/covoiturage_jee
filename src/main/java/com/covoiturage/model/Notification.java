package com.covoiturage.model;

import java.util.Date;

public class Notification {
    private Long id;
    private Long utilisateurId;
    private String type; // AVIS, RESERVATION, MESSAGE, SYSTEME
    private String titre;
    private String message;
    private String url;
    private boolean lue;
    private Date dateNotification;
    
    // Constructeurs
    public Notification() {}
    
    public Notification(Long utilisateurId, String type, String titre, String message, String url) {
        this.utilisateurId = utilisateurId;
        this.type = type;
        this.titre = titre;
        this.message = message;
        this.url = url;
        this.lue = false;
        this.dateNotification = new Date();
    }
    
    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getUtilisateurId() { return utilisateurId; }
    public void setUtilisateurId(Long utilisateurId) { this.utilisateurId = utilisateurId; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    
    public boolean isLue() { return lue; }
    public void setLue(boolean lue) { this.lue = lue; }
    
    public Date getDateNotification() { return dateNotification; }
    public void setDateNotification(Date dateNotification) { this.dateNotification = dateNotification; }
    
    // Méthode utilitaire
    public String getTypeIcon() {
        switch(type) {
            case "AVIS": return "fas fa-star";
            case "RESERVATION": return "fas fa-calendar-check";
            case "MESSAGE": return "fas fa-envelope";
            case "SYSTEME": return "fas fa-info-circle";
            default: return "fas fa-bell";
        }
    }
    
    public String getTypeColor() {
        switch(type) {
            case "AVIS": return "#f6ad55"; // orange
            case "RESERVATION": return "#4299e1"; // bleu
            case "MESSAGE": return "#68d391"; // vert
            case "SYSTEME": return "#a0aec0"; // gris
            default: return "#4a6cf7"; // violet
        }
    }
}