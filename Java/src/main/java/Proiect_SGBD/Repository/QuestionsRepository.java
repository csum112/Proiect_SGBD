package Proiect_SGBD.Repository;

import Proiect_SGBD.Database.ConnectionFactory;

import java.sql.*;

public class QuestionsRepository {
    private String email;
    private String body;

    public QuestionsRepository(String email, String body) throws SQLException {
        this.email = email;
        this.body = body;
    }

    public String getNextQuestion() throws SQLException {
        final Connection conn = ConnectionFactory.INSTANCE.getConnection();
        final String sql =
                "DECLARE " +
                        "result VARCHAR2(2000);" +
                        "BEGIN" +
                        "? := urmatoarea_intrebare(?, ?);" +
                        "END;";
        final CallableStatement stmt = conn.prepareCall(sql);
        stmt.registerOutParameter(1, Types.VARCHAR);
        stmt.setString(2, email);
        stmt.setString(3, body);
        stmt.execute();
        String result =  stmt.getString(1);
        stmt.close();
        return result;
    }
}
