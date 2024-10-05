*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM06_2F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_flight_data
*&---------------------------------------------------------------------*
*& GET ALL FLIGHT SCHEDULE DATA
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM get_flight_data .

  PERFORM get_spfli.

  PERFORM get_airline_name.

  PERFORM get_country_name USING zshiendialg_t05-countryfr
                           CHANGING zshiendialg_t05-countryfr_nm.

  PERFORM get_country_name USING zshiendialg_t05-countryto
                           CHANGING zshiendialg_t05-countryto_nm.                               .

  gs_before_changes = zshiendialg_t05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SPFLI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_spfli .
  SELECT SINGLE *
     FROM spfLi
      INTO CORRESPONDING FIELDS OF zshiendialg_t05
      WHERE carrid = zshiendialg_t05-carrid
        AND connid =  zshiendialg_t05-connid.


  IF sy-subrc <> 0.
    MESSAGE e003(zhien_demo06).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_AIRLINE_NAME
*&---------------------------------------------------------------------*
*& Get Airline Name
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM get_airline_name .
  SELECT SINGLE carrname
    FROM scarr
    INTO zshiendialg_t05-carrname
    WHERE carrid = zshiendialg_t05-carrid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_country_name
*&---------------------------------------------------------------------*
*& Get country name
*&---------------------------------------------------------------------*
*&      --> U_COUNTRY_CODE
*&      <-- C_COUNTRY_NAME
*&---------------------------------------------------------------------*
FORM get_country_name  USING    u_country_code TYPE t005t-land1
                       CHANGING c_country_name TYPE t005t-landx.
  SELECT SINGLE landx
    FROM  t005t
    INTO c_country_name
    WHERE land1 = u_country_code
      AND spras = sy-langu.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_FLIGHT_SCH
*&---------------------------------------------------------------------*
*& Create flight schedule
*&---------------------------------------------------------------------*

FORM create_flight_sch .
  DATA: ls_spfli TYPE spfli.

  MOVE-CORRESPONDING zshiendialg_t05 TO ls_spfli.

  INSERT spfli FROM ls_spfli.

  IF sy-subrc = 0.
      gd_screen_mode = gc_screenm_display.
      gs_before_changes = zshiendialg_t05.
*    MESSAGE ID 'ZHIEN_DEMO06' TYPE 'S' NUMBER 005 WITH LS_SPFLI-CARRID LS_SPFLI-CONNID.
    MESSAGE s001(zhien_demo06) WITH ls_spfli-carrid ls_spfli-connid.
  ELSE.
    MESSAGE e002(zhien_demo06).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_FLIGHT_SCH
*&---------------------------------------------------------------------*
*& Update flight schedule
*&---------------------------------------------------------------------*

FORM update_flight_sch .
  DATA: ls_spfli TYPE spfli.

  IF gs_before_changes = zshiendialg_t05.
*    The flight Schedule ha not been changed. No need to save
    MESSAGE s004(zhien_demo06).
  ELSE.
    MOVE-CORRESPONDING zshiendialg_t05 TO ls_spfli.

    UPDATE spfli FROM ls_spfli.

    IF sy-subrc = 0.

      gd_screen_mode = gc_screenm_display.
      gs_before_changes = zshiendialg_t05.
*    MESSAGE ID 'ZHIEN_DEMO06' TYPE 'S' NUMBER 005 WITH LS_SPFLI-CARRID LS_SPFLI-CONNID.
      MESSAGE s005(zhien_demo06) WITH ls_spfli-carrid ls_spfli-connid.
    ELSE.
      MESSAGE e006(zhien_demo06).
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_POPUP_CHANGE
*&---------------------------------------------------------------------*
*& show popup change
*&---------------------------------------------------------------------*

FORM show_popup_change .
  DATA: ld_answer TYPE c.
  IF gs_before_changes <> zshiendialg_t05.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
*       TITLEBAR       = ' '
*       DIAGNOSE_OBJECT             = ' '
        text_question  = 'Data has not been saved. Do you really want to leave?'
        text_button_1  = 'Yes'(001)
        text_button_2  = 'No'(002)
        default_button = '1'
      IMPORTING
        answer         = ld_answer
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.
    IF ld_answer = '1'.
      zshiendialg_t05 = gs_before_changes.
      gd_screen_mode = gc_screenm_display.
    ENDIF.
  ELSE.
    gd_screen_mode = gc_screenm_display.
  ENDIF.
ENDFORM.
