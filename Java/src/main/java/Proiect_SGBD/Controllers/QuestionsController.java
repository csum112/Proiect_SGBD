package Proiect_SGBD.Controllers;

import Proiect_SGBD.Repository.EmailRepository;
import Proiect_SGBD.Repository.QuestionsRepository;
import Proiect_SGBD.Util.DatabaseResponse;
import Proiect_SGBD.Util.NextAnswerRequest;
import Proiect_SGBD.Util.QuestionOrScore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;

@RestController
@RequestMapping("/api/questions")
@CrossOrigin(origins="*")
public class QuestionsController {

    private Logger logger = LoggerFactory.getLogger(QuestionsController.class);

    @PostMapping(value = "", consumes = "application/json", produces = "application/json")
    public ResponseEntity<QuestionOrScore> getNextQuestion(@RequestBody NextAnswerRequest body) throws SQLException {
        if (body.getEmail() == null || body.getHash() == null)
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        if (!doesEmailAndHashExist(body.getEmail(), body.getHash()))
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);

        final String dbReq = formAnswer(body);
        final QuestionsRepository questionsRepository = new QuestionsRepository(body.getEmail(), dbReq);
        final String nextQResponse = questionsRepository.getNextQuestion();
        final QuestionOrScore qos = (new DatabaseResponse(nextQResponse)).getQOS();
        return ResponseEntity.ok(qos);
    }

    private boolean doesEmailAndHashExist(String email, String hash) throws SQLException {
        final EmailRepository emailRepository = new EmailRepository();
        return emailRepository.comboExists(email, hash);
    }

    private String formAnswer(NextAnswerRequest req) {
        if (req.getQuestionId() == null) return null;
        String body = "" + req.getQuestionId();
        if (req.getAnswers() != null)
            for (Integer answer : req.getAnswers()) {
                body = body + " ," + answer;
            }
        return body;
    }
}
