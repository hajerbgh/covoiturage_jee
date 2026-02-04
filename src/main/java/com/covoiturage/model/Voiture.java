package com.covoiturage.model;

public class Voiture {
    private Long id;
    private String marque;
    private String modele;
    private String matricule;
    private int nombrePlaces;
    private Long conducteurId;
    
    // Constructeurs
    public Voiture() {}
    
    public Voiture(String marque, String modele, String matricule, int nombrePlaces, Long conducteurId) {
        this.marque = marque;
        this.modele = modele;
        this.matricule = matricule;
        this.nombrePlaces = nombrePlaces;
        this.conducteurId = conducteurId;
    }
    
    // Getters et Setters (à générer avec Eclipse)
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getMarque() { return marque; }
    public void setMarque(String marque) { this.marque = marque; }
    
    public String getModele() { return modele; }
    public void setModele(String modele) { this.modele = modele; }
    
    public String getMatricule() { return matricule; }
    public void setMatricule(String matricule) { this.matricule = matricule; }
    
    public int getNombrePlaces() { return nombrePlaces; }
    public void setNombrePlaces(int nombrePlaces) { this.nombrePlaces = nombrePlaces; }
    
    public Long getConducteurId() { return conducteurId; }
    public void setConducteurId(Long conducteurId) { this.conducteurId = conducteurId; }
    
    @Override
    public String toString() {
        return marque + " " + modele + " (" + matricule + ")";
    }
}