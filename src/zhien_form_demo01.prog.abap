*&---------------------------------------------------------------------*
*& Report ZHIEN_FORM_DEMO01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_form_demo01 NO STANDARD PAGE HEADING.
* DeclarationsTypes |
TYPES: ty_r_po_number TYPE RANGE OF  ZtHIEN_po_head-ebeln.
TYPES: ty_r_company_code TYPE RANGE OF ZtHIEN_po_head-bukrs.
TYPES: BEGIN OF ts_po_header,
         po_number    TYPE ZtHIEN_po_head-ebeln,
         company_code TYPE ZtHIEN_po_head-bukrs,
         vendor_code  TYPE ZtHIEN_po_head-lifnr,
         vendor_name  TYPE ZtHIEN_po_head-lif_name,
         currency     TYPE ZtHIEN_po_head-waers,
       END OF ts_po_header,
       tt_po_header TYPE STANDARD TABLE OF ts_po_header WITH NON-UNIQUE KEY po_number.
TYPES: BEGIN OF ts_po_item,
         po_number  TYPE ZtHIEN_po_item-ebeln,
         line_item  TYPE ZtHIEN_po_item-ebelp,
         material   TYPE ZtHIEN_po_item-matnr,
         short_text TYPE ZtHIEN_po_item-txz01,
         quantity
           TYPE ZtHIEN_po_item-menge,
         uom        TYPE ZtHIEN_po_item-meins,
         price      TYPE ZtHIEN_po_item-netpr,
       END OF ts_po_item,
       tt_po_item TYPE STANDARD TABLE OF ts_po_item WITH NON-UNIQUE KEY po_number line_item.

*Declarations - Datal
DATA: gd_sel_po_number TYPE ZtHIEN_po_head-ebeln. " Only use for Select-options
DATA: gd_sel_company_code TYPE ZtHIEN_po_head-bukrs. " Only use for Select-options
DATA: gs_current_header TYPE ts_po_header,
      gt_header         TYPE tt_po_header,
      gt_items          TYPE tt_po_item.

*Declarations - Data
*Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b001 WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: s_ponum FOR gd_sel_po_number.
  SELECT-OPTIONS: s_comco FOR gd_sel_company_code.
SELECTION-SCREEN END
OF BLOCK b001.
SELECTION-SCREEN BEGIN OF BLOCK b002 WITH FRAME TITLE TEXT-802.
SELECTION-SCREEN END
OF BLOCK b002.
*INITIALIZATION
INITIALIZATION.
*Modify Selection-Screen
AT SELECTION-SCREEN OUTPUT.
*Validate Selection-Screen Inputs
AT SELECTION-SCREEN.

AT LINE-SELECTION.
    PERFORM SHOW_FORM.
*Main Program
START-OF-SELECTION.
  PERFORM execute_report.

TOP-OF-PAGE.
  PERFORM top_of_page.
* Main Processing

FORM execute_report.

  PERFORM get_po_header.
  PERFORM get_po_items.
  PERFORM display_report.
ENDFORM.

*& Form GET_PO_HEADER
*& Get Purchase Order Header
FORM get_po_header.
  SELECT ebeln AS po_number,
  bukrs AS company_code,
  lifnr AS vendor_code,
  lif_name AS vendor_name,
  waers AS currency
  FROM ZtHIEN_po_head
  WHERE ebeln IN @s_ponum[]
  AND bukrs IN @s_comco[]
  INTO TABLE @gt_header.
  IF sy-subrc <> 0.
*    *    MESSAGE e005(yxxx_test_msgcls).
    MESSAGE 'FAIL TO GET ITEM DATA' TYPE 'I'.
  ENDIF.
ENDFORM.

*& Form GET_PO_ITEMS)
*& Get Purchase Order Items
FORM get_po_items.
  SELECT ebeln AS po_number,
  ebelp AS line_item,
  matnr AS material,
  txz01 AS short_text,
  menge AS quantity,
  meins AS uom,
  netpr AS price
  FROM ZtHIEN_po_item
  FOR ALL ENTRIES IN @gt_header
  WHERE ebeln = @gt_header-po_number
  ORDER BY PRIMARY KEY
  INTO TABLE @gt_items.
  IF sy-subrc <> 0.
*    MESSAGE e005(yxxx_test_msgcls).
    MESSAGE 'FAIL TO GET ITEM DATA' TYPE 'I'.
  ENDIF.
ENDFORM.

*& DisplAy the maIn report.
FORM display_report.
  LOOP AT gt_header INTO DATA(lds_header).
    gs_current_header =  lds_header.
    NEW-PAGE.
    FORMAT COLOR COL_HEADING.
    WRITE:/(8) 'Line No.',
            (18) 'Material Code',
            (25) 'Short Text',
            (18) 'Quantity' RIGHT-JUSTIFIED,
            (5) 'UoM',
            (20) 'Net Price' RIGHT-JUSTIFIED,
            (5) 'Curr.'.
    FORMAT COLOR OFF.
    LOOP AT gt_items INTO DATA(lds_items)
    WHERE po_number = lds_header-po_number.
      FORMAT COLOR COL_NORMAL.
      WRITE:/(8) lds_items-line_item,
      (18) lds_items-material,
      (25) lds_items-short_text,
      (18) lds_items-quantity UNIT lds_items-uom,
      (5)  lds_items-uom,
      (20) lds_items-price CURRENCY lDS_header-currency,
      (5) lds_header-currency.
      FORMAT COLOR OFF.
    ENDLOOP.

  ENDLOOP.

*LOOP AT gt_header INTO DATA(lds_header).
*  CONTINUE.
**    gs_current_header =  lds_header.
*
**    LOOP AT gt_items INTO DATA(lds_items)
**    WHERE po_number = lds_header-po_number.
**
**    ENDLOOP.
**
*  ENDLOOP.

*      DATA: lv_funcname TYPE rs38l_fnam.
*
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          formname           = 'ZFHIEN_FORM_DEMO01'
**         VARIANT            = ' '
**         DIRECT_CALL        = ' '
*        IMPORTING
*          fm_name            = lv_funcname
*        EXCEPTIONS
*          no_form            = 1
*          no_function_module = 2
*          OTHERS             = 3.
*      IF sy-subrc = 0.
**       Implement suitable error handling here
*
*        CALL FUNCTION lv_funcname
*       EXPORTING
**         ARCHIVE_INDEX      =
**         ARCHIVE_INDEX_TAB  =
**         ARCHIVE_PARAMETERS =
**         CONTROL_PARAMETERS =
**         MAIL_APPL_OBJ      =
**         MAIL_RECIPIENT     =
**         MAIL_SENDER        =
**         OUTPUT_OPTIONS     =
**         USER_SETTINGS      =
**        IMPORTING
**          DOCUMENT_OUTPUT_INFO
**          JOB_OUTPUT_INFO
**          JOB_OUTPUT_OPTIONS
*          IM_PO_HEAD = lds_header
*          TABLES
*            TAB_ITEMS        = gt_items
*          EXCEPTIONS
*            formatting_error = 1
*            internal_error   = 2
*            send_error       = 3
*            user_canceled    = 4.
*        IF sy-subrc = 0.
*
*        ENDIF.
*      ENDIF.

ENDFORM.

*& Form TOP_OF_PAGE)
** Snow cop-or-ocael
FORM top_of_page.
  WRITE: 240 'Pagc: ',  sy-pagno RIGHT-JUSTIFIED.
  WRITE: / 'Purchase Order: ', gs_current_header-po_number HOTSPOT COLOR COL_KEY.
  HIDE:  gs_current_header.
  SELECT SINGLE butxt FROM t001 INTO @DATA(ldf_company_name)
  WHERE bukrs = @gs_current_header-company_code.
  WRITE: / 'company code' , gs_current_header-company_code,'-', ldf_company_name.
  WRITE: / 'Supplier: ', gs_current_header-vendor_code, '-', gs_current_header-vendor_name.


  SKIP 1.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM show_form .
  DATA: LT_ITEM TYPE ztthienform_po_item,
        LS_HEAD TYPE ZSHIENFORM_PO_HEAD.

  MOVE-CORRESPONDING GS_CURRENT_HEADER TO LS_HEAD.

  LT_ITEM[] =  GT_ITEMS[].
  DELETE LT_ITEM
    WHERE PO_NUMBER <> LS_HEAD-PO_NUMBER.

  CALL FUNCTION '/1BCDWB/SF00000094'
    EXPORTING
*     ARCHIVE_INDEX              =
*     ARCHIVE_INDEX_TAB          =
*     ARCHIVE_PARAMETERS         =
*     CONTROL_PARAMETERS         =
*     MAIL_APPL_OBJ              =
*     MAIL_RECIPIENT             =
*     MAIL_SENDER                =
*     OUTPUT_OPTIONS             =
*     USER_SETTINGS              = 'X'
      im_po_head                 = LS_HEAD
*   IMPORTING
*     DOCUMENT_OUTPUT_INFO       =
*     JOB_OUTPUT_INFO            =
*     JOB_OUTPUT_OPTIONS         =
    tables
      tab_items                  = LT_ITEM
    EXCEPTIONS
      FORMATTING_ERROR           = 1
      INTERNAL_ERROR             = 2
      SEND_ERROR                 = 3
      USER_CANCELED              = 4
      OTHERS                     = 5
            .
  IF sy-subrc <> 0.
    MESSAGE 'Error form' TYPE 'E'.
  ENDIF.

ENDFORM.
