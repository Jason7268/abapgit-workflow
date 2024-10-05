*&---------------------------------------------------------------------*
*& Include          ZHIEN_ALV_INCL_DEFINITIONS
*&---------------------------------------------------------------------*

*TABLES : KNA1, vbak, adrc.

DATA: GD_DUMMY_VBELN TYPE VBAK-VBELN.

TYPES: TY_R_VBELN TYPE RANGE OF VBAK-VBELN.

TYPES: BEGIN OF ty_saledoc,
         vbeln TYPE vbak-vbeln,
         kunnr TYPE vbak-kunnr,
         adrnr TYPE kna1-adrnr,
         name1 TYPE adrc-name1,
         city1 TYPE adrc-city1,
       END   OF ty_saledoc,
       ty_t_saledoc TYPE STANDARD TABLE OF ty_saledoc.

TYPES: BEGIN OF ty_addresscus,
         addrnumber TYPE adrc-addrnumber,
         name1      TYPE adrc-name1,
         city1      TYPE adrc-city1,
       END   OF ty_addresscus,
       ty_t_addresscus TYPE STANDARD TABLE OF ty_addresscus.

TYPES: BEGIN OF ty_outputalv,
         vbeln TYPE vbak-vbeln,
         kunnr TYPE vbak-kunnr,
         adrnr TYPE  kna1-adrnr,
         name1 TYPE adrc-name1,
         city1 TYPE adrc-city1,
       END   OF ty_outputalv,
       ty_t_outputalv TYPE STANDARD TABLE OF ty_outputalv.

DATA: gt_saledoc    TYPE  ty_t_saledoc.

SELECT-OPTIONS: s_vbeln FOR gd_dummy_vbeln.
