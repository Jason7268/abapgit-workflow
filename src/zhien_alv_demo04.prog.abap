*&---------------------------------------------------------------------*
*& Report ZHIEN_ALV_DEMO02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_alv_demo04.

* DecLARATION - Types.
TYPES: BEGIN OF ts_po_data,
         po_number    TYPE ZTHIEN_po_head-ebeln,
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

  DATA: LO_ALV_TABLE TYPE REF TO CL_SALV_TABLE.

  DATA: lt_fieldcat TYPE lvc_t_fcat, " FIELD CATALOG
        ls_layout   TYPE lvc_s_layo.


*   Get po data
  PERFORM get_po_data CHANGING lt_po_data.

* Create ALV Tabel Object.
  PERFORM create_alv_object CHANGING lo_alv_table
                                     lt_po_data.

* Prepage ALV settings
  PERFORM prepare_alv CHANGING lo_alv_table.
* Display ALV Report
  PERFORM display CHANGING   lo_alv_table.
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
FORM prepare_alv  CHANGING co_alv_table TYPE REF TO CL_SALV_TABLE.
  DATA: LO_COLUMNS_LIST TYPE REF TO cl_salv_columns_table.

  DATA: LO_COLUMN TYPE REF TO cl_salv_column.
  DATA: LO_COLUMN_TABLE TYPE REF TO cl_salv_column_table.

  DATA: LO_D_SETTINGS TYPE REF TO cl_salv_display_settings.

  LO_COLUMNS_LIST = co_alv_table->get_columns( ).
  LO_COLUMNS_LIST->set_optimize( ).

*    TOTAL AMOUNT
  lo_column = lo_columns_list->get_column( columnname = 'TOTAL_AMOUNT' ).
  lo_column->set_currency_column( value = 'CURRENCY' ).
  lo_column->set_short_text( value = CONV #( TEXT-C01 ) ).
  lo_column->set_medium_text( value = CONV #( TEXT-C02 ) ).
*  CATCH cx_salv_not_found.  " ALV: General Error Class (Checked in Syntax Check)
*  CATCH cx_salv_data_error. " ALV: General Error Class (Checked in Syntax Check)

*   SET KEY PO NUMBER
    LO_COLUMN_TABLE ?= lo_columns_list->get_column( columnname = 'PO_NUMBER' ).
    LO_COLUMN_TABLE->set_key( ).

  lo_d_settings = co_alv_table->get_display_settings( ).
  lo_d_settings->set_striped_pattern( value = ABAP_TRUE ).

*  show Function toolbar
  co_alv_table->get_functions( )->set_all( ).

* sort
  co_alv_table->get_sorts( )->add_sort(
    EXPORTING
      columnname = 'PO_NUMBER' " ALV Control: Field Name of Internal Table Field
  ).
*  CATCH cx_salv_not_found.  " ALV: General Error Class (Checked in Syntax Check)
*  CATCH cx_salv_existing.   " ALV: General Error Class (Checked in Syntax Check)
*  CATCH cx_salv_data_error. " ALV: General Error Class (Checked in Syntax Check)

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
FORM display  CHANGING co_alv_table TYPE REF TO CL_SALV_TABLE.
  co_alv_table->display( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*& create_alv_object
*&---------------------------------------------------------------------*

FORM create_alv_object  CHANGING Co_alv_table TYPE REF TO CL_SALV_TABLE
                                 Ct_po_data   TYPE tt_po_Data.

  DATA: LD_LIST_FLAG TYPE SAP_BOOL.
  LD_LIST_FLAG = R_LIST.
  TRY .
    CL_SALV_TABLE=>factory(
    EXPORTING
      list_display   = LD_LIST_FLAG " ALV Displayed in List Mode
*      r_container    =                           " Abstract Container for GUI Controls
*      container_name =
    IMPORTING
      r_salv_table   = Co_alv_table                          " Basis Class Simple ALV Tables
    CHANGING
      t_table        = Ct_po_data
  ).
  CATCH cx_salv_msg. " ALV: General Error Class with Message.
*    TO DO: OUTPUT MESSAGE ERROR
  ENDTRY.

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
