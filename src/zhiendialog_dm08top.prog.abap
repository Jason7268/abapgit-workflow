*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM08TOP
*&---------------------------------------------------------------------*

CONTROLS: TC_DETAIL_LIST TYPE TABLEVIEW USING SCREEN 0100.

TABLES: ZSHIENDIALG_DM08D, ZSHIENDIALG_DM08h.

DATA: SCR_OKCODE TYPE SY-UCOMM.

DATA: GT_DETAIL TYPE STANDARD TABLE OF ZSHIENDIALG_DM08D,
      GD_FLAG_RESET_TC TYPE C, " not use
      GD_SCREEN_MODE TYPE C.

CONSTANTS: GC_MODE_CREATE TYPE C VALUE '1',
           GC_MODE_CHANGE TYPE C VALUE '2',
           GC_MODE_DISPLAY TYPE C VALUE '3'.
