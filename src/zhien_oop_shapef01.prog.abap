*&---------------------------------------------------------------------*
*& Include          ZHIEN_OOP_SHAPEF01
*&---------------------------------------------------------------------*
CONSTANTS: pi TYPE p DECIMALS 2 VALUE '3.14'.

TYPES: BEGIN OF ty_dimension,
         area      TYPE p DECIMALS 2,
         perimeter TYPE p DECIMALS 2,
       END OF ty_dimension.

INTERFACE zif_shape.
  METHODS calculate_dimensions
    RETURNING
      VALUE(rs_dimensions) TYPE ty_dimension.
ENDINTERFACE.

CLASS zcl_square DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_hien_shape.
    METHODS constructor
      IMPORTING
        iv_side_length TYPE p.
*      RAISING
*        zcx_checkinput_gt_0.

  PRIVATE SECTION.
    DATA mv_side_length TYPE p.
ENDCLASS.

**--------------square--------------
CLASS zcl_square IMPLEMENTATION.
  METHOD constructor.
    IF iv_side_length <= 0.
*      RAISE EXCEPTION TYPE zcx_checkinput_gt_0.
    ENDIF.
    mv_side_length = iv_side_length.
  ENDMETHOD.

  METHOD zif_hien_shape~zhien_cl_square.
    IF mv_side_length = 0.
      RAISE EXCEPTION TYPE zcx_checkinput_gt_0.
    ELSE.
      ev_acreage   = 4 * mv_side_length.
      ev_perimeter = mv_side_length * mv_side_length.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

**--------------rectangle --------------
CLASS zcl_rectangle DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_hien_shape.
    METHODS constructor
      IMPORTING
        iv_length TYPE p
        iv_width  TYPE p.
*      RAISING
*        cx_invalid_parameter.

  PRIVATE SECTION.
    DATA lv_length TYPE p.
    DATA lv_width TYPE p.
ENDCLASS.

CLASS zcl_rectangle IMPLEMENTATION.
  METHOD constructor.
    IF iv_length <= 0 OR iv_width <= 0 .

    ENDIF.
    lv_length = iv_length.
    lv_width  = iv_width.

  ENDMETHOD.

  METHOD zif_hien_shape~zhien_rectangle .
    ev_acreage   = 2 * ( lv_width + lv_length ).
    ev_perimeter = lv_length * lv_width.
  ENDMETHOD.
ENDCLASS.



**--------------circle --------------
CLASS zcl_circle DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_shape.
    METHODS constructor
      IMPORTING
        iv_radius TYPE p.
*      RAISING
*        cx_invalid_parameter.

  PRIVATE SECTION.
    DATA lv_radius TYPE p.
ENDCLASS.

CLASS zcl_circle IMPLEMENTATION.
  METHOD constructor.
    IF iv_radius <= 0  .

    ENDIF.
    lv_radius = iv_radius.
  ENDMETHOD.

  METHOD zif_shape~calculate_dimensions.
    rs_dimensions-perimeter = 2 * pi * lv_radius.
    rs_dimensions-area = 2 * lv_radius * lv_radius.
  ENDMETHOD.
ENDCLASS.
