package com.covoiturage.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.covoiturage.util.DatabaseConnection;


public class TestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    public void init() throws ServletException {
        System.out.println("🔧 TestServlet initialisée");
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html lang='fr'>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("<title>Test Application Covoiturage</title>");
        out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'>");
        out.println("<style>");
        out.println("* { margin: 0; padding: 0; box-sizing: border-box; }");
        out.println("body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); min-height: 100vh; padding: 20px; }");
        out.println(".container { max-width: 1200px; margin: 0 auto; }");
        out.println("header { background: #2c3e50; color: white; padding: 30px; border-radius: 10px 10px 0 0; text-align: center; }");
        out.println("header h1 { font-size: 2.5rem; margin-bottom: 10px; }");
        out.println("header p { font-size: 1.2rem; opacity: 0.9; }");
        out.println(".main-content { background: white; padding: 40px; border-radius: 0 0 10px 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }");
        out.println(".test-card { background: #f8f9fa; border-radius: 10px; padding: 25px; margin-bottom: 30px; border-left: 5px solid #3498db; transition: transform 0.3s; }");
        out.println(".test-card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }");
        out.println(".test-card.success { border-left-color: #27ae60; }");
        out.println(".test-card.error { border-left-color: #e74c3c; }");
        out.println(".test-card.warning { border-left-color: #f39c12; }");
        out.println(".test-card h3 { color: #2c3e50; margin-bottom: 15px; display: flex; align-items: center; gap: 10px; }");
        out.println(".status { display: inline-block; padding: 5px 15px; border-radius: 20px; font-weight: bold; margin-top: 10px; }");
        out.println(".status-success { background: #d4edda; color: #155724; }");
        out.println(".status-error { background: #f8d7da; color: #721c24; }");
        out.println(".status-warning { background: #fff3cd; color: #856404; }");
        out.println("table { width: 100%; border-collapse: collapse; margin-top: 15px; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 0 10px rgba(0,0,0,0.05); }");
        out.println("th, td { padding: 15px; text-align: left; border-bottom: 1px solid #e0e0e0; }");
        out.println("th { background: #3498db; color: white; font-weight: 600; }");
        out.println("tr:hover { background: #f5f9ff; }");
        out.println(".btn-group { display: flex; gap: 15px; margin-top: 40px; justify-content: center; flex-wrap: wrap; }");
        out.println(".btn { display: inline-flex; align-items: center; gap: 10px; padding: 15px 30px; background: #3498db; color: white; text-decoration: none; border-radius: 50px; font-weight: 600; transition: all 0.3s; border: none; cursor: pointer; }");
        out.println(".btn:hover { background: #2980b9; transform: translateY(-3px); box-shadow: 0 5px 15px rgba(52, 152, 219, 0.3); }");
        out.println(".btn-secondary { background: #95a5a6; }");
        out.println(".btn-secondary:hover { background: #7f8c8d; }");
        out.println(".server-info { background: #f1f8ff; padding: 20px; border-radius: 10px; margin-top: 30px; }");
        out.println(".server-info h4 { color: #2c3e50; margin-bottom: 15px; }");
        out.println(".info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; }");
        out.println(".info-item { background: white; padding: 15px; border-radius: 8px; border: 1px solid #e0e0e0; }");
        out.println(".info-label { font-weight: bold; color: #3498db; margin-bottom: 5px; }");
        out.println("@media (max-width: 768px) { .container { padding: 10px; } .main-content { padding: 20px; } .btn-group { flex-direction: column; align-items: center; } .btn { width: 100%; justify-content: center; } }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<header>");
        out.println("<h1><i class='fas fa-car'></i> Test Application Covoiturage</h1>");
        out.println("<p>Vérification de l'environnement et des connexions</p>");
        out.println("</header>");
        out.println("<div class='main-content'>");
        
        // ================== TEST 1: CONNEXION MYSQL ==================
        out.println("<div class='test-card'>");
        out.println("<h3><i class='fas fa-database'></i> Test 1 : Connexion Base de Données MySQL</h3>");
        
        try {
            Connection conn = DatabaseConnection.getConnection();
            
            if (conn != null && !conn.isClosed()) {
                out.println("<div class='status status-success'><i class='fas fa-check-circle'></i> CONNEXION RÉUSSIE</div>");
                out.println("<p><strong>URL :</strong> jdbc:mysql://localhost:3306/covoiturage_app</p>");
                out.println("<p><strong>Base de données :</strong> covoiturage_app</p>");
                out.println("<p><strong>État :</strong> Connecté</p>");
                
                // Tester si les tables existent
                DatabaseMetaData meta = conn.getMetaData();
                ResultSet tables = meta.getTables("covoiturage_app", null, "%", new String[]{"TABLE"});
                int tableCount = 0;
                while (tables.next()) tableCount++;
                tables.close();
                
                out.println("<p><strong>Tables :</strong> " + tableCount + " table(s) trouvée(s)</p>");
                
            } else {
                out.println("<div class='status status-error'><i class='fas fa-times-circle'></i> CONNEXION ÉCHOUÉE</div>");
                out.println("<p>La connexion à MySQL a échoué. Vérifiez :</p>");
                out.println("<ul>");
                out.println("<li>Que le service MySQL est démarré</li>");
                out.println("<li>Que la base 'covoiturage_app' existe</li>");
                out.println("<li>Que l'utilisateur 'root' a les permissions</li>");
                out.println("</ul>");
            }
        } catch (Exception e) {
            out.println("<div class='status status-error'><i class='fas fa-exclamation-triangle'></i> ERREUR : " + e.getMessage() + "</div>");
        }
        out.println("</div>");
        
        // ================== TEST 2: STRUCTURE BASE ==================
        out.println("<div class='test-card'>");
        out.println("<h3><i class='fas fa-table'></i> Test 2 : Structure de la Base de Données</h3>");
        
        try {
            Connection conn = DatabaseConnection.getConnection();
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet tables = meta.getTables("covoiturage_app", null, "%", new String[]{"TABLE"});
            
            int tableCount = 0;
            out.println("<table>");
            out.println("<thead>");
            out.println("<tr><th>Table</th><th>Colonnes</th><th>Type</th></tr>");
            out.println("</thead>");
            out.println("<tbody>");
            
            while (tables.next()) {
                tableCount++;
                String tableName = tables.getString("TABLE_NAME");
                
                out.println("<tr>");
                out.println("<td><strong>" + tableName + "</strong></td>");
                out.println("<td>");
                
                // Récupérer les colonnes
                ResultSet columns = meta.getColumns("covoiturage_app", null, tableName, null);
                while (columns.next()) {
                    String colName = columns.getString("COLUMN_NAME");
                    String colType = columns.getString("TYPE_NAME");
                    out.println(colName + " (" + colType + ")<br>");
                }
                columns.close();
                
                out.println("</td>");
                out.println("<td>TABLE</td>");
                out.println("</tr>");
            }
            
            out.println("</tbody>");
            out.println("</table>");
            
            if (tableCount > 0) {
                out.println("<div class='status status-success'><i class='fas fa-check-circle'></i> " + tableCount + " TABLE(S) TROUVÉE(S)</div>");
            } else {
                out.println("<div class='status status-warning'><i class='fas fa-exclamation-triangle'></i> AUCUNE TABLE DANS LA BASE</div>");
                out.println("<p>Exécutez ces commandes SQL :</p>");
                out.println("<pre style='background: #f4f4f4; padding: 15px; border-radius: 5px; overflow-x: auto;'>");
                out.println("USE covoiturage_app;");
                out.println("SHOW TABLES;");
                out.println("</pre>");
            }
            
            tables.close();
            
        } catch (SQLException e) {
            out.println("<div class='status status-error'><i class='fas fa-times-circle'></i> ERREUR SQL : " + e.getMessage() + "</div>");
        } catch (Exception e) {
            out.println("<div class='status status-error'><i class='fas fa-exclamation-triangle'></i> ERREUR : " + e.getMessage() + "</div>");
        }
        out.println("</div>");
        
        // ================== TEST 3: ENVIRONNEMENT ==================
        out.println("<div class='test-card'>");
        out.println("<h3><i class='fas fa-server'></i> Test 3 : Environnement Serveur</h3>");
        
        out.println("<div class='server-info'>");
        out.println("<div class='info-grid'>");
        
        out.println("<div class='info-item'>");
        out.println("<div class='info-label'>Serveur</div>");
        out.println("<div>" + getServletContext().getServerInfo() + "</div>");
        out.println("</div>");
        
        out.println("<div class='info-item'>");
        out.println("<div class='info-label'>Java Version</div>");
        out.println("<div>" + System.getProperty("java.version") + "</div>");
        out.println("</div>");
        
        out.println("<div class='info-item'>");
        out.println("<div class='info-label'>Contexte</div>");
        out.println("<div>" + request.getContextPath() + "</div>");
        out.println("</div>");
        
        out.println("<div class='info-item'>");
        out.println("<div class='info-label'>Encodage</div>");
        out.println("<div>UTF-8</div>");
        out.println("</div>");
        
        out.println("<div class='info-item'>");
        out.println("<div class='info-label'>Système</div>");
        out.println("<div>" + System.getProperty("os.name") + " " + System.getProperty("os.version") + "</div>");
        out.println("</div>");
        
        out.println("<div class='info-item'>");
        out.println("<div class='info-label'>Architecture</div>");
        out.println("<div>" + System.getProperty("os.arch") + "</div>");
        out.println("</div>");
        
        out.println("</div>"); // .info-grid
        out.println("</div>"); // .server-info
        out.println("</div>"); // .test-card
        
        // ================== BOUTONS ==================
        out.println("<div class='btn-group'>");
        out.println("<a href='" + request.getContextPath() + "/' class='btn'>");
        out.println("<i class='fas fa-home'></i> Retour à l'accueil");
        out.println("</a>");
        out.println("<a href='test' class='btn'>");
        out.println("<i class='fas fa-sync-alt'></i> Rafraîchir les tests");
        out.println("</a>");
        out.println("<a href='accueil' class='btn btn-secondary'>");
        out.println("<i class='fas fa-car'></i> Page d'accueil");
        out.println("</a>");
        out.println("</div>");
        
        out.println("</div>"); // .main-content
        out.println("</div>"); // .container
        out.println("</body>");
        out.println("</html>");
        
        out.close();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}