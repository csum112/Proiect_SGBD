package Proiect_SGBD.Repository;

import org.junit.jupiter.api.Test;

import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.*;

class EmailRepositoryTest {

    @Test
    void tryToInsertIntoEHCombo(){
        assertDoesNotThrow(() -> {
            final EmailRepository emailRepository = new EmailRepository();
            emailRepository.save("1", "1");
        });
    }
}
