package Proiect_SGBD.Util;

import java.util.List;

public class NextAnswerRequest {
    private String email;
    private String hash;
    private Integer questionId;
    private List<Integer> answers;

    public String getEmail() {
        return email;
    }

    public String getHash() {
        return hash;
    }

    public Integer getQuestionId() {
        return questionId;
    }

    public List<Integer> getAnswers() {
        return answers;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setHash(String hash) {
        this.hash = hash;
    }

    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }

    public void setAnswers(List<Integer> answers) {
        this.answers = answers;
    }
}
