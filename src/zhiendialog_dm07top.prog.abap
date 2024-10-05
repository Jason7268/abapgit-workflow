*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM07TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_header,
         carrid   TYPE spfli-carrid,
         carrname TYPE scarR-carrname,
       END OF ty_header.


TYPES: BEGIN OF ty_detail,
         carrID       TYPE spfli-caRRID,
         connid       TYPE spfli-connid,
         countryfr    TYPE spfli-countryfr,
         countryfr_nm TYPE t005t-landx,
         countryto    TYPE spflI-countryto,
         countryto_nm TYPE t005t-landx,
         distance     TYPE spfli-distance,
         distid       TYPE spfli-distid,
       END OF ty_detail.

CONTROLS: tc_detail_list TYPE TABLEVIEW USING SCREEN 100.

DATA : scr_okcode TYPE sy-ucomm.

DATA: gs_header TYPE ty_header,
      gs_detail TYPE ty_detail,
      gt_detail TYPE STANDARD TABLE OF ty_detail.
