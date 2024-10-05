*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM06_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
 SET PF-STATUS 'STATUS_0100'.
 SET TITLEBAR  'TITLE_0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.


  IF scr_okcode = 'DISSCR'.
   SET PF-STATUS 'STATUS_0200D'.
   SET TITLEBAR  'TITLE_0200_DIS'.
   PERFORM setgreen USING 0.

   ELSEIF scr_okcode = 'CHASCR'.
     SET PF-STATUS 'STATUS_0200C'.
     SET TITLEBAR  'TITLE_0200_CHA'.

   ELSEIF scr_okcode = 'CRESCR'.
     SET PF-STATUS 'STATUS_0200CR'.  "STANDARD
     SET TITLEBAR  'TITLE_0200_CRE'.
  ENDIF.
   PERFORM SETUP_LISTBOX.

ENDMODULE.
