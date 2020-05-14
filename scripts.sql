create sequence QA_ID_SEQUENCE
    start with 1
/

create TYPE POSSIBLE_ANSWER AS OBJECT
(
    id   NUMBER(1),
    text varchar2(1000)
)
/

create type ANSWER_ARRAY is varray (6) of NUMBER(2)
/

create TYPE REQUEST_INPUT AS OBJECT
(
    id_qa  NUMBER(10),
    id_ans ANSWER_ARRAY
)
/

create type POSSIBLE_ANSWER_ARRAY is varray (6) of POSSIBLE_ANSWER
/

create type QUESTION_RESPONE AS OBJECT
(
    id_qa            number(10),
    possible_answers POSSIBLE_ANSWER_ARRAY,
    text_intrebare   VARCHAR2(1000)
)
/

create table INTREBARI
(
    DOMENIU        VARCHAR2(5),
    ID             VARCHAR2(8)    not null
        primary key,
    TEXT_INTREBARE VARCHAR2(1000) not null
)
/

create table RASPUNSURI
(
    Q_ID         VARCHAR2(8),
    ID           VARCHAR2(8)    not null
        primary key,
    TEXT_RASPUNS VARCHAR2(1000) not null,
    CORECT       VARCHAR2(1)
)
/

create table TEST_QA
(
    ID     NUMBER(10),
    ID_A   VARCHAR2(8)
        constraint FK_IDA
            references RASPUNSURI,
    ANSWER VARCHAR2(1),
    SALT   NUMBER(1)
)
/

create table TESTE
(
    EMAIL        VARCHAR2(64),
    NR_INTREBARE NUMBER(2)   not null,
    ID_Q         VARCHAR2(8) not null,
    ID_QA        NUMBER(10)  not null,
    ANSWERED     VARCHAR2(1)
)
/

create FUNCTION GET_QUESTION_FROM_DOMAIN(V_DOMAIN VARCHAR2) RETURN VARCHAR2 AS
    TYPE VARR IS VARRAY (10) OF VARCHAR2(8);
    V_Q    VARR;
    V_RAND NUMBER(2);
BEGIN
    SELECT ID BULK COLLECT INTO V_Q FROM INTREBARI WHERE DOMENIU = V_DOMAIN;
    V_RAND := DBMS_RANDOM.VALUE(V_Q.FIRST, V_Q.LAST);
    RETURN V_Q(V_RAND);
end;
/

create FUNCTION GET_RANDOM_QUESTION(V_EMAIL varchar2) RETURN varchar2 AS
    TYPE VARR IS VARRAY (10) OF VARCHAR2(8);
    V_DOMENII VARR;
    V_RAND    NUMBER(2);
BEGIN
    SELECT DISTINCT DOMENIU BULK COLLECT
    INTO V_DOMENII
    FROM INTREBARI
    MINUS
    SELECT DISTINCT DOMENIU
    FROM TESTE
             JOIN INTREBARI ON TESTE.ID_Q = INTREBARI.ID
    WHERE EMAIL = V_EMAIL;

    V_RAND := DBMS_RANDOM.VALUE(V_DOMENII.FIRST, V_DOMENII.LAST);
-- TODO: Raise excepion if the user has no free domains left
    return GET_QUESTION_FROM_DOMAIN(V_DOMENII(V_RAND));
end;
/

create PROCEDURE GEN_ANSWERS(V_ID NUMBER, ID_Q VARCHAR2) AS
    TYPE VARR IS VARRAY (100) OF VARCHAR2(8);
    V_RASPUNSURI VARR;
    V_RANDOM     NUMBER(10);
BEGIN
    --     Punem primul raspuns si ne asiguram sa fie corecta
    SELECT ID BULK COLLECT INTO V_RASPUNSURI FROM RASPUNSURI WHERE Q_ID = ID_Q AND CORECT = '1';
    V_RANDOM := DBMS_RANDOM.VALUE(V_RASPUNSURI.FIRST, V_RASPUNSURI.LAST);
    INSERT INTO TEST_QA(ID, ID_A, SALT) VALUES (V_ID, V_RASPUNSURI(V_RANDOM), 1);
    V_RASPUNSURI.DELETE();

    FOR I IN 2..6
        LOOP
            SELECT ID BULK COLLECT
            INTO V_RASPUNSURI
            FROM RASPUNSURI
            WHERE Q_ID = ID_Q
            MINUS
            SELECT ID_A
            FROM TEST_QA
            WHERE ID = ID
              AND TEST_QA.ID = V_ID;
            V_RANDOM := DBMS_RANDOM.VALUE(V_RASPUNSURI.FIRST, V_RASPUNSURI.LAST);
            INSERT INTO TEST_QA(ID, ID_A, SALT) VALUES (V_ID, V_RASPUNSURI(V_RANDOM), i);
            V_RASPUNSURI.DELETE();
        end loop;
end;
/

create FUNCTION GEN_TEST(P_EMAIL VARCHAR2) RETURN NUMBER AS
    QID  VARCHAR2(8);
    QAID NUMBER(10);
    Fst  NUMBER(10);
BEGIN
    FOR i IN 1..10
        LOOP
            QID := GET_RANDOM_QUESTION(P_EMAIL);
            QAID := QA_ID_SEQUENCE.nextval;
            INSERT INTO TESTE(EMAIL, NR_INTREBARE, ID_Q, ID_QA) VALUES (P_EMAIL, i, QID, QAID);
            GEN_ANSWERS(QAID, QID);

            if i = 1 THEN
                Fst := QAID;
            end if;
        end loop;
    return Fst;
end;
/

create FUNCTION GET_SCORE_SINGLE(P_ID NUMBER) RETURN FLOAT AS
    V_CORRECTLY_ANSWERED    NUMBER(2);
    V_WRONG_ANSWER          NUMBER(2);
    V_TOTAL_CORRECT         NUMBER(2);
    V_UNANSWERED            NUMBER(2);
    V_SCORE_PER_GOOD_ANSWER FLOAT;
BEGIN
    SELECT COUNT(*) INTO V_UNANSWERED FROM TEST_QA WHERE ID = P_ID AND ANSWER IS NULL;

    SELECT COUNT(*)
    INTO V_CORRECTLY_ANSWERED
    FROM TEST_QA
             JOIN RASPUNSURI on TEST_QA.ID_A = RASPUNSURI.ID
    WHERE TEST_QA.ID = P_ID
      AND ANSWER = '1'
      AND CORECT = '1';

    SELECT COUNT(*)
    INTO V_TOTAL_CORRECT
    FROM TEST_QA
             JOIN RASPUNSURI on TEST_QA.ID_A = RASPUNSURI.ID
    WHERE TEST_QA.ID = P_ID
      AND CORECT = '1';

    V_WRONG_ANSWER := 6 - V_CORRECTLY_ANSWERED - V_UNANSWERED;
    V_SCORE_PER_GOOD_ANSWER := 10 / V_TOTAL_CORRECT;


    IF V_WRONG_ANSWER < V_CORRECTLY_ANSWERED THEN
        DBMS_OUTPUT.PUT_LINE(P_ID || ' got ' || V_SCORE_PER_GOOD_ANSWER * (V_CORRECTLY_ANSWERED - V_WRONG_ANSWER));
        RETURN V_SCORE_PER_GOOD_ANSWER * (V_CORRECTLY_ANSWERED - V_WRONG_ANSWER);
    ELSE
        RETURN 0;
    END IF;
end;
/

create FUNCTION GET_TEST_SCORE(P_EMAIL VARCHAR2) RETURN FLOAT AS
    V_SCORE FLOAT := 0;
BEGIN
    for row in (SELECT ID_QA FROM TESTE WHERE EMAIL = P_EMAIL)
        LOOP
            V_SCORE := V_SCORE + GET_SCORE_SINGLE(row.ID_QA);
        end loop;
    RETURN V_SCORE;
end;
/

create FUNCTION GET_QUESTION_INDEX(P_EMAIL varchar2) RETURN NUMBER AS
    i NUMBER(10);
BEGIN
    SELECT MIN(ID_QA) INTO I FROM TESTE WHERE EMAIL = P_EMAIL AND ANSWERED IS NULL;
    RETURN i;
EXCEPTION
    WHEN NO_DATA_FOUND then
        return null;
end;
/

create PROCEDURE SET_ANSWER(qa_id NUMBER, ans ANSWER_ARRAY) AS
BEGIN
    UPDATE TESTE SET ANSWERED = '1' WHERE ID_QA = qa_id;
    if ans.COUNT > 0 then
        FOR i IN ans.FIRST..ans.LAST
            LOOP
                UPDATE TEST_QA SET ANSWER = '1' WHERE TEST_QA.id = qa_id AND SALT = ans(i);
            end loop;
    end if;
end;
/

create FUNCTION BUILD_RESPONSE_ANWERS(qa_id number) return QUESTION_RESPONE AS
    question QUESTION_RESPONE;
BEGIN
    question.ID_QA := qa_id;
    return question;
end;
/

create FUNCTION BUILD_ANSWERS(qa_id number) return QUESTION_RESPONE AS
    question QUESTION_RESPONE;
BEGIN
    question.ID_QA := qa_id;
    return question;
end;
/

create FUNCTION BUILD_QUESTION(qa_id number) return QUESTION_RESPONE AS
    text_intrebare varchar2(1000);
    pos_ans        POSSIBLE_ANSWER_ARRAY;
BEGIN

    SELECT TEXT_INTREBARE
    INTO TEXT_INTREBARE
    FROM INTREBARI
             JOIN TESTE ON ID_Q = INTREBARI.ID
    WHERE ID_QA = qa_id;


    SELECT POSSIBLE_ANSWER(SALT, TEXT_RASPUNS) BULK COLLECT
    INTO pos_ans
    FROM TEST_QA
             JOIN RASPUNSURI ON TEST_QA.ID_A = RASPUNSURI.ID
    WHERE TEST_QA.ID = qa_id;
    return QUESTION_RESPONE(qa_id, pos_ans, text_intrebare);
end;
/

create FUNCTION TEXT2REQ(block varchar2) return REQUEST_INPUT AS
    id_qa NUMBER(10);
    ar    ANSWER_ARRAY;
    temp  integer;
BEGIN
    id_qa := to_number(REGEXP_SUBSTR(block, '[0-9]+', 1, 1));
    ar := ANSWER_ARRAY();
    for i in 2..7
        LOOP
            temp := to_number(REGEXP_SUBSTR(block, '[0-9]+', 1, i));
            if temp is not null then
                ar.extend(1);
                ar(i - 1) := temp;
            end if;
        end loop;
    return REQUEST_INPUT(id_qa, ar);
end;
/

create function QUESTION2TEXT(q QUESTION_RESPONE) return VARCHAR2 AS
    buffer varchar2(2000);
BEGIN
    buffer := '' || q.ID_QA || chr(10);
    buffer := buffer || q.TEXT_INTREBARE || chr(10);
    for i in q.POSSIBLE_ANSWERS.FIRST..q.POSSIBLE_ANSWERS.LAST
        LOOP
            buffer := buffer || q.POSSIBLE_ANSWERS(i).ID || '; ' || q.POSSIBLE_ANSWERS(i).text || chr(10);
        end loop;
    return buffer;
end;
/

create FUNCTION urmatoarea_intrebare(P_EMAIL varchar2, body varchar2 default null) RETURN VARCHAR2 AS
    question_count number(2);
    qa_id          number(10);
    req            REQUEST_INPUT;
BEGIN
    if body is null then
        req := null;
    else
        req := TEXT2REQ(body);
    end if;

    SELECT COUNT(*) INTO question_count FROM TESTE WHERE EMAIL = P_EMAIL;
    if question_count = 0 then
        qa_id := GEN_TEST(P_EMAIL);
    else
        qa_id := GET_QUESTION_INDEX(P_EMAIL);
    end if;

    if req is not null AND req.ID_QA = GET_QUESTION_INDEX(P_EMAIL) then
        SET_ANSWER(req.ID_QA, req.ID_ANS);
        qa_id := GET_QUESTION_INDEX(P_EMAIL);
    end if;

    if qa_id is null then
        return 'Felicitari, ai ' || GET_TEST_SCORE(P_EMAIL) || ' puncte!';
    end if;


    return QUESTION2TEXT(BUILD_QUESTION(qa_id));
end;
/
-- Domeniul 1 (geometrie)
INSERT INTO INTREBARI VALUES('D1','Q1','Care din urmatoarele figur geometrice au 4 laturi ?');
INSERT INTO RASPUNSURI VALUES ('Q1','A1','Patrat','1');
INSERT INTO RASPUNSURI VALUES ('Q1','A2','Cerc','0');
INSERT INTO RASPUNSURI VALUES ('Q1','A3','Triunghi','0');
INSERT INTO RASPUNSURI VALUES ('Q1','A4','Romb','1');
INSERT INTO RASPUNSURI VALUES ('Q1','A5','Dreptunghi','1');
INSERT INTO RASPUNSURI VALUES ('Q1','A6','Paralelogram','1');
INSERT INTO RASPUNSURI VALUES ('Q1','A7','Hexagon','0');
INSERT INTO RASPUNSURI VALUES ('Q1','A8','Dodecagon','0');
INSERT INTO RASPUNSURI VALUES ('Q1','A9','Pentagon','0');
INSERT INTO RASPUNSURI VALUES ('Q1','A10','Poligon','0');
INSERT INTO INTREBARI VALUES('D1','Q2','Care din urmatoarele figuri geometrice au mai mult de 4 colturi ?');
INSERT INTO RASPUNSURI VALUES ('Q2','A11','Patrat','0');
INSERT INTO RASPUNSURI VALUES ('Q2','A12','Cerc','1');
INSERT INTO RASPUNSURI VALUES ('Q2','A13','Triunghi','0');
INSERT INTO RASPUNSURI VALUES ('Q2','A14','Romb','0');
INSERT INTO RASPUNSURI VALUES ('Q2','A15','Dreptunghi','0');
INSERT INTO RASPUNSURI VALUES ('Q2','A16','Paralelogram','0');
INSERT INTO RASPUNSURI VALUES ('Q2','A17','Hexagon','1');
INSERT INTO RASPUNSURI VALUES ('Q2','A18','Dodecagon','1');
INSERT INTO RASPUNSURI VALUES ('Q2','A19','Pentagon','1');
INSERT INTO RASPUNSURI VALUES ('Q2','A20','Poligon','0');
INSERT INTO INTREBARI VALUES('D1','Q3','Care din urmatoarele afirmatii sunt adevarate ?');
INSERT INTO RASPUNSURI VALUES ('Q3','A21','Triunghiul are 4 laturi','0');
INSERT INTO RASPUNSURI VALUES ('Q3','A22','Cercul are o infinitate de varfuri','1');
INSERT INTO RASPUNSURI VALUES ('Q3','A23','Suma unghiurilor unui triunghi este de 180 de grade','1');
INSERT INTO RASPUNSURI VALUES ('Q3','A24','Suma unghiurilor unui patrat este de 180 de grade','0');
INSERT INTO RASPUNSURI VALUES ('Q3','A25','Un patrat este un romb cu un unghi drept','1');
INSERT INTO RASPUNSURI VALUES ('Q3','A26','Un poligon este o linie franta inchisa','1');
INSERT INTO RASPUNSURI VALUES ('Q3','A27','Intr-un triunghi dreptunghic suma catetelor este egala cu ipotenuza','0');
INSERT INTO INTREBARI VALUES('D1','Q4','Care din urmatoarele figuri au toate laturile egale ?');
INSERT INTO RASPUNSURI VALUES ('Q4','A28','Triunghiul dreptunghic','0');
INSERT INTO RASPUNSURI VALUES ('Q4','A29','Triunghiul isoscel','0');
INSERT INTO RASPUNSURI VALUES ('Q4','A30','Triunghiul echilateral','1');
INSERT INTO RASPUNSURI VALUES ('Q4','A31','Patratul','1');
INSERT INTO RASPUNSURI VALUES ('Q4','A32','Rombul','1');
INSERT INTO RASPUNSURI VALUES ('Q4','A33','Dreptunghiul','0');
INSERT INTO RASPUNSURI VALUES ('Q4','A34','Hexagonul neregulat','0');
INSERT INTO INTREBARI VALUES('D2','Q5','Care din urmatoarele sunt numere prime ?');
INSERT INTO RASPUNSURI VALUES ('Q5','A35','3','1');
INSERT INTO RASPUNSURI VALUES ('Q5','A36','7','1');
INSERT INTO RASPUNSURI VALUES ('Q5','A37','5','1');
INSERT INTO RASPUNSURI VALUES ('Q5','A38','13','1');
INSERT INTO RASPUNSURI VALUES ('Q5','A39','17','1');
INSERT INTO RASPUNSURI VALUES ('Q5','A40','9','0');
INSERT INTO RASPUNSURI VALUES ('Q5','A41','16','0');
INSERT INTO RASPUNSURI VALUES ('Q5','A42','22','0');
INSERT INTO RASPUNSURI VALUES ('Q5','A43','121','0');
INSERT INTO RASPUNSURI VALUES ('Q5','A44','14','0');
INSERT INTO INTREBARI VALUES('D2','Q6','Care din urmatoarele sunt numere pare ?');
INSERT INTO RASPUNSURI VALUES ('Q6','A45','2','1');
INSERT INTO RASPUNSURI VALUES ('Q6','A46','4','1');
INSERT INTO RASPUNSURI VALUES ('Q6','A47','6','1');
INSERT INTO RASPUNSURI VALUES ('Q6','A48','12','1');
INSERT INTO RASPUNSURI VALUES ('Q6','A49','100','1');
INSERT INTO RASPUNSURI VALUES ('Q6','A50','13','0');
INSERT INTO RASPUNSURI VALUES ('Q6','A51','15','0');
INSERT INTO RASPUNSURI VALUES ('Q6','A52','1','0');
INSERT INTO RASPUNSURI VALUES ('Q6','A53','7','0');
INSERT INTO RASPUNSURI VALUES ('Q6','A54','9','0');
INSERT INTO INTREBARI VALUES('D2','Q7','Care din urmatoarele numere sunt din sirul lui Fibonacci ?');
INSERT INTO RASPUNSURI VALUES ('Q7','A55','1','1');
INSERT INTO RASPUNSURI VALUES ('Q7','A56','2','1');
INSERT INTO RASPUNSURI VALUES ('Q7','A57','3','1');
INSERT INTO RASPUNSURI VALUES ('Q7','A58','5','1');
INSERT INTO RASPUNSURI VALUES ('Q7','A59','8','1');
INSERT INTO RASPUNSURI VALUES ('Q7','A60','13','1');
INSERT INTO RASPUNSURI VALUES ('Q7','A61','21','1');
INSERT INTO RASPUNSURI VALUES ('Q7','A62','22','0');
INSERT INTO RASPUNSURI VALUES ('Q7','A63','23','0');
INSERT INTO INTREBARI VALUES('D3','Q8','Care flori sunt sau pot fi albe ?');
INSERT INTO RASPUNSURI VALUES ('Q8','A64','Ghiocelul','1');
INSERT INTO RASPUNSURI VALUES ('Q8','A65','Margareta','1');
INSERT INTO RASPUNSURI VALUES ('Q8','A66','Trandafirul','1');
INSERT INTO RASPUNSURI VALUES ('Q8','A67','Floarea de soc','1');
INSERT INTO RASPUNSURI VALUES ('Q8','A68','Papadia','0');
INSERT INTO RASPUNSURI VALUES ('Q8','A69','Floarea de cires','1');
INSERT INTO RASPUNSURI VALUES ('Q8','A70','Crinul','1');
INSERT INTO RASPUNSURI VALUES ('Q8','A71','Bumbisorul','1');
INSERT INTO RASPUNSURI VALUES ('Q8','A72','Floarea soarelui','0');
INSERT INTO INTREBARI VALUES('D3','Q9','Care din urmatorele nume de fete sunt si nume de flori ?');
INSERT INTO RASPUNSURI VALUES ('Q9','A73','Crina','1');
INSERT INTO RASPUNSURI VALUES ('Q9','A74','Margareta','1');
INSERT INTO RASPUNSURI VALUES ('Q9','A75','Lacramioara','1');
INSERT INTO RASPUNSURI VALUES ('Q9','A76','Madalina','0');
INSERT INTO RASPUNSURI VALUES ('Q9','A77','Maria','0');
INSERT INTO RASPUNSURI VALUES ('Q9','A78','Larisa','0');
INSERT INTO RASPUNSURI VALUES ('Q9','A79','Georgiana','0');
INSERT INTO RASPUNSURI VALUES ('Q9','A80','Brandusa','1');
INSERT INTO RASPUNSURI VALUES ('Q9','A81','Ana','0');
INSERT INTO INTREBARI VALUES('D4','Q10','Cate litere are alfabetul roman?');
INSERT INTO RASPUNSURI VALUES ('Q10','A82',26,'0');
INSERT INTO RASPUNSURI VALUES ('Q10','A83',31,'1');
INSERT INTO RASPUNSURI VALUES ('Q10','A84','Ce e asta?','0');
INSERT INTO RASPUNSURI VALUES ('Q10','A85','26.5','0');
INSERT INTO RASPUNSURI VALUES ('Q10','A86','-12','0');
INSERT INTO RASPUNSURI VALUES ('Q10','A87','Pe toate.','0');
INSERT INTO INTREBARI VALUES('D5','Q11','Pe ce planeta traiesti?');
INSERT INTO RASPUNSURI VALUES ('Q11','A88','Pe pamant.','1');
INSERT INTO RASPUNSURI VALUES ('Q11','A89','Traiesc in nori.','0');
INSERT INTO RASPUNSURI VALUES ('Q11','A90','Pe juiter.','0');
INSERT INTO RASPUNSURI VALUES ('Q11','A91','Depinde.','0');
INSERT INTO RASPUNSURI VALUES ('Q11','A92','Pe luna.','0');
INSERT INTO RASPUNSURI VALUES ('Q11','A93','Pe toate.','0');
INSERT INTO INTREBARI VALUES('D6','Q12','Care animal este mamifer ?');
INSERT INTO RASPUNSURI VALUES ('Q12','A94','Ariciul','1');
INSERT INTO RASPUNSURI VALUES ('Q12','A95','Capra neagra','1');
INSERT INTO RASPUNSURI VALUES ('Q12','A96','Lupul','1');
INSERT INTO RASPUNSURI VALUES ('Q12','A97','Ursul','1');
INSERT INTO RASPUNSURI VALUES ('Q12','A98','Gaina','0');
INSERT INTO RASPUNSURI VALUES ('Q12','A99','Barza','0');
INSERT INTO RASPUNSURI VALUES ('Q12','A100','Sarpele','0');
INSERT INTO RASPUNSURI VALUES ('Q12','A101','Delfinul','1');
INSERT INTO RASPUNSURI VALUES ('Q12','A102','Broasca testoasa','0');
INSERT INTO INTREBARI VALUES('D7','Q13','Cati pitici avea Cenusareasa ?');
INSERT INTO RASPUNSURI VALUES ('Q13','A103','0','1');
INSERT INTO RASPUNSURI VALUES ('Q13','A104','Niciunul','1');
INSERT INTO RASPUNSURI VALUES ('Q13','A105','1','0');
INSERT INTO RASPUNSURI VALUES ('Q13','A106','3','0');
INSERT INTO RASPUNSURI VALUES ('Q13','A107','7','0');
INSERT INTO RASPUNSURI VALUES ('Q13','A108','8','0');
INSERT INTO RASPUNSURI VALUES ('Q13','A109','Pe toti','0');
INSERT INTO RASPUNSURI VALUES ('Q13','A110','Unul si bun','0');
INSERT INTO RASPUNSURI VALUES ('Q13','A111','Nu stiu','0');
INSERT INTO INTREBARI VALUES('D8','Q14','Cine a fost Alexandru Ioan Cuza ?');
INSERT INTO RASPUNSURI VALUES ('Q14','A112','a fost primul domnitor al Principatelor Unite si al statului national Romania','1');
INSERT INTO RASPUNSURI VALUES ('Q14','A113','un om inrobit de doua patimi Iubirea pentru patrie si cea pentru femei frumoase','1');
INSERT INTO RASPUNSURI VALUES ('Q14','A114','un om pasionat de cai','1');
INSERT INTO RASPUNSURI VALUES ('Q14','A115','un pictor roman','0');
INSERT INTO RASPUNSURI VALUES ('Q14','A116','primul scriitor de opera literara','0');
INSERT INTO RASPUNSURI VALUES ('Q14','A117','a fost ultimul domnitor al Principatelor Unite si al statului national Romania','0');
INSERT INTO RASPUNSURI VALUES ('Q14','A118','un domnitor roman nascut in anul 1820','1');
INSERT INTO RASPUNSURI VALUES ('Q14','A119','un domnitor roman nascut in anul 1859','0');
INSERT INTO RASPUNSURI VALUES ('Q14','A120','Domnitor in 1859-1866','1');
INSERT INTO INTREBARI VALUES('D9','Q15','Care este/sunt scriitori romani ?');
INSERT INTO RASPUNSURI VALUES ('Q15','A121','Mihai Eminescu','1');
INSERT INTO RASPUNSURI VALUES ('Q15','A122','Ion Luca Caragiale','1');
INSERT INTO RASPUNSURI VALUES ('Q15','A123','Mircea Cartarescu','1');
INSERT INTO RASPUNSURI VALUES ('Q15','A124','Mircea Eliade','1');
INSERT INTO RASPUNSURI VALUES ('Q15','A125','Ion Creanga','1');
INSERT INTO RASPUNSURI VALUES ('Q15','A126','Liviu Rebreanu','1');
INSERT INTO RASPUNSURI VALUES ('Q15','A127','Nicolae Grigorescu','0');
INSERT INTO RASPUNSURI VALUES ('Q15','A128','Nicolae Tonitza','0');
INSERT INTO RASPUNSURI VALUES ('Q15','A129','Stefan Luchian','0');
INSERT INTO RASPUNSURI VALUES ('Q15','A130','Ion Andreescu','0');
INSERT INTO INTREBARI VALUES('D10','Q16','Care dintre urmatoarele filme il au drept regizor pe Quentin Tarantino ?');
INSERT INTO RASPUNSURI VALUES ('Q16','A131','From Dusk till Dawn','1');
INSERT INTO RASPUNSURI VALUES ('Q16','A132','Pulp Fiction','1');
INSERT INTO RASPUNSURI VALUES ('Q16','A133','Django','1');
INSERT INTO RASPUNSURI VALUES ('Q16','A134','Eyes wide shut','0');
INSERT INTO RASPUNSURI VALUES ('Q16','A135','Terminator','0');
INSERT INTO RASPUNSURI VALUES ('Q16','A136','Godfather','0');
INSERT INTO RASPUNSURI VALUES ('Q16','A137','Kill Bill','1');
INSERT INTO RASPUNSURI VALUES ('Q16','A138','Ender’s Game','0');
INSERT INTO RASPUNSURI VALUES ('Q16','A139','Coboram la prima','0');
INSERT INTO RASPUNSURI VALUES ('Q16','A140','The Notebook','0');
COMMIT;