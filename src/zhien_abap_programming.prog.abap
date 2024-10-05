*&---------------------------------------------------------------------*
*& Report ZKHOI_ABAP_PROGRAMMING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_abap_programming.

TABLES: kna1, zdat_product_db.

* Tao Structure Type
TYPES: BEGIN OF gty_product,
         productid   TYPE zdat_de_productid,
         productname TYPE zdat_product_db-productname,
         zyear       TYPE zdat_de_year,
         price       TYPE zdat_de_price,
         currency    TYPE zdat_de_currency,
       END OF gty_product.
*-----------------------------------------------------------------------
* Data defind
DATA: lv_price    TYPE p DECIMALS 2 VALUE '100', " khai bao bien
      lv_float    TYPE f VALUE '500',
      gs_count    TYPE i,
      lv_airline  TYPE zsflight-carrid,
      gs_product  TYPE zdat_st_product,     " khai bao structure
      gt_product  TYPE zdat_tt_product,     " khai bao internal table
      gv_customer TYPE kna1-kunnr,          " khai bao theo field trong table
      gr_kunnr    TYPE RANGE OF kna1-kunnr. " khai bao range - tuong tu select-option
*&---------------------------------------------------------------------*
CONSTANTS gc_name TYPE string VALUE 'KHOI'.
*&---------------------------------------------------------------------*
* Khai bao structre (CACH 2)
DATA: gs_product_2 TYPE gty_product ,  " khai bao structure
      gt_product_4 TYPE STANDARD TABLE OF gty_product, " khai bao internal table
      gt_product_3 TYPE STANDARD TABLE OF gty_product, " khai bao internal table
      gt_product_2 TYPE STANDARD TABLE OF gty_product. " khai bao internal table

*&---------------------------------------------------------------------*
* Khai bao selection screen
PARAMETERS: p_proid TYPE zdat_product_db-productid,
            p_check AS CHECKBOX , " nhan gia tri 1: X 2: space
            p_radi1 RADIOBUTTON GROUP g1, " nhan gia tri 1: X 2: space
            p_radi2 RADIOBUTTON GROUP g1. " nhan gia tri 1: X 2: space

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS: so_prona FOR zdat_product_db-productname NO INTERVALS,
                  so_year  FOR zdat_product_db-zyear NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK blk1.

*&---------------------------------------------------------------------*
* get data from parameter and select option
SELECT * FROM zdat_product_db
  INTO CORRESPONDING FIELDS OF TABLE gt_product_2
  WHERE productid = p_proid
  OR    zyear IN so_year.
IF sy-subrc = 0.
  LOOP AT gt_product_2 INTO gs_product_2.
    WRITE: / gs_product_2-productid,
    gs_product_2-productname,
    gs_product_2-zyear,
    gs_product_2-price ,
    gs_product_2-currency.
  ENDLOOP.
*&---------------------------------------------------------------------*
* Apend to internal table
  CLEAR gs_product_2.
  gs_product_2-productid = 'PD15'.
  gs_product_2-productname = 'SAMSUNG 16'.
  gs_product_2-zyear      = '2025'.
  gs_product_2-price      = '1000'.
  gs_product_2-currency   = 'USD'.
  APPEND gs_product_2 TO gt_product_2.
  CLEAR gs_product_2.

  gs_product_2-productid = 'PD16'.
  gs_product_2-productname = 'SAMSUNG 16'.
  gs_product_2-zyear      = '2025'.
  gs_product_2-price      = '1000'.
  gs_product_2-currency   = 'USD'.
  INSERT gs_product_2 INTO gt_product_2 INDEX 3.

  LOOP AT gt_product_2 INTO gs_product_2 WHERE zyear = '2020'.
    IF gs_product_2-productid = 'PD06'.
      gs_product_2-price = '1500'.
      DATA(lv_flag) = sy-tabix.
      MODIFY gt_product_2 FROM gs_product_2.
    ENDIF.
  ENDLOOP.

*  DELETE gt_product_2 INDEX lv_flag. " sy-tabix bien chua gia tri index
*  DELETE gt_product_2 WHERE zyear = '2014'.
  CLEAR gs_product_2.
*&---------------------------------------------------------------------*
* insert or append nhiu line du lieu vao mot internal table khac
  APPEND LINES OF gt_product_2 TO gt_product_3.
  INSERT LINES OF gt_product_2 INTO gt_product_3 INDEX 5.

* Dem so luong line trong internal table
  DESCRIBE TABLE gt_product_3 LINES gs_count.
  WRITE:/ 'Number of row: ', gs_count.
*&---------------------------------------------------------------------*
  ULINE.
*&---------------------------------------------------------------------*
  READ TABLE gt_product_2 INTO gs_product_2 WITH KEY productid = p_proid.
  IF sy-subrc = 0.
    WRITE: / gs_product_2-productid,
    gs_product_2-productname,
    gs_product_2-zyear,
    gs_product_2-price ,
    gs_product_2-currency.
  ENDIF.
*&---------------------------------------------------------------------*
ENDIF.
*&---------------------------------------------------------------------*
CASE gs_product_2-zyear.
  WHEN '2024'.
    WRITE : 'NAM SAN PHAM 2024'.
  WHEN '2023'.
    WRITE : 'NAM SAN PHAM 2023'.
  WHEN OTHERS.
ENDCASE.
*&---------------------------------------------------------------------*
CHECK gs_product_2-zyear = '2025'. " THOA DIEU KIEN CHECK SE CHAY TIEP

IF gs_product_2-zyear IS NOT INITIAL. " BIEN YEAR CO GIA TRI

ELSEIF gs_product_2-zyear IS INITIAL. " BIEN YEAR KHONG CO GIA TRI

ELSE.

ENDIF.

DO 6 TIMES.
  WRITE 'hello'.
ENDDO.

WHILE gs_product_2-zyear = '2020'.

ENDWHILE.
*&---------------------------------------------------------------------*
LOOP AT gt_product_2 INTO gs_product_2.

  IF gs_product_2-zyear = '2020'.
    CONTINUE. " Dung lai, chay line ke tiep trong table
  ENDIF.

ENDLOOP.
*&---------------------------------------------------------------------*
DO.
  IF gs_product_2-zyear = '2020'.
    EXIT.
  ENDIF.
ENDDO.
