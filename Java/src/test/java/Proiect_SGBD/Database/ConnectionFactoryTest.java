package Proiect_SGBD.Database;

import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.*;

class ConnectionFactoryTest {


    @Test
    void connectionIsNotNull() {
        Connection conn = null;
        try {
            conn = ConnectionFactory.INSTANCE.getConnection();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        assertNotNull(conn);
    }
}
