*&---------------------------------------------------------------------*
*& Report ZHIEN_ABAP_EX2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_abap_ex2.

PARAMETERS p_year TYPE ZHIEN_DE_YEAR.
TYPES ty_string TYPE STANDARD TABLE OF string.


*main process
PERFORM main_process.

*&---------------------------------------------------------------------*
*& Form CAL_THIENCAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> u_year
*&      --> u_t_thiencan
*&      --> c_v_thiencan
*&---------------------------------------------------------------------*
FORM cal_thiencan  USING    u_year        TYPE char4
                            u_t_thiencan  TYPE ty_string
                   CHANGING c_v_thiencan  TYPE string.
  DATA lv_endnum TYPE char1.
  lv_endnum =  u_year+3(1) + 1.
  READ TABLE u_t_thiencan INDEX lv_endnum INTO c_v_thiencan.
  IF sy-subrc = 0.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_DIACHI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> u_year
*&      --> u_t_diachi
*&      <-- c_v_diachi
*&---------------------------------------------------------------------*
FORM cal_diachi  USING    u_year    TYPE char4
                          u_t_diachi TYPE ty_string
                 CHANGING c_v_diachi TYPE string.
  DATA lv_year TYPE i.
  lv_year = CONV i( u_year ).
  DATA lv_surplus TYPE i.
  lv_surplus =  lv_year MOD 12 + 1.
  READ TABLE u_t_diachi INDEX lv_surplus INTO c_v_diachi.

*  CHECK sy-subrc = 0.
*  WRITE:/ c_v_diachi.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form main_process
*&---------------------------------------------------------------------*
*& main process
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM main_process .

  DATA: lt_thiencan TYPE ty_string.
  DATA: lt_diachi TYPE ty_string.
  DATA: lv_thiencan TYPE string,
        lv_diachi   TYPE string.


  " STRING THIEN CAN
  lt_thiencan = VALUE #( ( |{ TEXT-T01 }| )
                         ( |{ TEXT-T02 }| )
                         ( |{ TEXT-T03 }| )
                         ( |{ TEXT-T04 }| )
                         ( |{ TEXT-T05 }| )
                         ( |{ TEXT-T06 }| )
                         ( |{ TEXT-T07 }| )
                         ( |{ TEXT-T08 }| )
                         ( |{ TEXT-T09 }| )
                         ( |{ TEXT-T10 }| ) ).

*LOOP AT lt_thiencan INTO DATA(lv_string).
*  WRITE: / lv_string.
*ENDLOOP.
* STRING ÐIA CHI



  lt_diachi = VALUE #( ( |{ TEXT-D01 }| )
                       ( |{ TEXT-D02 }| )
                       ( |{ TEXT-D03 }| )
                       ( |{ TEXT-D04 }| )
                       ( |{ TEXT-D05 }| )
                       ( |{ TEXT-D06 }| )
                       ( |{ TEXT-D07 }| )
                       ( |{ TEXT-D08 }| )
                       ( |{ TEXT-D09 }| )
                       ( |{ TEXT-D10 }| )
                       ( |{ TEXT-D11 }| )
                       ( |{ TEXT-D12 }| ) ).

**1 TÍNH THIEN CAN DUA VÀO SO CUOI NAM SINH
  PERFORM cal_thiencan USING    p_year
                                lt_thiencan
                       CHANGING lv_thiencan.

** TÍNH ÐIA CHI DUA VÀO NAM SINH/12 VÀ LAY SO DU*12 LÀM TRÒN
  PERFORM cal_diachi USING    p_year
                              lt_diachi
                     CHANGING lv_diachi.

  WRITE :/ p_year, 'LÀ NĂM: ', lv_thiencan,' ',lv_diachi.
ENDFORM.
