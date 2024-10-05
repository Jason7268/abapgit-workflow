*&---------------------------------------------------------------------*
*& Include          ZHIEN_GETORDERF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form MAIN_PROCESS
*&---------------------------------------------------------------------*
*& main process
*&---------------------------------------------------------------------*

FORM main_process USING u_r_aufnr TYPE ty_r_aufnr.

  DEFINE ole_check_error.
    IF &1 NE 0.
      MESSAGE e000 WITH &1.
      EXIT.
    ENDIF.
  END-OF-DEFINITION.


* DecLare Flight schedule internal table
  DATA: lt_orderhead TYPE ty_t_orderhead.

* Declare ORDER ITEM internal table
  DATA: lt_orderitem TYPE ty_t_orderitem.

* Declare ORRDER QUANTITY internal table
  DATA: lt_orderquan TYPE ty_t_orderquan.

* Declare WORK CENTER internal table
  DATA: lt_workcenter TYPE ty_t_workcenter.

* Get data header
  PERFORM getdata_header  USING u_r_aufnr
                          CHANGING lt_orderhead.

* Get data item
  PERFORM getdata_item  USING u_r_aufnr
                        CHANGING lt_orderitem.
  SORT lt_orderitem BY aufnr ASCENDING vornr ASCENDING.
   DATA(lt_temp)  = lt_orderitem.

   SORT lt_temp by aufpl
                   aplzl.
   delete ADJACENT DUPLICATES FROM lt_temp COMPARING aufpl aplzl.

*   GET ORDER QUANTITY
  PERFORM get_orderquan USING lt_temp
                        CHANGING lt_orderquan.
*   GET WORK CENTER

    lt_temp  = lt_orderitem.

   SORT lt_temp by arbid .
   delete ADJACENT DUPLICATES FROM lt_temp COMPARING arbid.

  PERFORM get_workcenter  USING lt_temp
                          CHANGING lt_workcenter.
  refresh lt_temp.
* Update quantity , workcenter and operation for item internal table
  PERFORM update_item  USING lt_orderquan lt_workcenter
                      CHANGING lt_orderitem.
*    EXPORT FILE EXCEL TO 2 SHEETS
  PERFORM export_excel USING lt_orderhead lt_orderitem.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GETDATA_HEADER
*&---------------------------------------------------------------------*
*& Get data header
*&---------------------------------------------------------------------*
*&      <-- LT_ORDERHEAD
*&---------------------------------------------------------------------*
FORM getdata_header USING u_r_aufnr TYPE ty_r_aufnr
                    CHANGING c_t_orderhead TYPE ty_t_orderhead.

  SELECT aufnr,
         matnr,
         psmng,
         wemng
    FROM afpo
    WHERE aufnr IN @so_aufnr
    INTO TABLE @c_t_orderhead.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GETDATA_ITEM
*&---------------------------------------------------------------------*
*& GETDATA ITEM
*&---------------------------------------------------------------------*
*&      <-- LT_ORDERITEM
*&---------------------------------------------------------------------*
FORM getdata_item USING u_r_aufnr TYPE ty_r_aufnr
                   CHANGING c_t_orderitem TYPE ty_t_orderitem.

*   Get data from afko and afvc
  SELECT p~aufnr,
         p~aufpl,
         v~vornr,
         v~aplzl,
         v~arbid,
         v~ltxa1
  FROM afko AS p
    INNER JOIN afvc AS v
      ON p~aufpl = v~aufpl
  WHERE p~aufnr IN @so_aufnr
  INTO CORRESPONDING FIELDS OF TABLE @c_t_orderitem.

  IF sy-suBrc = 0.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ORDERQUAN
*&---------------------------------------------------------------------*
*& GET ORDER QUANTITY
*&---------------------------------------------------------------------*
*&      --> U_R_AUFNR
*&      <-- LT_ORDERQUAN
*&---------------------------------------------------------------------*
FORM get_orderquan  USING u_t_orderitem TYPE ty_t_orderitem
                    CHANGING c_t_orderquan TYPE ty_t_orderquan.
  CHECK u_t_orderitem  IS NOT INITIAL.
  SELECT aufpl,
         aplzl,
         bmsch,
         vgw01,
         vgw02,
         vgw03
    FROM afvv INTO TABLE @c_t_orderquan
    FOR ALL ENTRIES IN @u_t_orderitem
    WHERE aufpl = @u_t_orderitem-aufpl
      AND aplzl = @u_t_orderitem-aplzl .
  IF sy-subrc = 0.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_WORKCENTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> U_R_AUFNR
*&      <-- LT_ORDERQUAN
*&---------------------------------------------------------------------*
FORM get_workcenter  USING   u_t_orderitem TYPE ty_t_orderitem
                     CHANGING c_t_WORKCENTER TYPE ty_t_workcenter.
  CHECK u_t_orderitem  IS NOT INITIAL.
  SELECT objid,
         arbpl
    FROM crhd INTO TABLE @c_t_WORKCENTER
    FOR ALL ENTRIES IN @u_t_orderitem
    WHERE objid = @u_t_orderitem-arbid.

  IF sy-subrc = 0.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ITEM
*&---------------------------------------------------------------------*
*& Update quantity , workcenter and operation for item interna; table
*&---------------------------------------------------------------------*
*&      --> LT_ORDERQUAN
*&      --> LT_WORKCENTER
*&      <-- LT_ORDERITEM
*&---------------------------------------------------------------------*
FORM update_item  USING    c_t_orderquan TYPE ty_t_orderquan
                           c_t_workcenter TYPE ty_t_workcenter
                  CHANGING c_t_orderitem TYPE ty_t_orderitem.

  LOOP AT c_t_orderitem ASSIGNING FIELD-SYMBOL(<lfs_orderitem>).

*  *   Get and set quantiy
    READ TABLE c_t_orderquan INTO DATA(ls_orderquan)
    WITH TABLE KEY aufpl = <lfs_orderitem>-aufpl
                   aplzl = <lfs_orderitem>-aplzl.

    IF sy-subrc = 0. " Success
      <lfs_orderitem>-bmsch = ls_orderquan-bmsch.
      <lfs_orderitem>-vgw01 = ls_orderquan-vgw01.
      <lfs_orderitem>-vgw02 = ls_orderquan-vgw02.
      <lfs_orderitem>-vgw03 = ls_orderquan-vgw03.
    ENDIF.
**    Get work center
    READ TABLE c_t_workcenter INTO DATA(ls_workcenter)
    WITH TABLE KEY objid = <lfs_orderitem>-arbid.
    IF sy-subrc = 0. " Success
      <lfs_orderitem>-arbpl = ls_workcenter-arbpl.
    ENDIF.
  ENDLOOP.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form EXPORT_EXCEL
*&---------------------------------------------------------------------*
*& EXPORT DATA TO EXCEL
*&---------------------------------------------------------------------*
*&      --> LT_ORDERHEAD
*&      --> LT_ORDERITEM
*&---------------------------------------------------------------------*
FORM export_excel  USING    u_t_orderhead TYPE ty_t_orderhead
                            u_t_orderitem TYPE ty_t_orderitem.

  PERFORM set_excel_headers.
  PERFORM set_excel_items USING u_t_orderhead u_t_orderitem.
  PERFORM start_excel.
  PERFORM set_first_sheet.
  PERFORM set_second_sheet.
  PERFORM save_excel USING h_excel h_map.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_excel_headers
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_excel_headers .
*  * Excel Tab
  deli = cl_abap_char_utilities=>horizontal_tab.
* Setting Header
  CONCATENATE 'Order' 'Material' 'Target Qty' 'Del. Qty'
         INTO gt_1 SEPARATED BY deli .
  APPEND gt_1.       CLEAR gt_1.
  CONCATENATE 'Order' 'Op.' 'Work Center' 'Op. Short Text' 'Base Qty' 'Setup' 'Machine' 'Labor'
         INTO gt_2 SEPARATED BY deli.
  INSERT gt_2 INDEX 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_excel_items
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_excel_items USING    u_t_orderhead TYPE ty_t_orderhead
                              u_t_orderitem TYPE ty_t_orderitem..

  DATA: lv_val1 TYPE string,
        lv_val2 TYPE string,
        lv_val3 TYPE string,
        lv_val4 TYPE string.

  LOOP AT u_t_orderhead INTO DATA(ls_orderhead).
    CLEAR: lv_val1, lv_val2, lv_val3.
    lv_val2 = ls_orderhead-psmng.
    lv_val3 = ls_orderhead-wemng.
    CONCATENATE ls_orderhead-aufnr
                ls_orderhead-matnr lv_val2
                lv_val3
    INTO  gt_1   SEPARATED BY deli.
    APPEND gt_1.      CLEAR gt_1.
  ENDLOOP.


  LOOP AT u_t_orderitem INTO DATA(ls_orderitem).
    CLEAR: lv_val1, lv_val2, lv_val3,lv_val4.
    lv_val1 = ls_orderitem-bmsch.
    lv_val2 = ls_orderitem-vgw01.
    lv_val3 = ls_orderitem-vgw02.
    lv_val4 = ls_orderitem-vgw03.
    CONCATENATE ls_orderitem-aufnr
                ls_orderitem-vornr
                ls_orderitem-arbpl
                ls_orderitem-ltxa1
                lv_val1 lv_val2 lv_val3 lv_val4
    INTO   gt_2 SEPARATED BY deli.
    APPEND gt_2.       CLEAR gt_2.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_excel
*&---------------------------------------------------------------------*
*& text

*&---------------------------------------------------------------------*
FORM start_excel .
  IF h_excel-header = space OR h_excel-handle = -1.
    CREATE OBJECT h_excel 'EXCEL.APPLICATION'.
  ENDIF.
  CALL METHOD OF h_excel 'Workbooks' = h_mapl.
  SET PROPERTY OF h_excel 'Visible'   = 0.
  CALL METHOD OF h_mapl 'Add' = h_map.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_first_sheet
*&---------------------------------------------------------------------*
*& text

*&---------------------------------------------------------------------*
FORM set_first_sheet .

  gv_sheet_name = 'Order Header'.
  CALL METHOD OF h_excel 'Cells' = w_cell1
    EXPORTING #1 = 1 #2 = 1.
  CALL METHOD OF h_excel 'Cells' = w_cell2
    EXPORTING #1 = 1 #2 = 5.
  CALL METHOD OF h_excel 'Range' = range
    EXPORTING #1 = w_cell1 #2 = w_cell2.
  SET PROPERTY OF range 'WRAPTEXT' = 1.
  GET PROPERTY OF range 'FONT'     = font.
  SET PROPERTY OF font  'BOLD'     = 1.
  GET PROPERTY OF h_excel   'ACTIVESHEET' = worksheet.
  SET PROPERTY OF worksheet 'Name'        = gv_sheet_name .
  DATA: lo_interior TYPE ole2_object.
  CALL METHOD OF range 'Interior' = lo_interior.
  SET PROPERTY OF lo_interior 'Color' = 2552550.
*  PERFORM add_border USING 1 1 550 5.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_second_sheet
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_second_sheet .
  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data                 = gt_2[]
    CHANGING
      rc                   = l_rc
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  CALL METHOD OF h_excel 'Cells' = w_cell1
     EXPORTING #1 = 1 #2 = 1.
  CALL METHOD OF h_excel 'Cells' = w_cell2
     EXPORTING #1 = 1 #2 = 1.
  CALL METHOD OF h_excel 'Range' = range
     EXPORTING #1 = w_cell1 #2 = w_cell2.
  CALL METHOD OF range 'Select'.
  CALL METHOD OF worksheet 'Paste'.
  PERFORM create_sheet TABLES gt_1
                        USING 'Order Item' h_sheet2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form open_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_excel USING iv_excel TYPE ole2_object
                      iv_workbook TYPE ole2_object.

  DATA: l_filename     TYPE string,
        l_path         TYPE string,
        l_fullpath     TYPE string,
        l_user_action  TYPE i.

  " Get the active worksheet
  GET PROPERTY OF iv_excel 'ACTIVESHEET' = worksheet.

  " Set default filename
  l_filename = 'dataexport.xlsx'.

  " Open file dialog for saving
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title         = 'Save Excel File'
      default_extension    = 'xlsx'
      default_file_name    = l_filename
      file_filter          = '*.xlsx'
    CHANGING
      filename             = l_filename
      path                 = l_path
      fullpath             = l_fullpath
      user_action          = l_user_action
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  IF sy-subrc <> 0.
    MESSAGE 'Error opening file dialog' TYPE 'E'.
    RETURN.
  ENDIF.

  " Check user action for cancellation
  IF l_user_action = cl_gui_frontend_services=>action_cancel.
    MESSAGE 'File save cancelled by user' TYPE 'S'.
    RETURN.
  ENDIF.

  " Save the workbook
  CALL METHOD OF iv_workbook 'SaveAs'
    EXPORTING
      #1 = l_fullpath.

  " Close the workbook
  CALL METHOD OF iv_workbook 'Close'.

  " Quit the Excel application
  PERFORM close_excel USING iv_excel.

  " Inform the user
  MESSAGE 'Excel file saved successfully' TYPE 'S'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form close_excel
*&---------------------------------------------------------------------*
*& This subroutine will quit and close the Excel application
*&---------------------------------------------------------------------*
FORM close_excel USING iv_excel TYPE ole2_object.

  " Quit Excel and free the Excel object
  IF iv_excel IS NOT INITIAL.
    CALL METHOD OF iv_excel 'Quit'.
    FREE OBJECT iv_excel.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_sheet
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_1
*&      --> P_
*&      --> H_SHEET2
*&---------------------------------------------------------------------*
FORM create_sheet  TABLES   it_sheet TYPE ty_data
                   USING    iv_name
                            iv_sheet TYPE ole2_object.


  DATA l_rc TYPE i.
  gv_sheet_name = iv_name.
  GET PROPERTY OF h_excel 'Sheets' = iv_sheet .
  CALL METHOD OF iv_sheet 'Add' = h_map.
  SET PROPERTY OF h_map 'Name' = gv_sheet_name .
  GET PROPERTY OF h_excel 'ACTIVESHEET' = worksheet.
  CALL METHOD OF h_excel 'Cells' = w_cell1
    EXPORTING #1 = 1 #2 = 1.
  CALL METHOD OF h_excel 'Cells' = w_cell2
    EXPORTING #1 = 1 #2 = 4.
  CALL METHOD OF h_excel 'Range' = range
    EXPORTING #1 = w_cell1 #2 = w_cell2.
  SET PROPERTY OF range 'WrapText' = 1.
  GET PROPERTY OF range 'Font' = font.
  SET PROPERTY OF font 'Bold' = 1.
  DATA: lo_interior TYPE ole2_object.
  CALL METHOD OF range 'Interior' = lo_interior.
  SET PROPERTY OF lo_interior 'Color' = 2552550.
*  PERFORM add_border USING 1 1 250 4.
  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data                 = it_sheet[]
    CHANGING
      rc                   = l_rc
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  CALL METHOD OF h_excel 'Cells' = w_cell1
    EXPORTING #1 = 1 #2 = 1.
  CALL METHOD OF h_excel 'Cells' = w_cell2
    EXPORTING #1 = 1 #2 = 1.
  CALL METHOD OF h_excel 'Range' = range
    EXPORTING #1 = w_cell1 #2 = w_cell2.
  CALL METHOD OF range 'Select'.
  CALL METHOD OF worksheet 'Paste'.


ENDFORM.



*&---------------------------------------------------------------------*
*& Form sh_aufnr
*&---------------------------------------------------------------------*
*& search help
*&---------------------------------------------------------------------*
FORM sh_aufnr .
  SELECT aufnr FROM afko INTO TABLE @DATA(lt_aufnr) UP TO 50 ROWS.
  IF sy-subrc NE 0.
*   do somthing
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'AUFNR'
      value_org       = 'S'
    TABLES
      value_tab       = lt_aufnr
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_INPUTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_inputs .
  CASE sy-ucomm .
    WHEN 'ONLI'.
      PERFORM check_required_fields USING so_aufnr TEXT-t01.
    WHEN OTHERS.
  ENDCASE.

*   PERFORM CHECK_REQUIRED_FIELDS USING SO_AUFNR TEXT-T01.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_REQUIRED_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SO_AUFNR
*&      --> TEXT_T01
*&---------------------------------------------------------------------*
FORM check_required_fields  USING    u_value TYPE any
                                     u_field_name TYPE string.
  IF u_value IS INITIAL.
    MESSAGE | Vui lòng nhập dữ liệu vào trường { u_field_name }.| TYPE 'W'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Subroutine: EXPORT_EXCEL
*&---------------------------------------------------------------------*
*& Export data to Excel with two sheets
*&---------------------------------------------------------------------*
*FORM export_to_excel USING lt_orderhead TYPE ty_t_orderhead
*                           lt_orderitem TYPE ty_t_orderitem.
*
*  DATA: lo_excel    TYPE  ole2_object,
*        lo_workbook TYPE  ole2_object,
*        lo_sheet1   TYPE  ole2_object,
*        lo_sheet2   TYPE  ole2_object,
*        lt_sheet1   TYPE string_table, " New variable declaration
*        lt_sheet2   TYPE string_table, " New variable declaration
*        lv_filename TYPE string,
*        lv_path     TYPE string,
*        lv_fullpath TYPE string,
*        lv_rc       TYPE i.
*
*  " Create Excel object
*  CREATE OBJECT lo_excel 'EXCEL.APPLICATION'.
*  CALL METHOD OF lo_excel 'Workbooks' = lo_workbook.
*  SET PROPERTY OF lo_excel 'Visible' = 0.
*
*  " Create first sheet (OrderHeader)
*  CALL METHOD OF lo_excel 'Sheets' = lo_sheet1.
*  CALL METHOD OF lo_sheet1 'Add' = lo_workbook.
*  SET PROPERTY OF lo_sheet1 'Name' = 'OrderHeader'.
*
*  " Prepare and write OrderHeader data
*  PERFORM prepare_orderheader_data USING lt_orderhead lt_sheet1.
*  PERFORM write_to_sheet USING lo_sheet1 lt_sheet1.
*
*  " Create second sheet (OrderItem)
*  CALL METHOD OF lo_excel 'Sheets' = lo_sheet2.
*  CALL METHOD OF lo_sheet2 'Add' = lo_workbook.
*  SET PROPERTY OF lo_sheet2 'Name' = 'OrderItem'.
*
*  " Prepare and write OrderItem data
*  PERFORM prepare_orderitem_data USING lt_orderitem lt_sheet2.
*  PERFORM write_to_sheet USING lo_sheet2 lt_sheet2.
*
*  " Save Excel file
*  PERFORM save_excel USING lo_excel lo_workbook.
**  CALL METHOD cl_gui_frontend_services=>file_save_dialog
**    EXPORTING
**      window_title         = 'Save Excel File'
**      default_extension    = 'xlsx'
**      default_file_name    = 'dataexport.xlsx'
**      file_filter          = '*.xlsx'
**    CHANGING
**      filename             = lv_filename
**      path                 = lv_path
**      fullpath             = lv_fullpath
**      user_action          = lv_rc
**    EXCEPTIONS
**      cntl_error           = 1
**      error_no_gui         = 2
**      not_supported_by_gui = 3
**      OTHERS               = 4.
**  IF sy-subrc <> 0.
**    MESSAGE 'Error opening file dialog' TYPE 'E'.
**    RETURN.
**  ENDIF.
**
**  IF lv_rc = cl_gui_frontend_services=>action_cancel.
**    MESSAGE 'File save cancelled by user' TYPE 'S'.
**    RETURN.
**  ENDIF.
**
**  CALL METHOD OF lo_workbook 'SaveAs'
**    EXPORTING
**      #1 = lv_fullpath.
**  CALL METHOD OF lo_workbook 'Close'.
**  CALL METHOD OF lo_excel 'Quit'.
**
**  MESSAGE 'Excel file exported successfully' TYPE 'S'.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form prepare_orderheader_data
**&---------------------------------------------------------------------*
*FORM prepare_orderheader_data USING lt_orderhead TYPE ty_t_orderhead
*                                   rt_data      TYPE string_table.
*    DATA: lv_val1 TYPE string,
*        lv_val2 TYPE string.
*  APPEND 'Order,Material,Target Qty,Del. Qty' TO rt_data.
*
*  LOOP AT lt_orderhead ASSIGNING FIELD-SYMBOL(<orderhead>).
*     CLEAR: lv_val1, lv_val2.
*    lv_val1 = <orderhead>-psmng.
*    lv_val2 = <orderhead>-wemng.
*
*    CONCATENATE <orderhead>-aufnr <orderhead>-matnr lv_val1 lv_val2
*           INTO DATA(lv_row) SEPARATED BY ','.
*    APPEND lv_row TO rt_data.
*  ENDLOOP.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form prepare_orderitem_data
**&---------------------------------------------------------------------*
*FORM prepare_orderitem_data USING lt_orderitem TYPE ty_t_orderitem
*                                  rt_data      TYPE string_table.
*      DATA: lv_val1 TYPE string,
*        lv_val2 TYPE string,
*        lv_val3 TYPE string,
*        lv_val4 TYPE string.
*  APPEND 'Order,Op.,Work Center,Op. Short Text,Base Qty,Setup,Machine,Labor' TO rt_data.
*
*  LOOP AT lt_orderitem ASSIGNING FIELD-SYMBOL(<orderitem>).
*    CLEAR: lv_val1, lv_val2, lv_val3,lv_val4.
*    lv_val1 = <orderitem>-bmsch.
*    lv_val2 = <orderitem>-vgw01.
*    lv_val3 = <orderitem>-vgw02.
*    lv_val4 = <orderitem>-vgw03.
*    CONCATENATE <orderitem>-aufnr <orderitem>-vornr <orderitem>-arbpl <orderitem>-ltxa1
*           lv_val1 lv_val2 lv_val3 lv_val4
*           INTO DATA(lv_row) SEPARATED BY ','.
*    APPEND lv_row TO rt_data.
*  ENDLOOP.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form write_to_sheet
**&---------------------------------------------------------------------*
*FORM write_to_sheet USING io_sheet TYPE ole2_object
*                          it_data  TYPE string_table.
*
*  DATA: lo_range TYPE  ole2_object,
*        lo_cell  TYPE  ole2_object,
*        lv_row   TYPE string.
*
*  CALL METHOD OF io_sheet 'Cells' = lo_cell
*    EXPORTING #1 = 1 #2 = 1.
*  CALL METHOD OF io_sheet 'Range' = lo_range
*    EXPORTING #1 = lo_cell.
*
*  LOOP AT it_data INTO lv_row.
*    CALL METHOD OF lo_range 'Value' = lv_row.
*    CALL METHOD OF lo_range 'Offset' = lo_range
*      EXPORTING #1 = 1 #2 = 1.
*  ENDLOOP.
*
*ENDFORM.
*
*FORM save_excel USING iv_excel TYPE ole2_object
*                        iv_workbook TYPE ole2_object.
*
*  DATA: l_filename     TYPE string,
*        l_path         TYPE string,
*        l_fullpath     TYPE string,
*        l_user_action  TYPE i.
*
*  " Get the active worksheet
*  GET PROPERTY OF iv_excel 'ACTIVESHEET' = worksheet.
*
*  " Set default filename
*  l_filename = 'dataexport.xlsx'.
*
*  " Open file dialog for saving
*  CALL METHOD cl_gui_frontend_services=>file_save_dialog
*    EXPORTING
*      window_title         = 'Save Excel File'
*      default_extension    = 'xlsx'
*      default_file_name    = l_filename
*      file_filter          = '*.xlsx'
*    CHANGING
*      filename             = l_filename
*      path                 = l_path
*      fullpath             = l_fullpath
*      user_action          = l_user_action
*    EXCEPTIONS
*      cntl_error           = 1
*      error_no_gui         = 2
*      not_supported_by_gui = 3
*      OTHERS               = 4.
*
*  IF sy-subrc <> 0.
*    MESSAGE 'Error opening file dialog' TYPE 'E'.
*    RETURN.
*  ENDIF.
*
*  " Check user action for cancellation
*  IF l_user_action = cl_gui_frontend_services=>action_cancel.
*    MESSAGE 'File save cancelled by user' TYPE 'S'.
*    RETURN.
*  ENDIF.
*
*  " Save the workbook
*  CALL METHOD OF iv_workbook 'SaveAs'
*    EXPORTING
*      #1 = l_fullpath.
*
*  " Close the workbook
*  CALL METHOD OF iv_workbook 'Close'.
*
*  " Quit the Excel application
*  PERFORM close_excel USING iv_excel.
*
*  " Inform the user
*  MESSAGE 'Excel file saved successfully' TYPE 'S'.
*
*ENDFORM.

*
*FORM export_to_excel USING lt_orderhead TYPE ty_t_orderhead
*                           lt_orderitem TYPE ty_t_orderitem.
*
*  DATA: lo_excel    TYPE ole2_object,
*        lo_workbook TYPE ole2_object,
*        lo_sheet1   TYPE ole2_object,
*        lo_sheet2   TYPE ole2_object,
*        lt_sheet1   TYPE string_table,
*        lt_sheet2   TYPE string_table,
*        lv_filename TYPE string,
*        lv_path     TYPE string,
*        lv_fullpath TYPE string,
*        lv_rc       TYPE i.
*
*  " Create Excel object
*  CREATE OBJECT lo_excel 'Excel.Application'.
*  SET PROPERTY OF lo_excel 'Visible' = 0.
*
*  " Create new workbook
*  CALL METHOD OF lo_excel 'Workbooks' = lo_workbook.
*  CALL METHOD OF lo_workbook 'Add'.
*
*  " Get first sheet (OrderHeader)
*CALL METHOD OF lo_excel 'Worksheets' = lo_sheet1
*  EXPORTING #1 = 1.
*SET PROPERTY OF lo_sheet1 'Name' = 'OrderHeader'.
*
*" Prepare and write OrderHeader data
*PERFORM prepare_orderheader_data USING lt_orderhead CHANGING lt_sheet1.
*PERFORM write_to_sheet USING lo_sheet1 lt_sheet1.
*
*" Add second sheet (OrderItem)
*CALL METHOD OF lo_workbook 'Worksheets' 'Add' RECEIVING value = lo_sheet2.
*SET PROPERTY OF lo_sheet2 'Name' = 'OrderItem'.
*
*" Prepare and write OrderItem data
*PERFORM prepare_orderitem_data USING lt_orderitem CHANGING lt_sheet2.
*PERFORM write_to_sheet USING lo_sheet2 lt_sheet2.
*
*  " Save Excel file
*  CALL METHOD cl_gui_frontend_services=>file_save_dialog
*    EXPORTING
*      window_title         = 'Save Excel File'
*      default_extension    = 'xlsx'
*      default_file_name    = 'dataexport.xlsx'
*      file_filter          = '*.xlsx'
*    CHANGING
*      filename             = lv_filename
*      path                 = lv_path
*      fullpath             = lv_fullpath
*      user_action          = lv_rc
*    EXCEPTIONS
*      cntl_error           = 1
*      error_no_gui         = 2
*      not_supported_by_gui = 3
*      OTHERS               = 4.
*
*  IF sy-subrc <> 0.
*    MESSAGE 'Error opening file dialog' TYPE 'E'.
*    RETURN.
*  ENDIF.
*
*  IF lv_rc = cl_gui_frontend_services=>action_cancel.
*    MESSAGE 'File save cancelled by user' TYPE 'S'.
*    RETURN.
*  ENDIF.
*
*  " Save and close the workbook
*  CALL METHOD OF lo_workbook 'SaveAs'
*    EXPORTING #1 = lv_fullpath.
*  CALL METHOD OF lo_workbook 'Close'.
*
*  " Quit Excel
*  CALL METHOD OF lo_excel 'Quit'.
*
*  " Free objects
*  FREE OBJECT: lo_sheet2, lo_sheet1, lo_workbook, lo_excel.
*
*  MESSAGE 'Excel file exported successfully' TYPE 'S'.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form prepare_orderheader_data
**&---------------------------------------------------------------------*
*FORM prepare_orderheader_data USING lt_orderhead TYPE ty_t_orderhead
*                              CHANGING ct_data TYPE string_table.
*
*  APPEND 'Order,Material,Target Qty,Del. Qty' TO ct_data.
*
*  LOOP AT lt_orderhead ASSIGNING FIELD-SYMBOL(<orderhead>).
*    DATA(lv_row) = |{ <orderhead>-aufnr },{ <orderhead>-matnr },{ <orderhead>-psmng },{ <orderhead>-wemng }|.
*    APPEND lv_row TO ct_data.
*  ENDLOOP.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form prepare_orderitem_data
**&---------------------------------------------------------------------*
*FORM prepare_orderitem_data USING lt_orderitem TYPE ty_t_orderitem
*                            CHANGING ct_data TYPE string_table.
*
*  APPEND 'Order,Op.,Work Center,Op. Short Text,Base Qty,Setup,Machine,Labor' TO ct_data.
*
*  LOOP AT lt_orderitem ASSIGNING FIELD-SYMBOL(<orderitem>).
*    DATA(lv_row) = |{ <orderitem>-aufnr },{ <orderitem>-vornr },{ <orderitem>-arbpl },{ <orderitem>-ltxa1 },{ <orderitem>-bmsch },{ <orderitem>-vgw01 },{ <orderitem>-vgw02 },{ <orderitem>-vgw03 }|.
*    APPEND lv_row TO ct_data.
*  ENDLOOP.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form write_to_sheet
**&---------------------------------------------------------------------*
*FORM write_to_sheet USING io_sheet TYPE ole2_object
*                          it_data  TYPE string_table.
*
*  DATA: lo_range TYPE ole2_object,
*        lo_cell  TYPE ole2_object.
*
*  CALL METHOD OF io_sheet 'Cells' = lo_cell
*    EXPORTING #1 = 1 #2 = 1.
*  CALL METHOD OF io_sheet 'Range' = lo_range
*    EXPORTING #1 = lo_cell.
*
*  CALL METHOD OF lo_range 'Select'.
*
*  CALL METHOD OF io_sheet 'Paste'
*    EXPORTING
*      #1 = it_data.
*
*ENDFORM.
