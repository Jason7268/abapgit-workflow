*&---------------------------------------------------------------------*
*& Include          ZHIEN_DIALOG_DEMOLOGINTOP
*&---------------------------------------------------------------------*



DATA: scr_okcode    TYPE sy-ucomm,
      scr_password    TYPE zhien_login-password,
      scr_password2 TYPE zhien_login-password,
      gv_mark       TYPE char01.

TABLES: zhien_login.

TYPES: BEGIN OF ty_detail,
         username TYPE zhien_login-username,
         password TYPE zhien_login-password,
         name2    TYPE zhien_login-name2,
       END OF ty_detail.

CONTROLS: tc_detail_list TYPE TABLEVIEW USING SCREEN 200.

DATA: gs_detail  TYPE zhien_login,
      gt_detail  TYPE STANDARD TABLE OF zhien_login,
      gs_sflight TYPE sflight,
      gt_sflight TYPE STANDARD TABLE OF sflight,
      gs_scarr   TYPE scarr,
      gt_scarr   TYPE STANDARD TABLE OF scarr.

*CONTROLS: tc_product TYPE TABLEVIEW USING SCREEN 0100. " Khai bao table control
CONTROLS: ts_control TYPE TABSTRIP,
          tc_sflight TYPE TABLEVIEW USING SCREEN 0200,
          tc_scarr   TYPE TABLEVIEW USING SCREEN 0500.
