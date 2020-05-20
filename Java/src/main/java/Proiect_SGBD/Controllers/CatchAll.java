package Proiect_SGBD.Controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CatchAll {
    @CrossOrigin(origins = "*")
    @GetMapping(value = {"/auth", "/test"})
    public String catchAllRoute() {
        return "index.html";
    }
}
