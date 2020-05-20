package Proiect_SGBD.Repository;

import Proiect_SGBD.Database.ConnectionFactory;

import java.sql.*;

public class EmailRepository {

    public void save(String email, String hash) throws SQLException {
        final Connection conn = ConnectionFactory.INSTANCE.getConnection();
        PreparedStatement stmt = conn.prepareStatement("INSERT INTO EMAIL_HASH_COMBO(EMAIL, HASH) VALUES(?,?)");
        stmt.setString(1, email);
        stmt.setString(2, hash);
        stmt.executeUpdate();
        stmt.close();
    }

    public boolean comboExists(String email, String hash) throws SQLException {
        final Connection conn = ConnectionFactory.INSTANCE.getConnection();
        PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM EMAIL_HASH_COMBO WHERE EMAIL = ? AND HASH = ?");
        stmt.setString(1, email);
        stmt.setString(2, hash);
        final ResultSet resultSet = stmt.executeQuery();
        resultSet.next();
        int count = resultSet.getInt(1);
        stmt.close();
        resultSet.close();
        return count > 0;
    }

    public boolean emailExists(String email) throws SQLException {
        final Connection conn = ConnectionFactory.INSTANCE.getConnection();
        PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM EMAIL_HASH_COMBO WHERE EMAIL = ?");
        stmt.setString(1, email);
        final ResultSet resultSet = stmt.executeQuery();
        resultSet.next();
        int count = resultSet.getInt(1);
        stmt.close();
        resultSet.close();
        return count > 0;
    }


}
