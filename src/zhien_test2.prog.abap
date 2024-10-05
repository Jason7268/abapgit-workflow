*&---------------------------------------------------------------------*
*& Report ZHIEN_TEST2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_test2.

TYPES: BEGIN OF ty_material,
         matnr TYPE matnr,
         maktx TYPE maktx,
       END OF ty_material,

       BEGIN OF ty_customer,
         kunnr TYPE kunnr,
         name1 TYPE name1_gp,
       END OF ty_customer,

       BEGIN OF ty_sorder_header,
         sales_order   TYPE vbeln_va,
         order_type    TYPE auart,
         sales_org     TYPE vkorg,
         distr_channel TYPE vtweg,
         division      TYPE spart,
         sold_to_party TYPE kunnr,
       END OF ty_sorder_header,

       BEGIN OF ty_sorder_item,
         sales_order TYPE vbeln_va,
         item_number TYPE posnr_va,
         material    TYPE matnr,
         quantity    TYPE kwmeng,
         unit        TYPE vrkme,
         net_value   TYPE netwr_ak,
       END OF ty_sorder_item,

       BEGIN OF ty_upload_data,
         sales_order   TYPE vbeln_va,
         order_type    TYPE auart,
         sales_org     TYPE vkorg,
         distr_channel TYPE vtweg,
         division      TYPE spart,
         sold_to_party TYPE kunnr,
         item_number   TYPE posnr_va,
         material      TYPE matnr,
         quantity      TYPE kwmeng,
         unit          TYPE vrkme,
         net_value     TYPE netwr_ak,
       END OF ty_upload_data,

       BEGIN OF ty_error,
         sales_order TYPE vbeln_va,
         item_number TYPE posnr_va,
         field_name  TYPE string,
         error_msg   TYPE string,
       END OF ty_error.

DATA: gt_upload_data TYPE TABLE OF ty_upload_data,
      gt_sorder_header TYPE TABLE OF ty_sorder_header,
      gt_sorder_item TYPE TABLE OF ty_sorder_item,
      gt_error TYPE TABLE OF ty_error,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout TYPE slis_layout_alv,
      gv_file_path TYPE string,
      gt_file_table TYPE filetable,
      gv_rc TYPE i.

" Global internal tables for master data
DATA: gt_material TYPE SORTED TABLE OF ty_material WITH UNIQUE KEY matnr,
      gt_customer TYPE SORTED TABLE OF ty_customer WITH UNIQUE KEY kunnr.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_file TYPE string LOWER CASE.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  PERFORM load_master_data.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Select File'
      default_extension       = 'CSV'
      file_filter             = 'CSV Files (*.csv)|*.csv|All Files (*.*)|*.*'
    CHANGING
      file_table              = gt_file_table
      rc                      = gv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc = 0 AND gv_rc = 1.
    READ TABLE gt_file_table INDEX 1 INTO gv_file_path.
    p_file = gv_file_path.
  ENDIF.

START-OF-SELECTION.
  PERFORM upload_file.
  PERFORM process_data.
  PERFORM display_results.


FORM load_master_data.
  " Load Material data
  SELECT DISTINCT a~matnr, b~maktx
    FROM mara as a INNER JOIN makt as b on a~matnr = b~matnr
    INTO TABLE @gt_material UP TO 50 ROWS.

  " Load Customer data
  SELECT kunnr, name1
    FROM kna1
    INTO TABLE @gt_customer UP TO 50 ROWS.
ENDFORM.

FORM upload_file.
  DATA: lt_data TYPE TABLE OF string,
        lv_headerline TYPE string.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = p_file
      filetype                = 'ASC'
    TABLES
      data_tab                = lt_data
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  IF sy-subrc <> 0.
    MESSAGE 'File upload failed' TYPE 'E'.
  ENDIF.

  " Remove header line
  READ TABLE lt_data INTO lv_headerline INDEX 1.
  DELETE lt_data INDEX 1.

  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lv_data>).
    SPLIT <lv_data> AT ',' INTO TABLE DATA(lt_fields).
    APPEND INITIAL LINE TO gt_upload_data ASSIGNING FIELD-SYMBOL(<ls_upload>).
    <ls_upload>-sales_order   = lt_fields[ 1 ].
    <ls_upload>-order_type    = lt_fields[ 2 ].
    <ls_upload>-sales_org     = lt_fields[ 3 ].
    <ls_upload>-distr_channel = lt_fields[ 4 ].
    <ls_upload>-division      = lt_fields[ 5 ].
    <ls_upload>-sold_to_party = lt_fields[ 6 ].
    <ls_upload>-item_number   = lt_fields[ 7 ].
    <ls_upload>-material      = lt_fields[ 8 ].
    <ls_upload>-quantity      = lt_fields[ 9 ].
    <ls_upload>-unit          = lt_fields[ 10 ].
    <ls_upload>-net_value     = lt_fields[ 11 ].
  ENDLOOP.
ENDFORM.

FORM process_data.
  DATA: ls_header TYPE ty_sorder_header,
        ls_item TYPE ty_sorder_item,
        ls_error TYPE ty_error.

  LOOP AT gt_upload_data ASSIGNING FIELD-SYMBOL(<ls_upload>).
    CLEAR: ls_header, ls_item, ls_error.

    " Process header data
    MOVE-CORRESPONDING <ls_upload> TO ls_header.

    " Validate header data
    PERFORM validate_header USING ls_header CHANGING ls_error.
    IF ls_error IS NOT INITIAL.
      APPEND ls_error TO gt_error.
      CONTINUE.
    ENDIF.

    COLLECT ls_header INTO gt_sorder_header.

    " Process item data
    MOVE-CORRESPONDING <ls_upload> TO ls_item.

    " Validate item data
    PERFORM validate_item USING ls_item CHANGING ls_error.
    IF ls_error IS NOT INITIAL.
      APPEND ls_error TO gt_error.
      CONTINUE.
    ENDIF.

    APPEND ls_item TO gt_sorder_item.
  ENDLOOP.

  " Sort the tables
  SORT gt_sorder_header BY sales_order.
  SORT gt_sorder_item BY sales_order item_number.
ENDFORM.


FORM validate_header USING ps_header TYPE ty_sorder_header
                     CHANGING ps_error TYPE ty_error.
  ps_error-sales_order = ps_header-sales_order.

  " Check if customer exists
  READ TABLE gt_customer WITH KEY kunnr = ps_header-sold_to_party TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    ps_error-field_name = 'SOLD_TO_PARTY'.
    ps_error-error_msg = 'Customer does not exist'.
  ENDIF.

  " Add more header validations as needed
ENDFORM.

FORM validate_item USING ps_item TYPE ty_sorder_item
                   CHANGING ps_error TYPE ty_error.
  ps_error-sales_order = ps_item-sales_order.
  ps_error-item_number = ps_item-item_number.

  " Check if material exists
  READ TABLE gt_material WITH KEY matnr = ps_item-material TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    ps_error-field_name = 'MATERIAL'.
    ps_error-error_msg = 'Material does not exist'.
  ENDIF.

  " Check quantity
  IF ps_item-quantity <= 0.
    ps_error-field_name = 'QUANTITY'.
    ps_error-error_msg = 'Quantity must be greater than zero'.
  ENDIF.

  " Add more item validations as needed
ENDFORM.

FORM display_results.
  " Display error data if any
  IF gt_error IS NOT INITIAL.
    PERFORM build_error_fieldcat.
    PERFORM build_layout.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        is_layout          = gs_layout
        it_fieldcat        = gt_fieldcat
        i_save             = 'A'
        i_default          = 'X'
      TABLES
        t_outtab           = gt_error
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    " Display header data
    PERFORM build_header_fieldcat.
    PERFORM build_layout.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        is_layout          = gs_layout
        it_fieldcat        = gt_fieldcat
        i_save             = 'A'
        i_default          = 'X'
      TABLES
        t_outtab           = gt_sorder_header
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    " Display item data
    PERFORM build_item_fieldcat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        is_layout          = gs_layout
        it_fieldcat        = gt_fieldcat
        i_save             = 'A'
        i_default          = 'X'
      TABLES
        t_outtab           = gt_sorder_item
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.





FORM build_error_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = 'TY_ERROR'
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

FORM build_header_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = 'TY_SORDER_HEADER'
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

FORM build_item_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = 'TY_SORDER_ITEM'
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

FORM build_layout.
  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.
ENDFORM.





























** test export excel
*&
*this report demonstrates how to send some ABAP data to an
*
*EXCEL sheet using OLE automation.

INCLUDE ole2incl.

*handles for OLE objects

DATA: h_excel TYPE ole2_object, " Excel object

      h_mapl  TYPE ole2_object, " list of workbooks

      h_map   TYPE ole2_object, " workbook

      h_zl    TYPE ole2_object, " cell

      h_f     TYPE ole2_object. " font

TABLES: spfli.

DATA h TYPE i.

*table of flights

data: it_spfli like spfli occurs 10 with header line.

*&----
*
**& Event START-OF-SELECTION
*
*&----

START-OF-SELECTION.

*read flights

  SELECT * FROM spfli INTO TABLE it_spfli UP TO 10 ROWS.

*display header

  ULINE (61).

  WRITE: / sy-vline NO-GAP,

  (3) 'Flg'(001) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP,

  (4) 'Nr'(002) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP,

  (20) 'Von'(003) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP,

  (20) 'Nach'(004) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP,

  (8) 'Zeit'(005) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP.

  ULINE /(61).

*display flights

  LOOP AT it_spfli.

    WRITE: / sy-vline NO-GAP,

    it_spfli-carrid COLOR COL_KEY NO-GAP, sy-vline NO-GAP,

    it_spfli-connid COLOR COL_NORMAL NO-GAP, sy-vline NO-GAP,

    it_spfli-cityfrom COLOR COL_NORMAL NO-GAP, sy-vline NO-GAP,

    it_spfli-cityto COLOR COL_NORMAL NO-GAP, sy-vline NO-GAP,

    it_spfli-deptime COLOR COL_NORMAL NO-GAP, sy-vline NO-GAP.

  ENDLOOP.

  ULINE /(61).

*tell user what is going on

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = TEXT-007
    EXCEPTIONS
      OTHERS     = 1.

*start Excel

  CREATE OBJECT h_excel 'EXCEL.APPLICATION'.

  PERFORM err_hdl.

  SET PROPERTY OF h_excel 'Visible' = 1.

  CALL METHOD OF h_excel 'FILESAVEAS'
    EXPORTING
      #1 = 'c:\kis_excel.xls'.

  PERFORM err_hdl.

*tell user what is going on

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = TEXT-008
    EXCEPTIONS
      OTHERS     = 1.
*
*get list of workbooks, initially empty

  CALL METHOD OF h_excel 'Workbooks' = h_mapl.

  PERFORM err_hdl.

*add a new workbook

  CALL METHOD OF h_mapl 'Add' = h_map.

  PERFORM err_hdl.

*tell user what is going on

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = TEXT-009
    EXCEPTIONS
      OTHERS     = 1.

*output column headings to active Excel sheet

  PERFORM fill_cell USING 1 1 1 'Flug'(001).

  PERFORM fill_cell USING 1 2 0 'Nr'(002).

  PERFORM fill_cell USING 1 3 1 'Von'(003).

  PERFORM fill_cell USING 1 4 1 'Nach'(004).

  PERFORM fill_cell USING 1 5 1 'Zeit'(005).

  LOOP AT it_spfli.

*copy flights to active EXCEL sheet

    h = sy-tabix + 1.

    PERFORM fill_cell USING h 1 0 it_spfli-carrid.

    PERFORM fill_cell USING h 2 0 it_spfli-connid.

    PERFORM fill_cell USING h 3 0 it_spfli-cityfrom.

    PERFORM fill_cell USING h 4 0 it_spfli-cityto.

    PERFORM fill_cell USING h 5 0 it_spfli-deptime.

  ENDLOOP.

*changes by Kishore - start

  CALL METHOD OF h_excel 'Workbooks' = h_mapl.

  CALL METHOD OF h_excel 'Worksheets' = h_mapl." EXPORTING #1 = 2.

  PERFORM err_hdl.

*add a new workbook

  CALL METHOD OF h_mapl 'Add' = h_map EXPORTING #1 = 2.

  PERFORM err_hdl.

*tell user what is going on

  SET PROPERTY OF h_map 'NAME' = 'COPY'.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = TEXT-009
    EXCEPTIONS
      OTHERS     = 1.

*output column headings to active Excel sheet

  PERFORM fill_cell USING 1 1 1 'Flug'(001).

  PERFORM fill_cell USING 1 2 0 'Nr'(002).

  PERFORM fill_cell USING 1 3 1 'Von'(003).

  PERFORM fill_cell USING 1 4 1 'Nach'(004).

  PERFORM fill_cell USING 1 5 1 'Zeit'(005).

  LOOP AT it_spfli.

*copy flights to active EXCEL sheet

    h = sy-tabix + 1.

    PERFORM fill_cell USING h 1 0 it_spfli-carrid.

    PERFORM fill_cell USING h 2 0 it_spfli-connid.

    PERFORM fill_cell USING h 3 0 it_spfli-cityfrom.

    PERFORM fill_cell USING h 4 0 it_spfli-cityto.

    PERFORM fill_cell USING h 5 0 it_spfli-deptime.

  ENDLOOP.
*
*changes by Kishore - end
*
*disconnect from Excel

  CALL METHOD OF h_excel 'FILESAVEAS' EXPORTING #1 = 'C:\SKV.XLS'.

  FREE OBJECT h_excel.

  PERFORM err_hdl.

*  ----

*  FORM fill_cell *
*
*  ----

*sets cell at coordinates i,j to value val boldtype bold *

*  ----

  FORM fill_cell USING I j bold val.

  CALL METHOD OF h_excel 'Cells' = h_zl EXPORTING #1 = I #2 = j.

  PERFORM err_hdl.

  SET PROPERTY OF h_zl 'Value' = val .

  PERFORM err_hdl.

  GET PROPERTY OF h_zl 'Font' = h_f.

  PERFORM err_hdl.

  SET PROPERTY OF h_f 'Bold' = bold .

  PERFORM err_hdl.

ENDFORM.

*&----

*& Form ERR_HDL

*&----
*
*outputs OLE error if any *
*
*----
*
*--> p1 text
*
*<-- p2 text
*
*----

FORM err_hdl.

  IF sy-subrc <> 0.

    WRITE: / 'Fehler bei OLE-Automation:'(010), sy-subrc.

    STOP.

  ENDIF.

ENDFORM. " ERR_HDL
