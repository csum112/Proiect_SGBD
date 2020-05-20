package Proiect_SGBD.Util;

public class DatabaseResponse {
    private String[] tokens;

    public DatabaseResponse(String body) {
        this.tokens = body.split("\n");
    }

    private boolean isScore() {
        return this.tokens.length == 1;
    }

    private Score getScore() {
        return new Score(tokens);
    }

    private Question getQuestion() {
        return new Question(tokens);
    }

    public QuestionOrScore getQOS() {
        if(isScore()) return getScore();
        else return getQuestion();
    }
}
