*&---------------------------------------------------------------------*
*& Report ZHIEN_INTERFACE_DEMO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_oop_shape.

INCLUDE ZHIEN_OOP_SHAPEf01.

PARAMETERS: p_rad1 RADIOBUTTON GROUP g1 USER-COMMAND usr DEFAULT 'X',
            p_rad2 RADIOBUTTON GROUP g1,
            p_rad3 RADIOBUTTON GROUP g1.

PARAMETERS: p_lside TYPE p DECIMALS 2 MODIF ID m01.

PARAMETERS: p_length TYPE p DECIMALS 2 MODIF ID m02,
            p_width  TYPE p DECIMALS 2 MODIF ID m02.

PARAMETERS: p_radius TYPE p DECIMALS 2 MODIF ID m03.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF p_rad1 = abap_true.
      IF screen-group1 = 'M01'.
        screen-active = 1.
      ELSEIF screen-group1 = 'M02'.
        screen-active = 0.
      ELSEIF screen-group1 = 'M03'.
        screen-active = 0.
      ENDIF.
    ELSEIF p_rad2 = abap_true.
      IF screen-group1 = 'M01'.
        screen-active = 0.
      ELSEIF screen-group1 = 'M02'.
        screen-active = 1.
      ELSEIF screen-group1 = 'M03'.
        screen-active = 0.
      ENDIF.
    ELSEIF p_rad3 = abap_true.
      IF screen-group1 = 'M01'.
        screen-active = 0.
      ELSEIF screen-group1 = 'M02'.
        screen-active = 0.
      ELSEIF screen-group1 = 'M03'.
        screen-active = 1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

START-OF-SELECTION.

  DATA: lv_p TYPE p,
        lv_a TYPE p.

  IF p_rad1 =  abap_true. "SQUARE
*    IF p_lside IS NOT INITIAL.
      DATA: lo_square TYPE REF TO zcl_square.
      CREATE OBJECT lo_square
        EXPORTING
          iv_side_length = p_lside.
*  TRY.
*  DATA(lo_square) = NEW zcl_square( 7 ).
*      DATA(ls_dimensions) = lo_square->zif_shape~calculate_dimensions( ).
*      WRITE: 'Square area =', ls_dimensions-area,
*             'Square perimeter =', ls_dimensions-perimeter.
*  DATA(lo_square) = NEW zcl_square( 7 ).
      TRY .
        lo_square->zif_hien_shape~zhien_cl_square(
        IMPORTING
          ev_acreage   = lv_a
          ev_perimeter = lv_p
      ).
      CATCH zcx_checkinput_gt_0 INTO DATA(lo_exception).
        WRITE: lo_exception->get_text( ).
      ENDTRY.

      WRITE:/ 'Square area =', lv_a,/,
             'Square perimeter =', lv_p.
*    CATCH cx_invalid_parameter.
*      WRITE 'Invalid side length provided.'.
*  ENDTRY.
*    ELSE.
*      MESSAGE 'PLEASE FILL ALL DATA' TYPE 'W'.
*    ENDIF.

  ELSEIF p_rad2 =  abap_true.  " RECTENGLE

    IF p_length IS NOT INITIAL AND p_width IS NOT INITIAL.
*  DATA(lo_rectangle) = NEW zcl_rectangle( iv_length = 3 iv_width = 4 ).
*      DATA(ls_resultrec) = lo_rectangle->zif_shape~calculate_dimensions( ).
*      WRITE:/ 'rectangle area =', ls_resultrec-area,
*             'rectangle perimeter =', ls_resultrec-perimeter.
      DATA(lo_rectangle) = NEW zcl_rectangle( iv_length = p_length iv_width = p_width ).
      CLEAR : lv_a, lv_p.
      lo_rectangle->zif_hien_shape~zhien_rectangle(
        IMPORTING
          ev_acreage   = lv_a
          ev_perimeter = lv_p
      ).
      WRITE:/ 'rectangle area =', lv_a,/,
             'rectangle perimeter =', lv_p.

    ELSE.
      MESSAGE 'PLEASE FILL ALL DATA' TYPE 'W'.
    ENDIF.

  ELSEIF p_rad3 =  abap_true.  "CIRCLE

    IF p_radius IS NOT INITIAL.
      DATA(lo_circle) = NEW zcl_circle( p_radius ).
      DATA(ls_resultcircle) = lo_circle->zif_shape~calculate_dimensions( ).
      WRITE:/ 'Circle area =', ls_resultcircle-area,/,
              'Circle perimeter =', ls_resultcircle-perimeter.
    ELSE.
      MESSAGE 'PLEASE FILL ALL DATA' TYPE 'W'.
    ENDIF.



  ENDIF.
