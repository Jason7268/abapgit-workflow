*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM08PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module PREPARE_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE prepare_data OUTPUT.
* Get Airline name
  IF zshiendialg_dm08h-carrid IS NOT INITIAL.
    PERFORM get_carrname.
  ENDIF.

* Get SFLIGHT
  IF gd_screen_mode = gc_mode_display
     AND zshiendialg_dm08h-carrid IS NOT INITIAL
     AND zshiendialg_dm08h-connid IS NOT INITIAL.

    PERFORM get_sfligt.

  ENDIF.
* Get number of lines of internal table to config Table Control
  DESCRIBE TABLE gt_detail LINES tc_detail_list-lines.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module MODIFY_TABLE_FIELD OUTPUT
*&---------------------------------------------------------------------*
*& Modify table screen field
*&---------------------------------------------------------------------*
MODULE modify_table_field OUTPUT.
  LOOP AT SCREEN.
    CASE gd_screen_mode.
      WHEN gc_mode_display.
        IF screen-group1 = 'DT1' OR
           screen-group1 = 'DT2' OR
           screen-group1 = 'DT3' .
          screen-input = '0'.
        ENDIF.
      WHEN gc_mode_change.
        IF screen-group1 = 'DT1' OR
           screen-group1 = 'DT3' .
          screen-input = '0'.
        ENDIF.

        IF screen-group1 = 'DT2' .
          screen-input = '1'.
        ENDIF.
      WHEN gc_mode_create.
        IF screen-group1 = 'DT3' .
          screen-input = '0'.
        ENDIF.

        IF screen-group1 = 'DT1' OR
           screen-group1 = 'DT2' .
          screen-input = '1'.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_HEADER_FIELD OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE modify_header_field OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'HD1'.
      CASE gd_screen_mode.
        WHEN gc_mode_display.
          screen-input = '1'.
          screen-required = '1'.
        WHEN gc_mode_change OR gc_mode_create.
          screen-input = '0'.
          screen-required = '0'.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  IF gd_screen_mode IS INITIAL.
    gd_screen_mode = gc_mode_display.
  ENDIF.

  CASE gd_screen_mode.
    WHEN gc_mode_display OR space.
      SET PF-STATUS 'STATUS_0100' EXCLUDING 'SAVE'.
      SET TITLEBAR 'TITLE_0100_DISP'.
    WHEN gc_mode_create.
      SET PF-STATUS 'STATUS_0100' EXCLUDING 'CREATE'.
      SET TITLEBAR 'TITLE_0100_CREA'.
    WHEN gc_mode_change.
      SET PF-STATUS 'STATUS_0100'.
      SET TITLEBAR 'TITLE_0100_CHNG'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
