*&---------------------------------------------------------------------*
*& Include          ZHIEN_DIALOG_EX01PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100' ."EXCLUDING 'SAVE'.
  SET TITLEBAR 'TITLE_0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  IF gd_screen_mode IS INITIAL.
    gd_screen_mode = gc_mode_display.
  ENDIF.

  CASE gd_screen_mode.
    WHEN gc_mode_display OR space.
      SET PF-STATUS 'STATUS_0200' EXCLUDING 'SAVE'  .
      SET TITLEBAR 'TITLE_0200_DISP'.

    WHEN gc_mode_create.
      SET PF-STATUS 'STATUS_0200' EXCLUDING 'CREATE'.
      SET TITLEBAR 'TITLE_0200_CREA'.

    WHEN gc_mode_change.
      SET PF-STATUS 'STATUS_0200'.
      SET TITLEBAR 'TITLE_0200_CHAN'.

    WHEN OTHERS.
  ENDCASE.
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
        WHEN gc_mode_display OR gc_mode_change .
          screen-input = '0'.
          screen-required = '0'.
        WHEN  gc_mode_create.
          screen-input = '1'.
          screen-required = '1'.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
    IF screen-group1 = 'HD2'.
      CASE gd_screen_mode.
        WHEN gc_mode_display.
          screen-input = '0'.
          screen-required = '0'.
        WHEN gc_mode_change OR gc_mode_create.
          screen-input = '1'.
          screen-required = '1'.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    IF screen-group1 = 'HD3'.
      IF gd_screen_mode = gc_mode_display.
        screen-invisible = 1.
*        screen-input = 0.
*        screen-active = 1.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_TABLE_FIELD OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE modify_table_field OUTPUT.
  LOOP AT SCREEN.
    CASE gd_screen_mode.
      WHEN gc_mode_display.
        IF screen-group1 = 'DT2' OR screen-group1 = 'DT1'.
          screen-input = '0'.
        ENDIF.
      WHEN gc_mode_create OR gc_mode_change.
        IF screen-group1 = 'DT2'.
          screen-input = '1'.
          screen-required = '1'.
        ENDIF.
        IF screen-group1 = 'DT1'.
          screen-input = '1'.
        ENDIF.
*      WHEN gc_mode_change.
*        IF screen-group1 = 'DT1'.
*          screen-input = '0'.
*        ENDIF.
*        IF screen-group1 = 'DT2' .
*          screen-input = '1'.
*          screen-required = '1'.
*        ENDIF.
      WHEN OTHERS.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PREPARE_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE prepare_data OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
