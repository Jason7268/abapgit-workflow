FUNCTION ZHIEN_TINH_TONG_NAME.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_FIND) TYPE  ZHIEN_DE_PRODUCTNAME
*"  EXPORTING
*"     REFERENCE(EV_TONG) TYPE  ZHIEN_DE_PRICE
*"  TABLES
*"      IT_PRODUCT STRUCTURE  ZHIEN_PRODUCT_DB
*"  EXCEPTIONS
*"      CHECK_KEY_NOT_INTIAL
*"----------------------------------------------------------------------


LOOP AT it_product INTO DATA(ls_product).

    IF ls_product-productname cs IV_FIND. " name have string
      ev_tong += ls_product-pricep.
    ENDIF.

ENDLOOP.


ENDFUNCTION.
