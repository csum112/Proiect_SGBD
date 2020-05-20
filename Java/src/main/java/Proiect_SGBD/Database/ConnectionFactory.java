package Proiect_SGBD.Database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public enum ConnectionFactory {
    INSTANCE;

    private String connectionString = "jdbc:oracle:thin:STUDENT/STUDENT@debian:1521:XE";
    private Connection connection = null;

    public Connection getConnection() throws SQLException {
        if (connection == null)
            connection = DriverManager.getConnection(connectionString);
        return connection;
    }
}
