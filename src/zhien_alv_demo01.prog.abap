*&---------------------------------------------------------------------*
*& Report ZHIEN_ALV_DEMO01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_alv_demo01.

* DecLARATION - Types.
TYPES: BEGIN OF ts_po_data,
         po_number
           TYPE ZTHIEN_po_head-ebeln,
         company_code TYPE zthien_po_head-bukrs,
         vendor_code  TYPE zthien_po_head-lifnr,
         vendor_name  TYPE zthien_po_head-lif_name,
         currency     TYPE zthien_po_head-waers,
         total_amount TYPE curr23_2,
       END OF ts_po_data,
       tt_po_data TYPE STANDARD TABLE OF ts_po_data
                    WITH NON-UNIQUE KEY po_number.


*Deccaratzons - Data
DATA: gd_sel_po_number TYPE zthien_PO_HEAD-ebeln. "Only use for Select-options.
DATA: gd_sel_company_code TYPE zthien_PO_HEAD-bukrs. " Only use for Select-options

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH  FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: s_ponum FOR gd_sel_po_number.
  SELECT-OPTIONS: s_comco FOR gd_sel_company_code.
SELECTION-SCREEN END OF BLOCK b01.
SELECTION-SCREEN BEGIN OF BLOCK b002 WITH FRAME TITLE TEXT-b02.
  PARAMETERS: r_grid RADIOBUTTON GROUP rb1,
              r_list RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK b002.
*initialilaliOn
INITIALIZATION.

* MoDIFY selection-screen
AT SELECTION-SCREEN OUTPUT.
* Validate SeLECTION SCREEN INPUTS
AT SELECTION-SCREEN.
*Main ProGRAm
START-OF-SELECTION.
  PERFORM main.

*SubroutTINES.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& Main processing

*&---------------------------------------------------------------------*
FORM main .
  DATA: lt_po_data TYPE tt_po_data.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv, " FIELD CATALOG
        ls_layout   TYPE slis_layout_alv.
  .

*   Get po data
  PERFORM get_po_data CHANGING lt_po_data.
* Prepage ALV settings
  PERFORM prepare_alv CHANGING lt_fieldcat
                               ls_layout.
* Display ALV Report
  PERFORM display CHANGING   lt_po_data
                             lt_fieldcat
                             ls_layout.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_PO_DATA
*&---------------------------------------------------------------------*
FORM get_po_data  CHANGING ct_po_data TYPE tt_po_data.

  SELECT hd~ebeln    AS po_number,
         hd~bukrs    AS company_code,
         hd~lifnr    AS vendor_code,
         hd~lif_name AS vendor_name,
         hd~waers    AS currency,
         SUM( it~menge * it~netpr ) AS total_amount
    FROM  zthien_po_head AS hd INNER JOIN zthien_po_item AS it
      ON hd~ebeln = it~ebeln
    INTO CORRESPONDING FIELDS OF  TABLE @ct_po_data
    WHERE hd~ebeln IN @s_ponum
      AND hd~bukrs IN @s_comco
    GROUP BY hd~ebeln,
             hd~bukrs,
             hd~lifnr,
             hd~lif_name,
             hd~waers
    .
  IF sy-subrc <> 0.
    "Data not found. Please try to change selection conditions.
    MESSAGE e005(zhien_msg).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_ALV
*&---------------------------------------------------------------------*
*& text
*&      <-- LS_LAYOUT
*&---------------------------------------------------------------------*
FORM prepare_alv  CHANGING Ct_fieldcat TYPE slis_t_fieldcat_alv
                           Cs_layout   TYPE slis_layout_alv.
  DATA: LS_fieldcat TYPE LINE OF slis_t_fieldcat_alv.

  CLEAR: Ct_fieldcat.

  CLEAR: LS_fieldcat.
  ls_fieldcat-fieldname = 'PO_NUMBER' .
  ls_fieldcat-datatype = 'NUMC' .
  ls_fieldcat-outputlen = '10'.
*  ls_fieldcat-REF-FIELDNAME
*  ls_fieldcat-REF_TABNAME
  ls_fieldcat-seltext_s = 'PO No.'.
  ls_fieldcat-seltext_m = 'Purchase Order'.
  ls_fieldcat-seltext_l = 'Purchase Order' .

  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: LS_fieldcat.
  ls_fieldcat-fieldname = 'COMPANY_CODE'.
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = '4'.
  ls_fieldcat-seltext_s = 'CoCode' .
  ls_fieldcat-seltext_m = 'Comapny Code' .
  ls_fieldcat-seltext_l = 'Comapny Code' .
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'VENDOR_CODE' .
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = '10'.
  ls_fieldcat-seltext_s = 'Vendor'.
  ls_fieldcat-seltext_m = 'Vendor Code'.
  ls_fieldcat-seltext_l = 'Vendor Code'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'VENDOR_NAME' .
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = '30'.
  ls_fieldcat-seltext_s = 'Vendor'.
  ls_fieldcat-seltext_m = 'Vendor Name'.
  ls_fieldcat-seltext_l = 'Vendor Name' .
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'CURRENCY' .
  ls_fieldcat-datatype = 'CUKY' .
  ls_fieldcat-seltext_s = 'Curr.'.
  ls_fieldcat-seltext_m = 'Currency' .
  ls_fieldcat-seltext_l = 'Currency'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'total_amount' .
  ls_fieldcat-Cfieldname = 'CURRENCY' .
*  ls_fieldcat-currency = 'USD' .
  ls_fieldcat-datatype = 'CURR' .
  ls_fieldcat-seltext_s = 'T.Amount'.
  ls_fieldcat-seltext_m = 'Total Amount' .
  ls_fieldcat-seltext_l = 'Total Amount'.
  ls_fieldcat-do_sum = abap_on.
  APPEND ls_fieldcat TO ct_fieldcat.

  cs_layout-colwidth_optimize = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_PO_DATA
*&      <-- LT_FIELDCAT
*&      <-- LS_LAYOUT
*&---------------------------------------------------------------------*
FORM display  CHANGING Ct_po_data  TYPE tt_po_data
                       Ct_fieldcat TYPE slis_t_fieldcat_alv
                       Cs_layout   TYPE slis_layout_alv.
  IF r_grid = abap_true.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        is_layout     = Cs_layout
        it_fieldcat   = Ct_fieldcat
*       IT_SORT       =
*       IT_FILTER     =
      TABLES
        t_outtab      = Ct_po_data
      EXCEPTIONS
        program_error = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        is_layout     = Cs_layout
        it_fieldcat   = Ct_fieldcat
*       IT_SORT       =
*       IT_FILTER     =
      TABLES
        t_outtab      = Ct_po_data
      EXCEPTIONS
        program_error = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDIF.


ENDFORM.
