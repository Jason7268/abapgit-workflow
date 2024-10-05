*&---------------------------------------------------------------------*
*& Include          ZHIEN_SO_UPLOADTOP
*&---------------------------------------------------------------------*
*Block 1: Upload multiple SO Data
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: p_psohd TYPE string.
  PARAMETERS: p_psoit TYPE string.
SELECTION-SCREEN END OF BLOCK b01.

TYPES: BEGIN OF ty_log,
         vbeln   TYPE vbak-vbeln,
         level   TYPE char8,
         message TYPE text150,
       END OF ty_log,

       ty_t_log TYPE STANDARD TABLE OF ty_log,

       BEGIN OF ty_upload,
         col1 TYPE string,
       END OF ty_upload,
       ty_t_upload TYPE STANDARD TABLE OF ty_upload,

       BEGIN OF ty_material,
         matnr TYPE zhien_mara-zzmatnr,
       END OF ty_material,
       ty_t_material TYPE STANDARD TABLE OF ty_material,

       BEGIN OF ty_customer,
         kunnr TYPE zhien_kna1-zzcustomer,
       END OF ty_customer,
       ty_t_customer TYPE STANDARD TABLE OF ty_customer,

      "itab to check header exist
       BEGIN OF ty_ordernumb,
         vbeln TYPE zhien_vbak-zzvbeln,
       END OF ty_ordernumb,
       ty_t_ordernumb TYPE STANDARD TABLE OF ty_ordernumb,

       "itab to check so item exist
       BEGIN OF ty_itemnumb,
         zzvbeln TYPE zhien_vbak-zzvbeln,
         zzvbelp TYPE zhien_vbap-zzvbelp,
       END OF ty_itemnumb,
       ty_t_itemnumb TYPE STANDARD TABLE OF ty_itemnumb,

       "itab to check company code exist
       BEGIN OF ty_comcode,
         bukrs TYPE t001-bukrs,
       END OF ty_comcode,
       ty_t_comcode TYPE STANDARD TABLE OF ty_comcode,

       ty_t_soheader type STANDARD TABLE OF zhien_vbak,
       ty_t_soitem type STANDARD TABLE OF zhien_vbap.

       DATA: gv_counthd       TYPE I,
             gv_countso_error TYPE I,
             gv_soupload      TYPE I.
