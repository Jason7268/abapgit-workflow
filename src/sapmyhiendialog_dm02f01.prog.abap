*&---------------------------------------------------------------------*
*& Include          SAPMYHIENDIALOG_DM02F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHECK_AIRLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_airline .
  DATA: LD_CARRNAME TYPE SCARR-CARRNAME.

  SELECT SINGLE CARRNAME FROM SCARR
    INTO LD_CARRNAME
    WHERE CARRID = SCR_CARRID.

    IF SY-SUBRC = 0.
      SCR_CARRNAME = LD_CARRNAME.
    ELSE.
      MESSAGE |This Airline { SCR_CARRID } does not exist SCARR.|
       TYPE 'E'.
    ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_TIME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_time .
  IF SCR_DEPTIME >= SCR_ARRTIME AND SCR_PERIOD = 0.
      SET CURSOR FIELD 'SCR_DEPTIME'.
      MESSAGE |Invalid flight time. Arrival time must be greater than Departure time.|
       TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VH_CARRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM vh_carrid .

  SELECT CARRID, CARRNAME FROM SCARR
    INTO TABLE @DATA(LT_SCARR).

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield               = 'CARRID'
*     PVALKEY                = ' '
     DYNPPROG               = SY-REPID
     DYNPNR                 = SY-DYNNR
     DYNPROFIELD            = 'SCR_CARRID'

     VALUE_ORG              = 'C'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY                = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB               =
*   IMPORTING
*     USER_RESET             =
    tables
      value_tab              = LT_SCARR

   EXCEPTIONS
     PARAMETER_ERROR        = 1
     NO_VALUES_FOUND        = 2
     OTHERS                 = 3
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
