/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    public Connection getConnection() throws Exception {
        // Driver kết nối Microsoft SQL Server
        String driverClass = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        String url = "jdbc:sqlserver://localhost:1433;databaseName=QuanLyChungCu;encrypt=false;trustServerCertificate=true;";
        String user = "sa"; 
        String password = "123";

        Class.forName(driverClass);
        return DriverManager.getConnection(url, user, password);
    }
}
