*&---------------------------------------------------------------------*
*& Report ZHIEN_ALV_DEMO03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_alv_demo03.

* DecLARATION - Types.

TYPES: tt_po_HEAD TYPE STANDARD TABLE OF zthien_PO_HEAD
             WITH NON-UNIQUE KEY ebeln.

TYPES: tt_po_ITEM TYPE STANDARD TABLE OF zthien_PO_ITEM
             WITH NON-UNIQUE KEY ebeln ebelp.

CLASS lcl_alv_handler DEFINITION.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING it_po_head TYPE tt_po_HEAD.
    METHODS handle_dbclick
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        e_row
        e_column
        es_row_no.
  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA: _t_po_head TYPE tt_po_HEAD.
    DATA: _t_po_item TYPE tt_po_ITEM.
    DATA: _o_alv_table TYPE  REF TO cl_gui_alv_grid.

ENDCLASS.

*Deccaratzons - Data
DATA: gd_sel_po_number TYPE zthien_PO_HEAD-ebeln. "Only use for Select-options.
DATA: gd_sel_company_code TYPE zthien_PO_HEAD-bukrs. " Only use for Select-options

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH  FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: s_ponum FOR gd_sel_po_number.
  SELECT-OPTIONS: s_comco FOR gd_sel_company_code.
SELECTION-SCREEN END OF BLOCK b01.

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
  DATA: lt_po_head TYPE tt_po_head.

  DATA: lt_fieldcat TYPE lvc_t_fcat, " FIELD CATALOG
        ls_layout   TYPE lvc_s_layo.

  DATA: lo_alv_table TYPE REF TO cl_gui_alv_grid.

*   Get po data
  PERFORM get_po_data CHANGING lt_po_head.

* Create ALV Tabel Object.
  PERFORM create_alv_object CHANGING lo_alv_table.

* Prepage ALV settings
  PERFORM prepare_alv CHANGING lt_fieldcat
                               ls_layout.
* Display ALV Report
  PERFORM display CHANGING   lt_po_head
                             lt_fieldcat
                             ls_layout
                             lo_alv_table.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_po_data  CHANGING ct_po_head TYPE tt_po_head.

  SELECT *
    FROM zthien_PO_HEAD
    WHERE ebeln IN @s_ponum
      AND bukrs IN @s_comco
    ORDER BY PRIMARY KEY
    INTO CORRESPONDING FIELDS OF  TABLE @ct_po_head.
  IF sy-subrc <> 0.
    "Data not found. Please try to change selection conditions.
    MESSAGE e002(zhien_msg).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_po_ITEM USING u_ponum TYPE  zthien_PO_HEAD-ebeln
        CHANGING ct_po_item TYPE tt_po_item.

  SELECT *
    FROM zthien_PO_item
    WHERE ebeln = @u_ponum " Purchase order number
    ORDER BY PRIMARY KEY
    INTO CORRESPONDING FIELDS OF TABLE @ct_po_item .
  IF sy-subrc <> 0.
    "Data not found. Please try to change selection conditions.
    MESSAGE e002(zhien_msg).
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
  ls_fieldcat-fieldname = 'EBELN' .
  ls_fieldcat-datatype = 'CHAR' .
  ls_fieldcat-outputlen = '10'.
  ls_fieldcat-key = abap_on.
  ls_fieldcat-scrtext_s = 'PO No.'.
  ls_fieldcat-scrtext_m = 'Purchase Order'.
  ls_fieldcat-scrtext_l = 'Purchase Order' .

  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: LS_fieldcat.
  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = '4'.
  ls_fieldcat-scrtext_s = 'CoCode' .
  ls_fieldcat-scrtext_m = 'Comapny Code' .
  ls_fieldcat-scrtext_l = 'Comapny Code' .
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'LIFNR' .
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = '10'.
  ls_fieldcat-scrtext_s = 'Vendor'.
  ls_fieldcat-scrtext_m = 'Vendor Code'.
  ls_fieldcat-scrtext_l = 'Vendor Code'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'LIF_NAME' .
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = '30'.
  ls_fieldcat-scrtext_s = 'Vendor'.
  ls_fieldcat-scrtext_m = 'Vendor Name'.
  ls_fieldcat-scrtext_l = 'Vendor Name' .
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS' .
  ls_fieldcat-datatype = 'CUKY' .
  ls_fieldcat-scrtext_s = 'Curr.'.
  ls_fieldcat-scrtext_m = 'Currency' .
  ls_fieldcat-scrtext_l = 'Currency'.
  APPEND ls_fieldcat TO ct_fieldcat.


  cs_layout-cwidth_opt = 'X'.
  cs_layout-zebra = abap_on.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form PREPARE_ALV item
*&---------------------------------------------------------------------*
*& text
*&      <-- LS_LAYOUT
*&---------------------------------------------------------------------*
FORM prepare_alv_item  CHANGING Ct_fieldcat TYPE lvc_t_fcat
                                Cs_layout   TYPE lvc_s_layo.
  DATA: LS_fieldcat TYPE LINE OF lvc_t_fcat.

  CLEAR: Ct_fieldcat.

  CLEAR: LS_fieldcat.
  ls_fieldcat-fieldname = 'EBELN' .
  ls_fieldcat-datatype = 'CHAR' .
  ls_fieldcat-outputlen = '10'.
  ls_fieldcat-key = abap_on.
  ls_fieldcat-scrtext_s = 'PO No.'.
  ls_fieldcat-scrtext_m = 'Purchase Order'.
  ls_fieldcat-scrtext_l = 'Purchase Order' .

  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: LS_fieldcat.
  ls_fieldcat-fieldname = 'EBELP'.
  ls_fieldcat-datatype = 'NUMC'.
  ls_fieldcat-outputlen = '5'.
  ls_fieldcat-key = abap_on.
  ls_fieldcat-scrtext_s = 'Line' .
  ls_fieldcat-scrtext_m = 'Item Line' .
  ls_fieldcat-scrtext_l = 'Item Line' .
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'TXZ01' .
  ls_fieldcat-datatype  = 'CHAR'.
  ls_fieldcat-outputlen = '40'.
  ls_fieldcat-scrtext_s = 'Short Text'.
  ls_fieldcat-scrtext_m = 'Short Text'.
  ls_fieldcat-scrtext_l = 'Short Text'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'MATNR' .
  ls_fieldcat-datatype  = 'CHAR'.
  ls_fieldcat-outputlen = '40'.
  ls_fieldcat-scrtext_s = 'Material'.
  ls_fieldcat-scrtext_m = 'Material'.
  ls_fieldcat-scrtext_l = 'Material' .
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname  = 'MENGE' .
  ls_fieldcat-datatype   = 'QUAN' .
  ls_fieldcat-outputlen  = '13'.
  ls_fieldcat-decimals   = '3'.
  ls_fieldcat-qfieldname = 'MEINS'.
  ls_fieldcat-scrtext_s  = 'Quantity'.
  ls_fieldcat-scrtext_m  = 'PO Quantity' .
  ls_fieldcat-scrtext_l  = 'PO Quantity'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR: ls_fieldcat.
  ls_fieldcat-fieldname = 'MEINS' .
  ls_fieldcat-datatype  = 'BSTME' .
  ls_fieldcat-outputlen = '3'.
  ls_fieldcat-scrtext_s = 'Order Unit'.
  ls_fieldcat-scrtext_m = 'Order Unit' .
  ls_fieldcat-scrtext_l = 'Order Unit'.
  APPEND ls_fieldcat TO ct_fieldcat.

*  CLEAR: ls_fieldcat.
*  ls_fieldcat-fieldname = 'NETPR' .
*  ls_fieldcat-datatype  = 'CURR' .
*  ls_fieldcat-outputlen = '11'.
*  ls_fieldcat-scrtext_s = 'Net Price'.
*  ls_fieldcat-scrtext_m = 'Net Price' .
*  ls_fieldcat-scrtext_l = 'Net Order Price'.
*  APPEND ls_fieldcat TO ct_fieldcat.


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
FORM display  CHANGING Ct_po_HEAD  TYPE tt_po_HEAD
                       Ct_fieldcat TYPE lvc_t_fcat
                       Cs_layout   TYPE lvc_s_layo
                       co_alv_table TYPE REF TO cl_gui_alv_grid.

  co_alv_table->set_table_for_first_display(
    EXPORTING
      is_layout                     = Cs_layout
    CHANGING
      it_outtab                     = Ct_po_HEAD
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

  DATA(lo_alv_item_handler) = NEW lcl_alv_handler( it_po_head = Ct_po_HEAD ).

  SET HANDLER lo_alv_item_handler->handle_dbclick FOR co_alv_table.

  CALL SCREEN 9000.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*& create_alv_object
*&---------------------------------------------------------------------*

FORM create_alv_object  CHANGING Co_alv_table.
  DATA(lo_container) = NEW cl_gui_custom_container(
    container_name = 'ALVHEAD'                " Name of the Screen CustCtrl Name to Link Container To
  ).
  Co_alv_table =  NEW cl_gui_alv_grid( i_parent = lo_container ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*& create_alv_object
*&---------------------------------------------------------------------*

FORM create_alv_object_ITEM  CHANGING Co_alv_table.
  DATA(lo_container) = NEW cl_gui_custom_container(
    container_name = 'ALVITEM'                " Name of the Screen CustCtrl Name to Link Container To
  ).
  Co_alv_table =  NEW cl_gui_alv_grid( i_parent = lo_container ).
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
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.

***-------------------
CLASS lcl_alv_handler IMPLEMENTATION.
  METHOD constructor.
    me->_t_po_head = it_po_head.
  ENDMETHOD.

  METHOD handle_dbclick.
    DATA: lt_fieldcat TYPE lvc_t_fcat, " FIELD CATALOG
          ls_layout   TYPE lvc_s_layo.

    READ TABLE me->_t_po_head INTO DATA(ls_po_head)
      INDEX es_row_no-row_id.

    IF sy-subrc = 0.
      PERFORM get_po_item USING ls_po_head-ebeln
                          CHANGING me->_t_po_item.

      IF me->_o_alv_table IS NOT BOUND.
        PERFORM create_alv_object_item CHANGING me->_o_alv_table.

        PERFORM prepare_alv_item CHANGING lt_fieldcat ls_layout.

        me->_o_alv_table->set_table_for_first_display(
          EXPORTING
            is_layout                     = ls_layout
          CHANGING
            it_outtab                     = me->_t_po_item
            it_fieldcatalog               = lt_fieldcat
          EXCEPTIONS
            invalid_parameter_combination = 1
            program_error                 = 2
            too_many_lines                = 3
            OTHERS                        = 4 ).

        IF sy-subrc <> 0.

          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ELSE.
        me->_o_alv_table->refresh_table_display(
          EXCEPTIONS
            finished = 1                " Display was Ended (by Export)
            OTHERS   = 2
        ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
