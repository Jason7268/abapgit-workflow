*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM05_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
 SET PF-STATUS 'STATUS_BASIC'.
 SET TITLEBAR 'TITLE_0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
   SET PF-STATUS 'STATUS_BASIC'.
   SET TITLEBAR 'TITLE_0100'.
   scr_dynnr = SY-dynnr.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
   SET PF-STATUS 'STATUS_BASIC'.
   SET TITLEBAR 'TITLE_0300'.

   scr_dynnr = SY-dynnr.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
   SET PF-STATUS 'STATUS_BASIC'.
   SET TITLEBAR 'TITLE_0400'.

   scr_dynnr = SY-dynnr.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
   SET PF-STATUS 'STATUS_BASIC'.
   SET TITLEBAR 'TITLE_0500'.

   scr_dynnr = SY-dynnr.
ENDMODULE.
