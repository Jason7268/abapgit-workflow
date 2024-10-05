*&---------------------------------------------------------------------*
*& Report ZHIEN_ALVOOP_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_alvoop_test.

include ZHIEN_ALVOOP_TEST_TOP.


*&---------------------------------------------------------------------*
*& This code snippet will show how to use the CL_SALV_TABLE to
*& generate the ALV
*& follow example code of http://zevolving.com/2008/09/tutorials/
*&---------------------------------------------------------------------*
*REPORT zkhoi_salv_om.





*---------------------------------------------------------------------*
* START OF SELECTION
*---------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: lo_report TYPE REF TO lcl_report.
*
  CREATE OBJECT lo_report.
*
  lo_report->get_data( ).
*
  lo_report->generate_output( ).

  include ZHIEN_ALVOOP_TEST_F01.
