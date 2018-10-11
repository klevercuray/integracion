CREATE OR REPLACE FUNCTION INTEGRACION.f_query_program_bx(p_pidm         IN SORLCUR.SORLCUR_PIDM%TYPE,
                                                          p_sorlcur_key  IN SORLCUR.SORLCUR_KEY_SEQNO%TYPE,
                                                          p_term_code    IN SORLCUR.SORLCUR_TERM_CODE%TYPE,
                                                          p_dato         IN VARCHAR2) RETURN VARCHAR2 IS
--AUTOR: KLEVER CURAY
--CREACION: 23/08/2018
--OBJETIVO: Obtener codigo del programa en base al StudyPath o Periodo. Este codigo sera utilizado por BX
--  CURSOR PARA OBTENER EL PROGRAMA DE ACUERDO AL STUDYPATH
    CURSOR SORLCUR_C IS
        SELECT DISTINCT SMRPRLE_PROGRAM, SMRPRLE_PROGRAM_DESC, SMRPRLE_LEVL_CODE
          FROM sorlcur, SMRPRLE
         WHERE sorlcur_pidm = p_pidm
           AND SORLCUR_KEY_SEQNO = p_sorlcur_key
           AND SORLCUR_LMOD_CODE = 'LEARNER'
           AND SMRPRLE_PROGRAM = SORLCUR_PROGRAM;


    CURSOR SORLCUR_S(P_PROGRAMA VARCHAR2) IS
        SELECT DISTINCT SMRPRLE_PROGRAM, SMRPRLE_PROGRAM_DESC, SMRPRLE_LEVL_CODE
          FROM SMRPRLE
         WHERE SMRPRLE_PROGRAM = P_PROGRAMA;
    
    lv_programa  SMRPRLE.SMRPRLE_PROGRAM%TYPE;
    pr_program   SORLCUR_C%ROWTYPE;
    pv_valor     SMRPRLE.SMRPRLE_PROGRAM_DESC%TYPE:=NULL;

BEGIN
  If p_sorlcur_key is not null Then
    OPEN sorlcur_c;
    FETCH sorlcur_c INTO pr_program;
    IF sorlcur_c%NOTFOUND THEN
     pv_valor := 'XYZ';      
    END IF;
    CLOSE sorlcur_c;
  Else
   -- OBTENER PROGRAMA DE ACUERDO AL PERIODO
   lv_programa := INTEGRACION.INT_F_OBT_PROG_PRIM_PERIODO(p_pidm, p_term_code);
   OPEN SORLCUR_S(lv_programa);
   FETCH SORLCUR_S INTO pr_program;
   IF SORLCUR_S%NOTFOUND THEN
     pv_valor := 'XYZ';
   END If;
   CLOSE SORLCUR_S;
  End if;
  
  IF pv_valor is NULL THEN
    IF p_dato = 'PROGRAM' THEN
      pv_valor := pr_program.smrprle_program;
    ELSIF p_dato = 'DESC_PROGRAM' THEN
      pv_valor := pr_program.smrprle_program_desc;
    ELSIF p_dato = 'LEVL' THEN
      pv_valor := pr_program.smrprle_levl_code;
    ELSE
      pv_valor := NULL;
    END IF;
  ELSE
    pv_valor := NULL;
  END IF;
  
  RETURN pv_valor;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/
