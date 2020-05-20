package Proiect_SGBD.Util;

import java.util.List;

public interface QuestionOrScore {
    Double getScore();
    Integer getQuestionId();
    String getQuestionText();
    List<Answer> getAnswerList();
}
