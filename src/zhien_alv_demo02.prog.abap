*&---------------------------------------------------------------------*
*& Report ZHIEN_ALV_DEMO02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_alv_demo02.

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
*SELECTION-SCREEN BEGIN OF BLOCK b002 WITH FRAME TITLE TEXT-b02.
*  PARAMETERS: r_grid RADIOBUTTON GROUP rb1,
*              r_list RADIOBUTTON GROUP rb1.
*SELECTION-SCREEN END OF BLOCK b002.
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

  DATA: lt_fieldcat TYPE lvc_t_fcat, " FIELD CATALOG
        ls_layout   TYPE lvc_s_layo.

  DATA: lo_alv_table TYPE REF TO cl_gui_alv_grid.

*   Get po data
  PERFORM get_po_data CHANGING lt_po_data.

* Create ALV Tabel Object.
  PERFORM create_alv_object CHANGING lo_alv_table.

* Prepage ALV settings
  PERFORM prepare_alv CHANGING lt_fieldcat
                               ls_layout.
* Display ALV Report
  PERFORM display CHANGING   lt_po_data
                             lt_fieldcat
                             ls_layout
                             lo_alv_table.
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
FORM prepare_alv  CHANGING Ct_fieldcat TYPE lvc_t_fcat
                           Cs_layout   TYPE lvc_s_layo.
  DATA: LS_fieldcat TYPE LINE OF lvc_t_fcat.

  CLEAR: Ct_fieldcat.

  CLEAR: LS_fieldcat.
  ls_fieldcat-fieldname = 'PO_NUMBER' .
  ls_fieldcat-datatype = 'NUMC' .
  ls_fieldcat-outputlen = '10'.
  ls_fieldcat-scrtext_s = 'PO No.'.
  ls_fieldcat-scrtext_m = 'Purchase Order'.
  ls_fieldcat-scrtext_l = 'Purchase Order' .

  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: LS_fieldcat.
  ls_fieldcat-fieldname = 'COMPANY_CODE'.
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = '4'.
  ls_fieldcat-scrtext_s = 'CoCode' .
  ls_fieldcat-scrtext_m = 'Comapny Code' .
  ls_fieldcat-scrtext_l = 'Comapny Code' .
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'VENDOR_CODE' .
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = '10'.
  ls_fieldcat-scrtext_s = 'Vendor'.
  ls_fieldcat-scrtext_m = 'Vendor Code'.
  ls_fieldcat-scrtext_l = 'Vendor Code'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'VENDOR_NAME' .
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = '30'.
  ls_fieldcat-scrtext_s = 'Vendor'.
  ls_fieldcat-scrtext_m = 'Vendor Name'.
  ls_fieldcat-scrtext_l = 'Vendor Name' .
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'CURRENCY' .
  ls_fieldcat-datatype = 'CUKY' .
  ls_fieldcat-scrtext_s = 'Curr.'.
  ls_fieldcat-scrtext_m = 'Currency' .
  ls_fieldcat-scrtext_l = 'Currency'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'total_amount' .
  ls_fieldcat-Cfieldname = 'CURRENCY' .
*  ls_fieldcat-currency = 'USD' .
  ls_fieldcat-datatype = 'CURR' .
  ls_fieldcat-scrtext_s = 'T.Amount'.
  ls_fieldcat-scrtext_m = 'Total Amount' .
  ls_fieldcat-scrtext_l = 'Total Amount'.
  ls_fieldcat-do_sum = abap_on.
  APPEND ls_fieldcat TO ct_fieldcat.

  cs_layout-cwidth_opt = 'X'.
  cs_layout-zebra = abap_on.
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
FORM display  CHANGING Ct_po_data  TYPE tt_po_Data
                       Ct_fieldcat TYPE lvc_t_fcat
                       Cs_layout   TYPE lvc_s_layo
                       co_alv_table TYPE REF TO cl_gui_alv_grid.

*  CALL METHOD co_alv_table->set_table_for_first_display
*    EXPORTING
*      is_layout                     = Cs_layout
*    CHANGING
*      it_outtab                     = Ct_po_data
*      it_fieldcatalog               = Ct_fieldcat
*    EXCEPTIONS
*      invalid_parameter_combination = 1
*      program_error                 = 2
*      too_many_lines                = 3
*      OTHERS                        = 4.

  co_alv_table->set_table_for_first_display(
    EXPORTING
      is_layout                     = Cs_layout
    CHANGING
      it_outtab                     = Ct_po_data
      it_fieldcatalog               = Ct_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4 ).

  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL SCREEN 9000.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*& create_alv_object
*&---------------------------------------------------------------------*

FORM create_alv_object  CHANGING Co_alv_table.
  Co_alv_table =  NEW cl_gui_alv_grid( i_parent = cl_gui_custom_container=>default_screen ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
 SET PF-STATUS 'GUI_STATUS_9000'.
 SET TITLEBAR 'GUI_TITTLE_9000'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'CANC'.
       LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
