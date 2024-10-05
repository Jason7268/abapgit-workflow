*&---------------------------------------------------------------------*
*& Report ZHIEN_ALVOOP_TEST2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_alvoop_test2.
************************************************************************
** Global References for Classes **
************************************************************************
DATA: gr_table     TYPE REF TO cl_salv_table.
DATA: gr_functions TYPE REF TO cl_salv_functions.
DATA: gr_display   TYPE REF TO cl_salv_display_settings.
DATA: gr_columns   TYPE REF TO cl_salv_columns_table.
DATA: gr_column    TYPE REF TO cl_salv_column_table.
DATA: gr_sorts     TYPE REF TO cl_salv_sorts.
DATA: gr_agg       TYPE REF TO cl_salv_aggregations.
************************************************************************
** Data Declarations **
************************************************************************
DATA: it_spfli TYPE TABLE OF spfli.
************************************************************************
** Processing Blocks **
************************************************************************
START-OF-SELECTION.

*  TRY .
      SELECT * INTO TABLE it_spfli FROM spfli.
      cl_salv_table=>factory( IMPORTING r_salv_table = gr_table CHANGING t_table = it_spfli ).
      gr_functions = gr_table->get_functions( ).
      gr_functions->set_all( abap_true ).
      gr_display = gr_table->get_display_settings( ).
      gr_display->set_list_header( 'This is our custom heading' ).
      gr_display->set_striped_pattern( abap_true ).

      gr_columns = gr_table->get_columns( ).
      gr_column ?= gr_columns->get_column( 'CITYTO' ).
      gr_column->set_long_text( 'long text example' ).
      gr_column->set_medium_text( 'med text example' ).
      gr_column->set_short_text( 'short text' ).

      gr_sorts = gr_table->get_sorts( ).
      gr_sorts->add_sort( columnname = 'CITYTO' subtotal = abap_true ).

      gr_agg = gr_table->get_aggregations( ).
      gr_agg->add_aggregation( 'DISTANCE' ).
*    CATCH cx_salv_data_error INTO DATA(lv_ex).". As this exception was .
*    CATCH cx_salv_not_found .                           "#EC NO_HANDLER
*    CATCH cx_salv_existing .                            "#EC NO_HANDLER

*      MESSAGE lv_ex->get_text( ) TYPE 'E'.
*  ENDTRY.

  gr_table->display( ).
