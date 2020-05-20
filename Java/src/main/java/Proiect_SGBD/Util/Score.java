package Proiect_SGBD.Util;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Score implements QuestionOrScore{
    private String body;
    private Double score;


    public Score(String[] strings) {
        this.body = strings[0];
        extractValue();
    }

    private void extractValue() {
        final Pattern pattern = Pattern.compile("^.*?([0-9]+\\.*[0-9]*)(.*)");
        Matcher matcher = pattern.matcher(this.body);
//        this.value = Float.parseFloat(matcher.group());
        matcher.matches();
        this.score = Double.parseDouble(matcher.group(1));
    }

    public Double getScore() {
        return score;
    }

    @Override
    public Integer getQuestionId() {
        return null;
    }

    @Override
    public String getQuestionText() {
        return null;
    }

    @Override
    public List<Answer> getAnswerList() {
        return null;
    }
}
