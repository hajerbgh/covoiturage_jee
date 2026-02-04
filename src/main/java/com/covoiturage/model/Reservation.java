package com.covoiturage.model;

import java.util.Date;

public class Reservation {
    private Long id;
    private Long trajetId;
    private Long passagerId;
    private Long conducteurId; // AJOUTER CET ATTRIBUT
    private int nombrePlaces;
    private String statut; // EN_ATTENTE, CONFIRMEE, ANNULEE, TERMINEE
    private Date dateReservation;
    private Double prixTotal;
    
    // Infos du trajet (pour affichage)
    private String depart;
    private String destination;
    private Date dateDepart;
    private Double prixParPlace;
    private String conducteurNom;
    private String conducteurPrenom;
    
    // Infos du passager (pour conducteur)
    private String passagerNom;
    private String passagerPrenom;
    private String passagerEmail;
    private String passagerTelephone;
    private String conducteurEmail;
    private String conducteurTelephone;
    
    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getTrajetId() { return trajetId; }
    public void setTrajetId(Long trajetId) { this.trajetId = trajetId; }
    
    public Long getPassagerId() { return passagerId; }
    public void setPassagerId(Long passagerId) { this.passagerId = passagerId; }
    
    // AJOUTER CES GETTERS/SETTERS
    public Long getConducteurId() { return conducteurId; }
    public void setConducteurId(Long conducteurId) { this.conducteurId = conducteurId; }
    
    public int getNombrePlaces() { return nombrePlaces; }
    public void setNombrePlaces(int nombrePlaces) { this.nombrePlaces = nombrePlaces; }
    
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    
    public Date getDateReservation() { return dateReservation; }
    public void setDateReservation(Date dateReservation) { this.dateReservation = dateReservation; }
    
    public Double getPrixTotal() { return prixTotal; }
    public void setPrixTotal(Double prixTotal) { this.prixTotal = prixTotal; }
    
    public String getDepart() { return depart; }
    public void setDepart(String depart) { this.depart = depart; }
    
    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }
    
    public Date getDateDepart() { return dateDepart; }
    public void setDateDepart(Date dateDepart) { this.dateDepart = dateDepart; }
    
    public Double getPrixParPlace() { return prixParPlace; }
    public void setPrixParPlace(Double prixParPlace) { this.prixParPlace = prixParPlace; }
    
    public String getConducteurNom() { return conducteurNom; }
    public void setConducteurNom(String conducteurNom) { this.conducteurNom = conducteurNom; }
    
    public String getConducteurPrenom() { return conducteurPrenom; }
    public void setConducteurPrenom(String conducteurPrenom) { this.conducteurPrenom = conducteurPrenom; }
    
    public String getPassagerNom() { return passagerNom; }
    public void setPassagerNom(String passagerNom) { this.passagerNom = passagerNom; }
    
    public String getPassagerPrenom() { return passagerPrenom; }
    public void setPassagerPrenom(String passagerPrenom) { this.passagerPrenom = passagerPrenom; }
    
    public String getPassagerEmail() { return passagerEmail; }
    public void setPassagerEmail(String passagerEmail) { this.passagerEmail = passagerEmail; }
    
    public String getConducteurEmail() { return conducteurEmail; }
    public void setConducteurEmail(String conducteurEmail) { this.conducteurEmail = conducteurEmail; }
    
    public String getConducteurTelephone() { return conducteurTelephone; }
    public void setConducteurTelephone(String conducteurTelephone) { this.conducteurTelephone = conducteurTelephone; }
    
    public String getPassagerTelephone() { return passagerTelephone; }
    public void setPassagerTelephone(String passagerTelephone) { this.passagerTelephone = passagerTelephone; }
}