*&---------------------------------------------------------------------*
*& Report ZHIEN_SALES_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_sales_report.

INCLUDE zhien_sales_reporttop.

START-OF-SELECTION.

  DATA: lo_report TYPE REF TO lcl_report.
  CREATE OBJECT lo_report.

  lo_report->get_customer( ).
*
  lo_report->get_data( ).
*
  lo_report->generate_output( ).

  INCLUDE zhien_sales_reportf01.
