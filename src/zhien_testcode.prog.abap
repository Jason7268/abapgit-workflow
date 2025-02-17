*&---------------------------------------------------------------------*
*& Report ZHIEN_TESTCODE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_testcode LINE-SIZE 250.

DATA lv_number TYPE I.

CALL FUNCTION 'NUMBER_GET_NEXT'
  EXPORTING
    nr_range_nr                   = '01'
    object                        = 'ZPURORDER'
*   QUANTITY                      = '1'
*   SUBOBJECT                     = ' '
*   TOYEAR                        = '0000'
*   IGNORE_BUFFER                 = ' '
 IMPORTING
   NUMBER                        = lv_number
*   QUANTITY                      =
*   RETURNCODE                    =
 EXCEPTIONS
   INTERVAL_NOT_FOUND            = 1
   NUMBER_RANGE_NOT_INTERN       = 2
   OBJECT_NOT_FOUND              = 3
   QUANTITY_IS_0                 = 4
   QUANTITY_IS_NOT_1             = 5
   INTERVAL_OVERFLOW             = 6
   BUFFER_OVERFLOW               = 7
   OTHERS                        = 8
          .
IF sy-subrc <> 0.
* Implement suitable error handling here

  ELSE.
     MESSAGE 'Next number: ' && lv_number TYPE 'I'.
ENDIF.




*CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
*  EXPORTING
*    date                      = '23122023'
*  EXCEPTIONS
*    plausibility_check_failed = 1
*    OTHERS                    = 2.
*IF sy-subrc <> 0.
* Implement suitable error handling here
*ENDIF.



*DATA: 1v_date TYPE sy-datum VALUE '20120931'. " YYYYMMDD
*CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
*  EXPORTING
*    date                      = 1v_date
*  EXCEPTIONS
*    plausibility_check_failed = 1
*    OTHERS                    = 2.
*IF sy-subrc <> 0.
*  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_ms).
*  MESSAGE lv_ms TYPE sy-msgty.
*ELSE.
*  MESSAGE 'Valid Date' TYPE 'I'.
*ENDIF.




























*-------------------------------------------test split tring
*SET TITLEBAR 'TITLE_TEST'.
*SET PF-STATUS 'STATUS_TEST'.
*DATA: lv_string TYPE string VALUE '1001,John,,2023-07-18,2000.50',
*      lt_parts  TYPE TABLE OF string,
*      lv_part   TYPE string.
*
*" Tách chuỗi thành các phần tử
*SPLIT lv_string AT ',' INTO TABLE lt_parts.
*
*" Khai báo các biến để chứa các giá trị chuyển đổi
*DATA: lv_id       TYPE i,
*      lv_name     TYPE string,
*      lv_date     TYPE d,
*      lv_salary   TYPE p DECIMALS 2.
*
*" Đọc và chuyển đổi các phần tử từ lt_parts
*READ TABLE lt_parts INTO lv_part INDEX 1.
*IF sy-subrc = 0.
*  lv_id = CONV i( lv_part ).
*ENDIF.
*
*READ TABLE lt_parts INTO lv_part INDEX 2.
*IF sy-subrc = 0.
*  lv_name = lv_part.
*ENDIF.
*
*READ TABLE lt_parts INTO lv_part INDEX 3.
*IF sy-subrc = 0.
*  IF lv_part IS INITIAL.
*    WRITE: / 'Empty element, skipping or setting default value'.
**    CONTINUE.
*  ENDIF.
*ENDIF.
*
*READ TABLE lt_parts INTO lv_part INDEX 4.
*IF sy-subrc = 0.
*  lv_date = CONV d( lv_part ).
*ENDIF.
*
*READ TABLE lt_parts INTO lv_part INDEX 5.
*IF sy-subrc = 0.
*  lv_salary = lv_part .
*ENDIF.
*
*" Hiển thị các giá trị sau khi chuyển đổi
*WRITE: / 'ID:', lv_id,
*       / 'Name:', lv_name,
*       / 'Date:', lv_date,
*       / 'Salary:', lv_salary.


*DATA : LT_PRODUCT TYPE ZHIEN_TT_PRODUCT.
*DATA : LS_PRODUCT TYPE ZHIEN_ST_PRODUCT.
*
*SELECT * FROM ZHIEN_PRODUCT_DB INTO CORRESPONDING FIELDS OF TABLE LT_PRODUCT
*         WHERE PRICEP > 4000 AND PRODUCTNAME LIKE 'HONDA%'.
*IF SY-SUBRC = 0.
*    LOOP AT LT_PRODUCT INTO LS_PRODUCT.
*    WRITE:/ 'PRODUCT: ' ,
*            LS_PRODUCT-PRODUCTID,
*            LS_PRODUCT-PRODUCTNAME,
*            LS_PRODUCT-YEARP,
*            LS_PRODUCT-PRICEP CURRENCY LS_PRODUCT-CURRENCY,
*            LS_PRODUCT-CURRENCY.
*  ENDLOOP.
*ENDIF.
*
** Write table with line
*DATA : lt_spfli TYPE STANDARD TABLE OF spfli.
*DATA : ls_spfli TYPE spfli.
*
*SELECT * FROM spfli INTO CORRESPONDING FIELDS OF TABLE lt_spfli UP TO 20 ROWS.
**         WHERE PRICEP > 4000 AND PRODUCTNAME LIKE 'HONDA%'.
*
*WRITE: /(5) 'Airline',         sy-vline,
*        (8) 'Flight No',       sy-vline,
*       (11) 'Dep.country',     sy-vline,
*       (16) 'Dep.city',        sy-vline,
*       (15) 'Dep.airport',     sy-vline,
*       (12) 'Arrival country', sy-vline,
*       (16) 'Arrival city',    sy-vline,
*       (15) 'Des.airport',     sy-vline,
*       (14) 'Flight time',     sy-vline,
*       (12) 'Dep time',        sy-vline,
*       (15) 'Arrival time',    sy-vline,
*       (7) 'Distance',        sy-vline,
*        (4) 'Unit',            sy-vline,
*       (11) 'Flight type',     sy-vline,
*        (7) 'Arrival n day(s)',sy-vline,
*        sy-uline.
*
*
*LOOP AT lt_spfli INTO ls_spfli.
*  WRITE: /(5)   ls_spfli-carrid,    sy-vline,
*          (8)   ls_spfli-connid,    sy-vline,
*         (11)   ls_spfli-countryfr, sy-vline,
*         (16)   ls_spfli-cityfrom,  sy-vline,
*         (15)   ls_spfli-airpfrom,  sy-vline,
*         (12)   ls_spfli-countryto, sy-vline,
*         (16)   ls_spfli-cityto,    sy-vline,
*         (15)   ls_spfli-airpto,    sy-vline,
*         (14)   ls_spfli-fltime,    sy-vline,
*         (12)   ls_spfli-deptime,   sy-vline,
*         (15)   ls_spfli-arrtime,   sy-vline,
*          (7)   ls_spfli-distance,  sy-vline,
*          (4)   ls_spfli-distid,    sy-vline,
*         (11)   ls_spfli-fltype,    sy-vline,
*          (7)   ls_spfli-period,    sy-vline.
*
*ENDLOOP.
*
*WRITE: sy-uline.
*

** test gán giá tri chuoi cho table
*DATA: lt_string_table TYPE STANDARD TABLE OF string.
*
**lt_string_table = VALUE #(  ( `Chuỗi thứ nhất`  )
**                            ( `Chuỗi thứ 2`     )
**                            ( `Chuỗi thứ 3`     ) ).
*
*lt_string_table = VALUE #(  ( |Chuỗi thứ nhất| )
*                            ( |Chuỗi thứ 2|     )
*                            ( |Chuỗi thứ 3|     ) ).
*
*
*LOOP AT lt_string_table INTO DATA(lv_string).
*  WRITE: / lv_string.
*ENDLOOP.

*DATA: lv_dividend TYPE i VALUE 1890,   " Số bị chia
*      lv_divisor  TYPE i VALUE 12,    " Số chia
*      lv_remainder TYPE i.           " Biến chứa kết quả số dư
*
*lv_remainder = lv_dividend MOD 12.
*
*WRITE: / 'Số dư là:', lv_remainder.
*
*PARAMETERS: lv_x2 type p DECIMALS 2 ,
*      lv_x type p DECIMALS 2,
*      lv_num type p DECIMALS 2.
*
*Data: lv_para type p DECIMALS 2,
*      lv_th1 type p DECIMALS 2,
*      lv_th2 type p DECIMALS 2.
*
** tinh delta
*lv_para = lv_x * lv_x - 4 * lv_x2 * lv_num.
*
*IF lv_para < 0 .
*  WRITE /'vo nhiem'.
*  ELSEIF lv_para = 0.
*    lv_th1 = - lv_x / ( 2 * lv_x2 ).
*    WRITE: /'nhiem kep = ', lv_th1.
*    else.
*      lv_th1 = ( - lv_x + sqrt( lv_para ) / 2 * lv_x2 ).
*      WRITE / lv_th1.
*      lv_th2 = ( - lv_x - sqrt( lv_para ) / 2 * lv_x2 ).
*            WRITE / lv_th2.
*
*
*ENDIF.




**----------------- test value help
*TYPES:
*       BEGIN OF TY_vbak,
*         vbeln TYPE vbak-vbeln,
*       END OF TY_vbak.
*       DATA:
*      lv_aufnr    TYPE aufnr,
*      lv_aufart   TYPE aufart,
*      lv_VBELN   TYPE VBELN_VA
*            .
*
*       DATA IT_vbak  TYPE STANDARD TABLE OF TY_vbak.
*
*SELECT-OPTIONS:
*  s_aufnr       FOR lv_aufnr,
*  s_aufart      FOR lv_aufart,
*   s_VBELN      FOR lv_VBELN
*  .
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_aufnr-low.
*
*  PERFORM aufnr_f4 CHANGING s_aufnr-low.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_aufnr-high.
*
*  PERFORM aufnr_f4 CHANGING s_aufnr-high.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_aufart-low.
*
*  PERFORM aufart_f4 CHANGING s_aufart-low.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_aufart-high.
*
*  PERFORM aufart_f4 CHANGING s_aufart-high.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_VBELN-low.
*
*  PERFORM VBELN_f4 CHANGING s_VBELN-low.
*
*FORM aufnr_f4
*  CHANGING
*    cv_aufnr TYPE aufnr.
*
*  DATA:
*        lv_value    TYPE help_info-fldvalue,
*        lt_return   TYPE STANDARD TABLE OF ddshretval
*        .
*
*    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
*      exporting
*        TABNAME             = '<any>'     " Table/structure name from Dictionary
*        FIELDNAME           = '<any>'     " Field name from Dictionary
*        SEARCHHELP          = 'ORDE'      " Search help as screen field attribute
*        VALUE               = lv_value    " Field contents for F4 call
*      tables
*        RETURN_TAB          = lt_return   " Return the selected value
*      exceptions
*        FIELD_NOT_FOUND     = 1           " Field does not exist in the Dictionary
*        NO_HELP_FOR_FIELD   = 2           " No F4 help is defined for the field
*        INCONSISTENT_HELP   = 3           " F4 help for the field is inconsistent
*        NO_VALUES_FOUND     = 4           " No values found
*        OTHERS              = 5
*      .
*    IF sy-subrc NE 0.
*      RETURN.
*    ENDIF.
*    READ TABLE lt_return INTO DATA(ls_ret) INDEX 1.
*    cv_aufnr = ls_ret-fieldval.
*
*ENDFORM.
*
*FORM aufart_f4
*  CHANGING
*    cv_aufart TYPE aufart.
*
*    DATA:
*        lt_values   TYPE STANDARD TABLE OF t003o,
*        lt_return   TYPE STANDARD TABLE OF ddshretval
*        .
*
*  SELECT *                "#EC CI_NOWHERE
*    FROM t003o
*    INTO TABLE lt_values.
*
*  IF sy-subrc NE 0.
*    RETURN.
*  ENDIF.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    exporting
*      RETFIELD         = 'AUART'    " Name of field in VALUE_TAB
*      VALUE_ORG        = 'S'        " Value return: C: cell by cell, S: structured
*    tables
*      VALUE_TAB        = lt_values  " Table of values: entries cell by cell
*      RETURN_TAB       = lt_return  " Return the selected value
*    exceptions
*      PARAMETER_ERROR  = 1          " Incorrect parameter
*      NO_VALUES_FOUND  = 2          " No values found
*      OTHERS           = 3
*    .
*
*  IF sy-subrc NE 0.
*    RETURN.
*  ENDIF.
*
*  read table lt_return INTO DATA(ls_return) INDEX 1.
*  cv_aufart = ls_return-fieldval.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form VBELN_f4
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**&      <-- S_VBELN_LOW
**&---------------------------------------------------------------------*
*FORM VBELN_f4  CHANGING cv_vbeln  TYPE VBELN_VA.
*   DATA:
*        lt_values   TYPE STANDARD TABLE OF vbak,
*        lt_return   TYPE STANDARD TABLE OF ddshretval
*        .
*
*  SELECT vbeln,  ERDAT, NETWR             "#EC CI_NOWHERE
*    FROM vbak
*    INTO TABLE @DATA(lT_vbak) UP TO 20 rows.
*
*  IF sy-subrc NE 0.
*    RETURN.
*  ENDIF.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    exporting
*      RETFIELD         = 'VBELN'    " Name of field in VALUE_TAB
*      VALUE_ORG        = 'S'        " Value return: C: cell by cell, S: structured
*    tables
*      VALUE_TAB        = lT_vbak " Table of values: entries cell by cell
*      RETURN_TAB       = lt_return  " Return the selected value
*    exceptions
*      PARAMETER_ERROR  = 1          " Incorrect parameter
*      NO_VALUES_FOUND  = 2          " No values found
*      OTHERS           = 3
*    .
*
*  IF sy-subrc NE 0.
*    RETURN.
*  ENDIF.
*
*  read table lt_return INTO DATA(ls_return) INDEX 1.
*  cv_vbeln = ls_return-fieldval.
*ENDFORM.
