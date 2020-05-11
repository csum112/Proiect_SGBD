CREATE SEQUENCE QA_ID_SEQUENCE INCREMENT BY 1 START WITH 1;
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
            WHERE ID = ID;
            V_RANDOM := DBMS_RANDOM.VALUE(V_RASPUNSURI.FIRST, V_RASPUNSURI.LAST);
            INSERT INTO TEST_QA(ID, ID_A, SALT) VALUES (V_ID, V_RASPUNSURI(V_RANDOM), i);
            V_RASPUNSURI.DELETE();
        end loop;
end;
/

create PROCEDURE GEN_TEST(EMAIL VARCHAR2) AS
    QID  VARCHAR2(8);
    QAID NUMBER(10);
BEGIN
    FOR i IN 1..10
        LOOP
            QID := GET_RANDOM_QUESTION(EMAIL);
            QAID := QA_ID_SEQUENCE.nextval;
            INSERT INTO TESTE(EMAIL, NR_INTREBARE, ID_Q, ID_QA) VALUES (EMAIL, i, QID, QAID);
            GEN_ANSWERS(QAID, QID);
        end loop;
end;
/
