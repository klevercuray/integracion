CREATE OR REPLACE FUNCTION INTEGRACION.f_query_expt (
    p_detail_code    TBBDETC.TBBDETC_DETAIL_CODE%TYPE,
    p_pimd           TBRACCD.TBRACCD_PIDM%TYPE,
    p_term_code      TBRACCD.TBRACCD_TERM_CODE%TYPE)
    RETURN VARCHAR2
IS
    CURSOR tbbdetc_c
    IS
        SELECT DISTINCT TBBESTU_PIDM  --, TBBESTU_TERM_CODE, TBRECAT_DCAT_CODE
          FROM V_BAN_BECAS_ALUMNO, V_BAN_CATALOGO_BECAS
         WHERE     TBBESTU_EXEMPTION_CODE = TBBEXPT_EXEMPTION_CODE
               AND TBBESTU_TERM_CODE = TBBEXPT_TERM_CODE
               AND TBBESTU_TERM_CODE = p_term_code
               AND TBBESTU_PIDM = p_pimd
               AND (TBRECAT_DCAT_CODE = (SELECT TBBDETC_DCAT_CODE
                                           FROM TBBDETC
                                          WHERE TBBDETC_DETAIL_CODE = p_detail_code)
                OR TBRECAT_DCAT_CODE = p_detail_code);

    --        SELECT SGBSTDN_TERM_CODE_EFF
    --          FROM SGBSTDN
    --         WHERE     sgbstdn_pidm = p_pidm
    --               AND sgbstdn_term_code_eff <= p_term_code_eff
    --      ORDER BY SGBSTDN_TERM_CODE_EFF DESC;


    p_detail_TYPE   TBBESTU.TBBESTU_PIDM%TYPE;
    p_return        VARCHAR2 (1) := 'Y';
BEGIN
    OPEN tbbdetc_c;

    FETCH tbbdetc_c INTO p_detail_TYPE;

    IF tbbdetc_c%NOTFOUND
    THEN
        --p_detail_TYPE := 'N';
        p_return := 'N';
    END IF;

    CLOSE tbbdetc_c;

    --RETURN p_detail_TYPE;
    RETURN p_return;
END f_query_expt;
/
