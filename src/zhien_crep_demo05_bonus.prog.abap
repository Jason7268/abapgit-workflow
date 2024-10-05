*&---------------------------------------------------------------------*
*& Report ZHIEN_CREP_DEMO05_BONUS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_CREP_DEMO05_BONUS.
PARAMETERS P_BUKRS TYPE C LENGTH 4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_BUKRS.

  SELECT BUKRS, BUTXT FROM T001
  INTO  TABLE @DATA(GT_T001).

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'BUKRS'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'P_BUKRS'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_T001
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  .
