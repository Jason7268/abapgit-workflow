*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM06_2TOP
*&---------------------------------------------------------------------*
CONSTANTS: GC_SCREENM_CREATE TYPE I VALUE 1,
           GC_SCREENM_CHANGE TYPE I VALUE 2,
           GC_SCREENM_DISPLAY TYPE I VALUE 3.
TABLES: ZSHIENDIALG_T05.

DATA: SCR_OKCODE TYPE SY-UCOMM.


DATA: GD_SCREEN_MODE TYPE I.

DATA: GS_BEFORE_CHANGES TYPE ZSHIENDIALG_T05.
