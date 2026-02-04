package com.covoiturage.model;

import java.util.Date;

public class Avis {
    private Long id;
    private int note; // 1 à 5
    private String commentaire;
    private Date dateAvis;
    private Long evaluateurId;
    private Long evalueId;
    private Long trajetId;
    private String evaluateurNom;
    private String evaluateurPrenom;
    private String evalueNom;
    private String evaluePrenom;
    private String trajetDepart;
    private String trajetDestination;
    private Date trajetDateDepart;
    // Constructeurs
    public Avis() {}
    
    public Avis(int note, String commentaire, Long evaluateurId, Long evalueId, Long trajetId) {
        setNote(note);
        this.commentaire = commentaire;
        this.dateAvis = new Date();
        this.evaluateurId = evaluateurId;
        this.evalueId = evalueId;
        this.trajetId = trajetId;
    }
    
    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public int getNote() { return note; }
    public void setNote(int note) { 
        if (note >= 1 && note <= 5) {
            this.note = note;
        } else {
            throw new IllegalArgumentException("La note doit être entre 1 et 5");
        }
    }
    
    public String getCommentaire() { return commentaire; }
    public void setCommentaire(String commentaire) { this.commentaire = commentaire; }
    
    public Date getDateAvis() { return dateAvis; }
    public void setDateAvis(Date dateAvis) { this.dateAvis = dateAvis; }
    
    public Long getEvaluateurId() { return evaluateurId; }
    public void setEvaluateurId(Long evaluateurId) { this.evaluateurId = evaluateurId; }
    
    public Long getEvalueId() { return evalueId; }
    public void setEvalueId(Long evalueId) { this.evalueId = evalueId; }
    
    public Long getTrajetId() { return trajetId; }
    public void setTrajetId(Long trajetId) { this.trajetId = trajetId; }
    
    // Méthodes utilitaires
    public String getNoteEtoiles() {
        StringBuilder etoiles = new StringBuilder();
        for (int i = 0; i < note; i++) {
            etoiles.append("★");
        }
        for (int i = note; i < 5; i++) {
            etoiles.append("☆");
        }
        return etoiles.toString();
    }
    
    public String getNoteColor() {
        if (note >= 4) return "success";
        if (note >= 3) return "warning";
        return "danger";
    }
    
    public boolean estNotePositive() {
        return note >= 4;
    }
    
    public String getCommentaireTronque(int maxLength) {
        if (commentaire.length() <= maxLength) {
            return commentaire;
        }
        return commentaire.substring(0, maxLength) + "...";
    }
    public String getEvaluateurNom() { return evaluateurNom; }
    public void setEvaluateurNom(String evaluateurNom) { this.evaluateurNom = evaluateurNom; }
    
    public String getEvaluateurPrenom() { return evaluateurPrenom; }
    public void setEvaluateurPrenom(String evaluateurPrenom) { this.evaluateurPrenom = evaluateurPrenom; }
    
    public String getEvalueNom() { return evalueNom; }
    public void setEvalueNom(String evalueNom) { this.evalueNom = evalueNom; }
    
    public String getEvaluePrenom() { return evaluePrenom; }
    public void setEvaluePrenom(String evaluePrenom) { this.evaluePrenom = evaluePrenom; }
    
    public String getTrajetDepart() { return trajetDepart; }
    public void setTrajetDepart(String trajetDepart) { this.trajetDepart = trajetDepart; }
    
    public String getTrajetDestination() { return trajetDestination; }
    public void setTrajetDestination(String trajetDestination) { this.trajetDestination = trajetDestination; }
    
    public Date getTrajetDateDepart() { return trajetDateDepart; }
    public void setTrajetDateDepart(Date trajetDateDepart) { this.trajetDateDepart = trajetDateDepart; }
    
    @Override
    public String toString() {
        return "Avis de " + evaluateurId + " pour " + evalueId + 
               " - Note: " + getNoteEtoiles() + 
               " - " + getCommentaireTronque(50);
    }
}