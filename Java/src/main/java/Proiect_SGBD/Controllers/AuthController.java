package Proiect_SGBD.Controllers;

import Proiect_SGBD.Repository.EmailRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;


@Controller
@RequestMapping("/api/auth")
@CrossOrigin(origins="*")
public class AuthController {
    @PostMapping(value = "", produces = "application/json", consumes = "application/json")
    public ResponseEntity<String> addEmail(@RequestBody String email) throws SQLException {
        final EmailRepository emailRepository = new EmailRepository();
        if (emailRepository.emailExists(email))
            return new ResponseEntity<String>(HttpStatus.CONFLICT);
        final String hash = Integer.toString((email + System.nanoTime()).hashCode());
        emailRepository.save(email, hash);
        return ResponseEntity.ok(hash);
    }
}
