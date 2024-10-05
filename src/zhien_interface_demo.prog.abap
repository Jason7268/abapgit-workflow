*&---------------------------------------------------------------------*
*& Report ZHIEN_INTERFACE_DEMO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_INTERFACE_DEMO.

DATA: lo_ptb2 TYPE REF TO ZCL_HIEN_PTB2,
      lv_X1 TYPE p,
      lv_X2 TYPE p.

    CREATE OBJECT lo_ptb2
    EXPORTING
      iv_a = 4
      iv_b = 9
      iv_C = 0.

      DATA(lv_str) = lo_ptb2->zif_hien_demo~GIAIPTB2(
                                  IMPORTING ev_x1 = lv_X1
                                            ev_X2 = lv_x2 ).

      WRITE: lv_Str, 'X1 = ' , lv_X1, 'X2 = ' , lv_X2.
