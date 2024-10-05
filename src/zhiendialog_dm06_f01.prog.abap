*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM06_F01
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
  DATA: LD_CARRID TYPE SPFLI-CARRID.

  SELECT SINGLE CARRID FROM SPFLI INTO LD_CARRID
    WHERE CARRID = ZSHIENDIALG_T05-CARRID.

    IF SY-SUBRC <> 0.
      MESSAGE |This Airline { ZSHIENDIALG_T05-CARRID } does not exist SPFLI.|
       TYPE 'E'.
    ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AIRNUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_airnum .
    DATA: LD_CARRID TYPE SPFLI-CARRID.

  SELECT SINGLE CARRID FROM SPFLI INTO LD_CARRID
    WHERE CONNID = ZSHIENDIALG_T05-CONNID.

    IF SY-SUBRC <> 0.
      MESSAGE |This Airline number { ZSHIENDIALG_T05-CONNID } does not exist SPFLI.|
       TYPE 'E'.
    ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  VH_CONNID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM vh_connid .
*    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
*    EXPORTING
*      tabname                   = 'SPFLI'
*      fieldname                 = 'CONNID'
*      DYNPPROG               = SY-REPID
*      DYNPNR                 = SY-DYNNR
*      DYNPROFIELD            = 'ZSHIENDIALG_T05-CONNID'
*
*   EXCEPTIONS
*     FIELD_NOT_FOUND           = 1
*     NO_HELP_FOR_FIELD         = 2
*     INCONSISTENT_HELP         = 3
*     NO_VALUES_FOUND           = 4
*     OTHERS                    = 5
*            .
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.

  SELECT CARRID, CONNID FROM SPFLI
    INTO TABLE @DATA(LT_SPFLI).

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield               = 'CONNID'
*     PVALKEY                = ' '
     DYNPPROG               = SY-REPID
     DYNPNR                 = SY-DYNNR
     DYNPROFIELD            = 'ZSHIENDIALG_T05-CONNID'

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
      value_tab              = LT_SPFLI

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
*& Form setgreen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SCR_OKCODE
*&---------------------------------------------------------------------*
FORM setgreen USING U_KEY TYPE INT1.
  LOOP AT SCREEN.
    IF SCREEN-group1 = '001'.
      SCREEN-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form vh_city_field
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- ZSHIENDIALG_T05_CITYFROM
*&---------------------------------------------------------------------*
FORM vh_city_field  .
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname                   = 'SPFLI'
      fieldname                 = 'CITYFROM'
      DYNPPROG               = SY-REPID
      DYNPNR                 = SY-DYNNR
      DYNPROFIELD            = 'ZSHIENDIALG_T05-CITYFROM'

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
*& Form vh_cityto_field
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM vh_cityto_field .
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname                   = 'SPFLI'
      fieldname                 = 'CITYTO'
      DYNPPROG               = SY-REPID
      DYNPNR                 = SY-DYNNR
      DYNPROFIELD            = 'ZSHIENDIALG_T05-CITYTO'

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
*& Form SETUP_LISTBOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM setup_listbox .
    DATA: LT_VALUES TYPE VRM_VALUES.

    LT_VALUES = VALUE VRM_VALUES( ( KEY = 'KM' TEXT = 'Kilometers' )
                                  ( KEY = 'MI' TEXT = 'Miles'  ) ).

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id                    = 'ZSHIENDIALG_T05-DISTID'
      values                = LT_VALUES
   EXCEPTIONS
     ID_ILLEGAL_NAME       = 1
     OTHERS                = 2
            .
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_SPFLI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_spfli .
       SELECT SINGLE * FROM SPFLI
          WHERE  CARRID = @ZSHIENDIALG_T05-CARRID AND connid = @ZSHIENDIALG_T05-CONNID
          INTO @DATA(read_line).
       UPDATE SPFLI FROM @( VALUE #( BASE read_line COUNTRYFR = ZSHIENDIALG_T05-COUNTRYFR
                                                    CITYFROM = ZSHIENDIALG_T05-CITYFROM
                                                    AIRPFROM = ZSHIENDIALG_T05-AIRPFROM
                                                    COUNTRYTO = ZSHIENDIALG_T05-COUNTRYTO
                                                    CITYTO = ZSHIENDIALG_T05-CITYTO
                                                    AIRPTO = ZSHIENDIALG_T05-AIRPTO
                                                    FLTIME = ZSHIENDIALG_T05-FLTIME
                                                    DEPTIME = ZSHIENDIALG_T05-DEPTIME
                                                    ARRTIME = ZSHIENDIALG_T05-ARRTIME
                                                    DISTANCE = ZSHIENDIALG_T05-DISTANCE
                                                    DISTID = ZSHIENDIALG_T05-DISTID
                                                    FLTYPE = ZSHIENDIALG_T05-FLTYPE   ) ).
        IF SY-SUBRC = 0.
            MESSAGE |Update success Airline { ZSHIENDIALG_T05-CARRID }.|
            TYPE 'I'.
        ELSE.
            MESSAGE |Update Fail Airline { ZSHIENDIALG_T05-CARRID }.|
            TYPE 'I'.
        ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form Insert_spfli
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM Insert_spfli .
  INSERT SPFLI FROM TABLE @( VALUE #( ( CARRID = ZSHIENDIALG_T05-CARRID )
                                      ( CONNID = ZSHIENDIALG_T05-CONNID )
                                      ( COUNTRYFR = ZSHIENDIALG_T05-COUNTRYFR )
                                      ( CITYFROM = ZSHIENDIALG_T05-CITYFROM )
                                      ( AIRPFROM = ZSHIENDIALG_T05-AIRPFROM )
                                      ( COUNTRYTO = ZSHIENDIALG_T05-COUNTRYTO )
                                      ( CITYTO = ZSHIENDIALG_T05-CITYTO )
                                      ( AIRPTO = ZSHIENDIALG_T05-AIRPTO )
                                      ( FLTIME = ZSHIENDIALG_T05-FLTIME )
                                      ( DEPTIME = ZSHIENDIALG_T05-DEPTIME )
                                      ( ARRTIME = ZSHIENDIALG_T05-ARRTIME )
                                      ( DISTANCE = ZSHIENDIALG_T05-DISTANCE )
                                      ( DISTID = ZSHIENDIALG_T05-DISTID )
                                      ( FLTYPE = ZSHIENDIALG_T05-FLTYPE )   ) ).
    IF SY-SUBRC = 0.
            MESSAGE |Insert success Airline { ZSHIENDIALG_T05-CARRID }.|
            TYPE 'I'.
        ELSE.
            MESSAGE |Insert Fail Airline { ZSHIENDIALG_T05-CARRID }.|
            TYPE 'I'.
        ENDIF.

ENDFORM.
