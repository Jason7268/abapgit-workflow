*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM06_2PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE modify_screen_0200 OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'GR1'.
      CASE gd_screen_mode.
        WHEN gc_screenm_create.
          screen-input = '1'.
          screen-requireD = '1'.
        WHEN gc_screenm_change.
          screen-input = '0'.
          screen-requireD = '0'.
        WHEN gc_screenm_display.
          screen-input = '0'.
          screen-requireD = '0'.
      ENDCASE.
    ELSEIF screen-group1 = 'GR2'.
      CASE gd_screen_mode.
        WHEN gc_screenm_create.
          screen-input = '1'.

        WHEN gc_screenm_change.
          screen-input = '1'.

        WHEN gc_screenm_display.
          screen-input = '0'.

      ENDCASE.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  CASE gd_screen_mode.
    WHEN gc_screenm_create.
      SET PF-STATUS 'STATUS_0200_CREA'.
      SET TITLEBAR 'TITLE_0200_CREA'.
    WHEN gc_screenm_change.
      SET PF-STATUS 'STATUS_0200_CHNG'.
      SET TITLEBAR 'TITLE_0200_CHNG'.
    WHEN gc_screenm_display.
      SET PF-STATUS 'STATUS_0200_DISP'.
      SET TITLEBAR 'TITLE_0200_DISP'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
