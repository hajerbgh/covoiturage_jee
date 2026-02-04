package com.covoiturage.model;

import java.util.Date;

public class Trajet {
    private Long id;
    private String depart;
    private String destination;
    private Date dateDepart;
    private double prix;
    private int placesDisponibles;
    private String description;
    private String restrictions;
    private String statut; // ACTIF, COMPLET, ANNULE, TERMINE
    private Long conducteurId;
    private Long voitureId;
    private Double departLat;
    private Double departLng;
    private Double destinationLat;
    private Double destinationLng;
    
    // Constructeurs
    public Trajet() {}
    
    public Trajet(String depart, String destination, Date dateDepart, double prix, 
                 int placesDisponibles, Long conducteurId, Long voitureId) {
        this.depart = depart;
        this.destination = destination;
        this.dateDepart = dateDepart;
        this.prix = prix;
        this.placesDisponibles = placesDisponibles;
        this.statut = "ACTIF";
        this.conducteurId = conducteurId;
        this.voitureId = voitureId;
    }
    
    // Getters et Setters (à générer)
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getDepart() { return depart; }
    public void setDepart(String depart) { this.depart = depart; }
    
    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }
    
    public Date getDateDepart() { return dateDepart; }
    public void setDateDepart(Date dateDepart) { this.dateDepart = dateDepart; }
    
    public double getPrix() { return prix; }
    public void setPrix(double prix) { this.prix = prix; }
    
    public int getPlacesDisponibles() { return placesDisponibles; }
    public void setPlacesDisponibles(int placesDisponibles) { this.placesDisponibles = placesDisponibles; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getRestrictions() { return restrictions; }
    public void setRestrictions(String restrictions) { this.restrictions = restrictions; }
    
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    
    public Long getConducteurId() { return conducteurId; }
    public void setConducteurId(Long conducteurId) { this.conducteurId = conducteurId; }
    
    public Long getVoitureId() { return voitureId; }
    public void setVoitureId(Long voitureId) { this.voitureId = voitureId; }
    
    // Méthode utilitaire
    public boolean estDisponible() {
        return "ACTIF".equals(statut) && placesDisponibles > 0;
    }
    public Double getDepartLat() { return departLat; }
    public void setDepartLat(Double departLat) { this.departLat = departLat; }
    
    public Double getDepartLng() { return departLng; }
    public void setDepartLng(Double departLng) { this.departLng = departLng; }
    
    public Double getDestinationLat() { return destinationLat; }
    public void setDestinationLat(Double destinationLat) { this.destinationLat = destinationLat; }
    
    public Double getDestinationLng() { return destinationLng; }
    public void setDestinationLng(Double destinationLng) { this.destinationLng = destinationLng; }

}