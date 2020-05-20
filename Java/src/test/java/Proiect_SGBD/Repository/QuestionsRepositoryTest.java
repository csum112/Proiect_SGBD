package Proiect_SGBD.Repository;

import org.junit.jupiter.api.Test;

import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.*;

class QuestionsRepositoryTest {

    @Test
    void getNextQuestionWorks() throws SQLException {
        final String email = "Andrei";
        final String body = "22";
        final QuestionsRepository qs = new QuestionsRepository(email, body);
        final String response = qs.getNextQuestion();
        System.out.println(response);
        assertNotNull(response);
    }

}
