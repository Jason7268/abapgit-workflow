*&---------------------------------------------------------------------*
*& Report ZHIEN_MOD_PART05_REP1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_MOD_PART05_REP1.

FORM WRITE_DATA USING U_INPUT_1 TYPE STRING
                      U_INPUT_2 TYPE STRING
                CHANGING C_OUTPUT_1 TYPE CHAR40.
  WRITE: 'DATA: ', U_INPUT_1, U_INPUT_2.

  C_OUTPUT_1 ='TEST OUTPUT'.

   ENDFORM.
