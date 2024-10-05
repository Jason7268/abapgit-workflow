*&---------------------------------------------------------------------*
*& Include          SAPMYHIENDIALOG_DM03F01
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
    INTO TABLE @DATA(LT_SCARR)
    WHERE CURRCODE = 'USD'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield               = 'CARRID'
*     PVALKEY                = ' '
     DYNPPROG               = SY-REPID
     DYNPNR                 = SY-DYNNR
     DYNPROFIELD            = 'SCR_CARRID'

     VALUE_ORG              = 'S'
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
*&---------------------------------------------------------------------*
*& Form VB_CARRID_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM vh_carrid_2 .
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname                   = 'SCARR'
      fieldname                 = 'CARRID'
      DYNPPROG               = SY-REPID
      DYNPNR                 = SY-DYNNR
      DYNPROFIELD            = 'SCR_CARRID'

   EXCEPTIONS
     FIELD_NOT_FOUND           = 1
     NO_HELP_FOR_FIELD         = 2
     INCONSISTENT_HELP         = 3
     NO_VALUES_FOUND           = 4
     OTHERS                    = 5
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VH_TIME_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- SCR_DEPTIME
*&---------------------------------------------------------------------*
FORM vh_time_field  CHANGING c_scr_deptime.
  CALL FUNCTION 'F4_CLOCK'
   EXPORTING
     START_TIME          = SY-UZEIT
*     DISPLAY             = ' '
   IMPORTING
     SELECTED_TIME       = c_scr_deptime.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SETUP_LISTBOX
*&---------------------------------------------------------------------*
*& SETUP LIST BOX
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM setup_listbox .

  DATA: LT_VALUES TYPE VRM_VALUES.

  LT_VALUES = VALUE VRM_VALUES( ( KEY = 'KM' TEXT = 'Kilometers' )
                                (  KEY = 'MI' TEXT = 'Miles'  ) ).

CALL FUNCTION 'VRM_SET_VALUES'
  EXPORTING
    id                    = 'SPFLI-DISTID'
    values                = LT_VALUES
 EXCEPTIONS
   ID_ILLEGAL_NAME       = 1
   OTHERS                = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

ENDFORM.
