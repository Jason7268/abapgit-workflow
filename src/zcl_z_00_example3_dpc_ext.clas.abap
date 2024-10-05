class ZCL_Z_00_EXAMPLE3_DPC_EXT definition
  public
  inheriting from ZCL_Z_00_EXAMPLE3_DPC
  create public .

public section.
protected section.

  methods FLIGHTSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_00_EXAMPLE3_DPC_EXT IMPLEMENTATION.


  method FLIGHTSET_GET_ENTITYSET.
DATA:   lt_headerdata TYPE STANDARD TABLE OF sflight,
        ls_headerdata TYPE  sflight,
        ls_product    LIKE LINE OF et_entityset.

  select * from sflight UP TO 50 ROWS
    INTO TABLE lt_headerdata.
  LOOP AT lt_headerdata INTO ls_headerdata.
    ls_product-carrid     = ls_headerdata-carrid.
    ls_product-connid     = ls_headerdata-connid.
    ls_product-currency   = ls_headerdata-currency.
    Ls_product-fldate     = ls_headerdata-fldate.
    Ls_product-paymentsum = ls_headerdata-paymentsum.
    Ls_product-planetype  = ls_headerdata-planetype.
    Ls_product-price      = ls_headerdata-price.
    Ls_product-seatsmax   = ls_headerdata-seatsmax.
    Ls_product-seatsmax_b = ls_headerdata-seatsmax_b.
    Ls_product-seatsmax_f = ls_headerdata-seatsmax_f.

    APPEND ls_product TO et_entityset.
  ENDLOOP.

  endmethod.
ENDCLASS.
