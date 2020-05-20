package Proiect_SGBD.Util;

import java.util.LinkedList;
import java.util.List;

public class Question implements QuestionOrScore{
    private Integer questionId;
    private String questionText;
    private List<Answer> answerList;
    private String[] tokens;

    public Question(String[] tokens) {
        this.questionId = Integer.parseInt(tokens[0]);
        this.questionText = tokens[1];
        this.answerList = new LinkedList<>();
        extractPossibleAnswers(tokens);
    }

    private void extractPossibleAnswers(String[] tokens) {
        for (int i = 2; i < 8; i++) {
            String[] strings = tokens[i].split(";");
            this.answerList.add(new Answer(Integer.parseInt(strings[0]), strings[1]));
        }
    }

    public Integer getQuestionId() {
        return questionId;
    }

    public String getQuestionText() {
        return questionText;
    }

    public List<Answer> getAnswerList() {
        return answerList;
    }

    @Override
    public Double getScore() {
        return null;
    }
}
