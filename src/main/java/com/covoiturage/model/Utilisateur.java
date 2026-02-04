package com.covoiturage.model;

import java.util.Date;

public class Utilisateur {
    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String motDePasse;
    private String telephone;
    private String role; // CONDUCTEUR, PASSAGER
    private Date dateCreation;
    private Double noteConducteur;
    private Double notePassager;
    
    // Constructeurs
    public Utilisateur() {}
    
    public Utilisateur(String nom, String prenom, String email, String motDePasse, String role) {
        this.nom = nom;
        this.prenom = prenom;
        this.email = email;
        this.motDePasse = motDePasse;
        this.role = role;
        this.dateCreation = new Date();
        this.noteConducteur = 0.0;
        this.notePassager = 0.0;
    }
    
    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    
    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getMotDePasse() { return motDePasse; }
    public void setMotDePasse(String motDePasse) { this.motDePasse = motDePasse; }
    
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public Date getDateCreation() { return dateCreation; }
    public void setDateCreation(Date dateCreation) { this.dateCreation = dateCreation; }
    
    public Double getNoteConducteur() { return noteConducteur; }
    public void setNoteConducteur(Double noteConducteur) { this.noteConducteur = noteConducteur; }
    
    public Double getNotePassager() { return notePassager; }
    public void setNotePassager(Double notePassager) { this.notePassager = notePassager; }
    
    // Méthodes utilitaires
    public boolean estConducteur() {
        return "CONDUCTEUR".equals(role);
    }
    
    public boolean estPassager() {
        return "PASSAGER".equals(role);
    }
    
    public String getNomComplet() {
        return prenom + " " + nom;
    }
    
    public double getNoteMoyenne() {
        if (estConducteur() && estPassager()) {
            return (noteConducteur + notePassager) / 2;
        } else if (estConducteur()) {
            return noteConducteur;
        } else {
            return notePassager;
        }
    }
    
    @Override
    public String toString() {
        return getNomComplet() + " (" + email + ") - " + role;
    }
}