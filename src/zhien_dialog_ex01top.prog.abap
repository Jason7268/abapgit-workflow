*&---------------------------------------------------------------------*
*& Include          ZHIEN_DIALOG_EX01TOP
*&---------------------------------------------------------------------*
TABLES: yshien_purorder, yshien_purordit.
DATA: scr_okcode         TYPE  sy-ucomm,
      scr_purchase_order TYPE yshien_purorder-purchase_order,
      scr_butxt          TYPE char25,
      scr_name1          TYPE char35.

DATA: gt_detail        TYPE STANDARD TABLE OF yshien_purordit,
      gd_flag_reset_tc TYPE c, " not use
      gd_screen_mode   TYPE c.

CONTROLS: tc_detail_list TYPE TABLEVIEW USING SCREEN 0200.

CONSTANTS: gc_mode_create  TYPE c VALUE '1',
           gc_mode_change  TYPE c VALUE '2',
           gc_mode_display TYPE c VALUE '3'.

DATA  linno TYPE i.                    "line number at cursor position
DATA  fld(20).                         "field name at cursor position
DATA  off TYPE i.                      "offset of cursor position
