*&---------------------------------------------------------------------*
*& Include          ZHIEN_SALES_REPORTF01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.
*
  METHOD get_data.
* data selection
    SELECT  h~zzcustomer
            i~zzvbeln
            i~zzvbelp
            i~zzmatnr
            i~zzmenge
            i~zzmeins
            i~zznetpr
            h~zzwaers
    INTO CORRESPONDING FIELDS OF TABLE t_vbak
    FROM  zhien_vbak AS h
      INNER JOIN  zhien_vbap AS i
        ON   h~zzvbeln = i~zzvbeln
    WHERE h~zzvbeln IN s_vbeln
      AND h~zzcustomer IN s_cust
      AND i~zzwerks IN s_werks.

    DATA: lv_string TYPE string.
    LOOP AT  t_vbak ASSIGNING FIELD-SYMBOL(<lfs_vbak>).
      CLEAR lv_string.
      " ADD LEADING ZERO to customer id
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <lfs_vbak>-zzcustomer
        IMPORTING
          output = lv_string.
*   Get customer name
      READ TABLE t_customer INTO DATA(ls_customer)
      WITH KEY zzcustomer = lv_string
       BINARY SEARCH.
      IF sy-subrc = 0. " Success
        <lfs_vbak>-ZZNAME1 = ls_customer-ZZNAME1.
      ENDIF.
      <lfs_vbak>-zznetprwt = <lfs_vbak>-zznetpr * <lfs_vbak>-zzmenge.
    ENDLOOP.
  ENDMETHOD. "get_data
*
  METHOD get_customer.
** data selection
    SELECT  zzcustomer
            ZZNAME1
    INTO CORRESPONDING FIELDS OF TABLE t_customer
    FROM  zhien_kna1.
    SORT t_customer BY zzcustomer.
  ENDMETHOD. "get_data
*.......................................................................
  METHOD generate_output.
* New ALV instance
* We are calling the static Factory method which will give back
* the ALV object reference.
** exception class
    DATA: lx_msg TYPE REF TO cx_salv_msg.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      = t_vbak ).
      CATCH cx_salv_msg INTO lx_msg.
    ENDTRY.
*
*$*$*.....CODE_ADD_2 - Begin..................................2..*$*$*
* *
*    In this area we will call the methods which will set the
* different properties to the ALV
*
    CALL METHOD set_pf_status
      CHANGING
        co_alv = o_alv.
* Setting up the Layout
    CALL METHOD set_layout
      CHANGING
        co_alv = o_alv.
* Calling the top of page method
    CALL METHOD me->set_top_of_page
      CHANGING
        co_alv = o_alv.
* Calling the End of Page method
    CALL METHOD me->set_end_of_page
      CHANGING
        co_alv = o_alv.
    CALL METHOD set_display_setting
      CHANGING
        co_alv = o_alv.
* *
*    Setting up the Columns
    CALL METHOD me->set_columns
      CHANGING
        co_alv = o_alv.
* *
*    SET Up the Hotspot & Event Handler
    CALL METHOD set_hotspot_vbeln
      CHANGING
        co_alv    = o_alv
        co_report = lo_report.
* Set the colors to ALV display
    CALL METHOD set_colors
      CHANGING
        co_alv  = o_alv
        ct_vbak = t_vbak.
* Set SORT
    CALL METHOD set_sorts
      CHANGING
        co_alv = o_alv.
* *
*    SET the colors to alv display
    CALL METHOD set_aggregations
      CHANGING
        co_alv = o_alv.
* Set Filters
    CALL METHOD set_filters
      CHANGING
        co_alv = o_alv.
*$*$*.....CODE_ADD_2 - End....................................2..*$*$*
* * *
*    Displaying the alv
* Here we will call the DISPLAY method to get the output on the screen
    o_alv->display( ).
*
  ENDMETHOD. "generate_output
*
*$*$*.....CODE_ADD_3 - Begin..................................3..*$*$*
* *
*  In this area we will implement the methods which are defined in
* the class definition
*
  METHOD set_pf_status.
* Calling method to set the PF-Status
    co_alv->set_screen_status(
      pfstatus      = 'SALV_STANDARD'
      report        = 'SALV_DEMO_TABLE_SELECTIONS'
      set_functions = co_alv->c_functions_all ).
  ENDMETHOD. "set_pf_status
  METHOD set_layout.
*
    DATA: lo_layout  TYPE REF TO cl_salv_layout,
          lf_variant TYPE slis_vari,
          ls_key     TYPE salv_s_layout_key.
* *
*GET layout object
    lo_layout = co_alv->get_layout( ).
* *
*  SET Layout save restriction
* 1. Set Layout Key .. Unique key identifies the Differenet ALVsls_key-report = sy-repid.
    lo_layout->set_key( ls_key ).
** 2. Remove Save layout the restriction.
    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
* *
*  SET initial Layout
    lf_variant = 'DEFAULT'.
    lo_layout->set_initial_layout( lf_variant ).
*
  ENDMETHOD. "set_layout
  METHOD set_top_of_page.
*
    DATA: lo_header  TYPE REF TO cl_salv_form_layout_grid,
          lo_h_label TYPE REF TO cl_salv_form_label,
          lo_h_flow  TYPE REF TO cl_salv_form_layout_flow.
* *
*  header object
    CREATE OBJECT lo_header.
* *
*  To create a Lable or Flow we have to specify the target
* row and column number where we need to set up the output
* text.
* *
*  information in Bold
    lo_h_label = lo_header->create_label( row = 1 column = 1 ).
    lo_h_label->set_text( 'Header in Bold' ).
* *
*  information in tabular format
    lo_h_flow = lo_header->create_flow( row = 2 column = 1 ).
    lo_h_flow->create_text( text = 'This is text of flow' ).
*
    lo_h_flow = lo_header->create_flow( row = 3 column = 1 ).
    lo_h_flow->create_text( text = 'Number of Records in the output' ).
*
    lo_h_flow = lo_header->create_flow( row = 3 column = 2 ).
    lo_h_flow->create_text( text = 20 ).
* *
*    SET the TOP of list using the header for Online.
    co_alv->set_top_of_list( lo_header ).
* *
*    SET the TOP of list using the header for PRINT.
    co_alv->set_top_of_list_print( lo_header ).
*
  ENDMETHOD. "set_top_of_page
*
  METHOD set_end_of_page.
*
    DATA: lo_footer  TYPE REF TO cl_salv_form_layout_grid,
          lo_f_label TYPE REF TO cl_salv_form_label,
          lo_f_flow  TYPE REF TO cl_salv_form_layout_flow.
* *
*  footer object
    CREATE OBJECT lo_footer.
* *
*  information in bold
    lo_f_label = lo_footer->create_label( row = 1 column = 1 ).
    lo_f_label->set_text( 'Footer .. here it goes' ).
* *
*  tabular information
    lo_f_flow = lo_footer->create_flow( row = 2 column = 1 ).
    lo_f_flow->create_text( text = 'This is text of flow in footer' ).
*
    lo_f_flow = lo_footer->create_flow( row = 3 column = 1 ).
    lo_f_flow->create_text( text = 'Footer number' ).
*
    lo_f_flow = lo_footer->create_flow( row = 3 column = 2 ).
    lo_f_flow->create_text( text = 1 ).
* *
*  Online footer
    co_alv->set_end_of_list( lo_footer ).
* *
*  Footer in print
    co_alv->set_end_of_list_print( lo_footer ).
*
  ENDMETHOD. "set_end_of_page
  METHOD set_display_setting.
*
    DATA: lo_display TYPE REF TO cl_salv_display_settings.
* *
*GET display object
    lo_display = co_alv->get_display_settings( ).
* *
*  SET zebra pattern
    lo_display->set_striped_pattern( 'X' ).
* *
*    Title to alv
    lo_display->set_list_header( 'ALV Test for Display Settings' ).
*
  ENDMETHOD. "SET_DISPLAY_SETTING
  METHOD set_columns.
*
*...Get all the Columns
    DATA: lo_cols TYPE REF TO cl_salv_columns_table.
    lo_cols = o_alv->get_columns( ).
* *
*  SET the Column optimization
    lo_cols->set_optimize( 'X' ).
*
*...Process individual columns
    DATA: lo_column TYPE REF TO cl_salv_column_table.
* *
*    Change the properties of the Columns kunnr
    TRY.
        lo_column ?= lo_cols->get_column( 'ZZNETPRWT' ).
        lo_column->set_long_text( 'Amount Without tax' ).
        lo_column->set_medium_text( 'Amount Wo tax' ).
        lo_column->set_short_text( 'Amount WOT' ).
        lo_column->set_output_length( '50' ).
      CATCH cx_salv_not_found." INTO DATA(LV_EX).                         "#EC NO_HANDLER
*          MESSAGE LV_EX->get_text( ) TYPE 'E'.

    ENDTRY.
*
  ENDMETHOD. "SET_COLUMNS
  METHOD set_hotspot_vbeln.
*
*...HotSpot
    DATA: lo_cols_tab TYPE REF TO cl_salv_columns_table,
          lo_col_tab  TYPE REF TO cl_salv_column_table.
* *
*GET Columns object
    lo_cols_tab = co_alv->get_columns( ).
* *
*GET vbeln column
    TRY.
        lo_col_tab ?= lo_cols_tab->get_column( 'ZZVBELN' ).
      CATCH cx_salv_not_found.
    ENDTRY.
* *
*SET the HotSpot for vbeln Column
    TRY.
        CALL METHOD lo_col_tab->set_cell_type
          EXPORTING
            value = if_salv_c_cell_type=>hotspot.
        .
      CATCH cx_salv_data_error .
    ENDTRY.
*
*...Events
    DATA: lo_events TYPE REF TO cl_salv_events_table.
** *
*all events
    lo_events = o_alv->get_event( ).
* *
*event handler
    SET HANDLER co_report->on_link_click FOR lo_events.
*
  ENDMETHOD. "set_hotspot_vbeln
* Handles the UI on the VBELN (HotSpot)
  METHOD on_link_click.
*
    DATA: la_vbak TYPE ty_vbak.
* *
*GET the Sales Order number from the table
    READ TABLE lo_report->t_vbak INTO la_vbak INDEX row.
    IF la_vbak-zzvbeln IS NOT INITIAL.
      MESSAGE i398(00) WITH 'You have selected' la_vbak-zzvbeln.
    ENDIF.
*
  ENDMETHOD. "on_link_click
  METHOD set_colors.
*.....Color for COLUMN.....
    DATA: lo_cols_tab TYPE REF TO cl_salv_columns_table,
          lo_col_tab  TYPE REF TO cl_salv_column_table.
    DATA: ls_color TYPE lvc_s_colo. " Colors strucutre
* get Columns object
    lo_cols_tab = co_alv->get_columns( ).
**
    INCLUDE <color>.
* Get ZCUSTOMER column & set the yellow Color for it
    TRY.
        lo_col_tab ?= lo_cols_tab->get_column( 'ZZCUSTOMER' ).
        ls_color-col = col_total.
        lo_col_tab->set_color( ls_color ).
      CATCH cx_salv_not_found.
    ENDTRY.
*.......Color for Specific Cell & Rows.................
* Applying color on the 3rd Row and Column AUART
* Applying color on the Entire 5th Row
*
    DATA: lt_s_color TYPE lvc_t_scol,
          ls_s_color TYPE lvc_s_scol,
          la_vbak    LIKE LINE OF ct_vbak,
          l_count    TYPE i.
    LOOP AT ct_vbak INTO la_vbak.
      l_count = l_count + 1.
      CASE l_count.
* Apply RED color to the AUART Cell of the 3rd Row
        WHEN 3.
          ls_s_color-fname = 'ZMEINS'.
          ls_s_color-color-col = col_negative.
          ls_s_color-color-int = 0.
          ls_s_color-color-inv = 0.
          APPEND ls_s_color TO lt_s_color.
          CLEAR ls_s_color.
* Apply GREEN color to the entire row # 5
* For entire row, we don't pass the Fieldname
        WHEN 5.
          ls_s_color-color-col = col_positive.
          ls_s_color-color-int = 0.
          ls_s_color-color-inv = 0.
          APPEND ls_s_color TO lt_s_color.
          CLEAR ls_s_color.
      ENDCASE.
* Modify that data back to the output table
      la_vbak-t_color = lt_s_color.
      MODIFY ct_vbak FROM la_vbak.
      CLEAR la_vbak.
      CLEAR lt_s_color.
    ENDLOOP.
* We will set this COLOR table field name of the internal table to
* COLUMNS tab reference for the specific colors
    TRY.
        lo_cols_tab->set_color_column( 'T_COLOR' ).
      CATCH cx_salv_data_error.                         "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD. "set_colors
  METHOD set_sorts.
    DATA: lo_sort TYPE REF TO cl_salv_sorts.
* *
*GET Sort object
    lo_sort = co_alv->get_sorts( ).
* *
*  SET the SORT on the vkorg, vtweg, kunnr,
*  WITH Subtotal
    TRY.
        CALL METHOD lo_sort->add_sort
          EXPORTING
            columnname = 'ZZVBELN'
            subtotal   = if_salv_c_bool_sap=>true.
        CALL METHOD lo_sort->add_sort
          EXPORTING
            columnname = 'ZZCUSTOMER'
            subtotal   = if_salv_c_bool_sap=>true.
        CALL METHOD lo_sort->add_sort
          EXPORTING
            columnname = 'ZZNAME1'
            subtotal   = if_salv_c_bool_sap=>true.
        CALL METHOD lo_sort->add_sort
          EXPORTING
            columnname = 'ZZVBELP'
            subtotal   = if_salv_c_bool_sap=>true.
      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
      CATCH cx_salv_existing .                          "#EC NO_HANDLER
      CATCH cx_salv_data_error .                        "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD. "set_sorts
  METHOD set_aggregations.
    DATA: lo_aggrs TYPE REF TO cl_salv_aggregations.
*
    lo_aggrs = co_alv->get_aggregations( ).
* *
*ADD total for COLUMN netwr
    TRY.
        CALL METHOD lo_aggrs->add_aggregation
          EXPORTING
            columnname  = 'ZZNETPR'
            aggregation = if_salv_c_aggregation=>total.
      CATCH cx_salv_data_error .                        "#EC NO_HANDLER
      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
      CATCH cx_salv_existing .                          "#EC NO_HANDLER
    ENDTRY.
* *
*Bring the total line to top
*    lo_aggrs->set_aggregation_before_items( ).
  ENDMETHOD. "set_aggregations
  METHOD set_filters.
*    DATA: lo_filters TYPE REF TO cl_salv_filters.
**
*    lo_filters = co_alv->get_filters( ).
** *
**SET the filter for the column erdat
** the filter criteria works exactly same as any
** RANGE or SELECT-OPTIONS works.
*    TRY.
*        CALL METHOD lo_filters->add_filter
*          EXPORTING
*            columnname = 'VKORG'
*            sign       = 'I'
*            option     = 'EQ'
*            low        = '1010'
*            high       = '1710'.
*      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
*      CATCH cx_salv_data_error .                        "#EC NO_HANDLER
*      CATCH cx_salv_existing .                          "#EC NO_HANDLER
*    ENDTRY.
  ENDMETHOD. "set_filters
*$*$*.....CODE_ADD_3 - End....................................3..*$*$*
*
  METHOD show_form.
    DATA: lt_item TYPE ZTTHIENFORM_SO_ITEM.
  MOVE-CORRESPONDING t_vbak TO lt_item .
  ENDMETHOD. "show_form

ENDCLASS. "lcl_report IMPLEMENTATION


FORM show_form.
  DATA: LT_ITEM TYPE ZSHIENFORM_SO_ITEM,
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
