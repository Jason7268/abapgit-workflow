*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM08F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_CARRNAME
*&---------------------------------------------------------------------*
*& Get Airline name
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM get_carrname .
  CLEAR: zshiendialg_dm08h-carrname.

  SELECT SINGLE carrname
    FROM scarr
    INTO zshiendialg_dm08h-carrname
    WHERE carrid = zshiendialg_dm08h-carrid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SFLIGT
*&---------------------------------------------------------------------*
*& Get list data
*&---------------------------------------------------------------------*
FORM get_sfligt .
  SELECT *
    FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_detail
    WHERE carrid = zshiendialg_dm08h-carrid
      AND connid = zshiendialg_dm08h-connid.
  IF sy-subrc <> 0.
    MESSAGE 'No schedule line to be displayed' TYPE 'S'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_DATA
*&---------------------------------------------------------------------*
*& Create data

*&---------------------------------------------------------------------*
FORM create_data .
  DATA: ls_detail  TYPE zshiendialg_dm08d,
        ls_sflight TYPE sflight.
  IF gt_detail IS NOT INITIAL AND
  lines( gt_detail ) = 1.
    READ TABLE gt_detail INTO ls_detail INDEX 1.
    MOVE-CORRESPONDING ls_detail TO ls_sflight.
    INSERT sflight FROM ls_sflight.
    IF sy-subrc <> 0.
      MESSAGE 'Insertion failed.' TYPE 'E'.
    ELSE.
      gd_screen_mode = gc_mode_display.
    ENDIF.
  ENDIF.
ENDFORM.
" CREATE_DATA
*&---------------------------------------------------------------------*
*& Form UPDATE_DATA
*&---------------------------------------------------------------------*
*& Update data

*&---------------------------------------------------------------------*
FORM update_data .
  DATA: ls_detail  TYPE zshiendialg_dm08d,
        ls_sflight TYPE sflight,
        lt_sflight TYPE STANDARD TABLE OF sflight.

  CHECK gt_Detail IS NOT INITIAL.

  LOOP AT gt_Detail INTO ls_Detail.
    CLEAR ls_sflight.

    MOVE-CORRESPONDING ls_detail TO ls_sflight.

    APPEND ls_sflight TO lt_sflight.

  ENDLOOP.

  IF lt_sflight IS NOT INITIAL.
    UPDATE sflight FROM TABLE lt_sflight.
  ENDIF.

  IF sy-subrc <> 0.
    MESSAGE 'Updating failed.' TYPE 'E'.
  ELSE.
    gd_screen_mode = gc_mode_display.
  ENDIF.
ENDFORM.
