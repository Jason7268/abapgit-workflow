*&---------------------------------------------------------------------*
*& Report ZHIEN_ABAP_EX3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_abap_ex3.
TABLES zhien_product_db.
SELECT-OPTIONS: so_proid FOR zhien_product_db-productid,
                so_ppri FOR zhien_product_db-pricep.

PARAMETERS p_year TYPE zhien_product_db-yearp.
PARAMETERS p_pron TYPE zhien_product_db-productname.
PARAMETERS      p_CURR TYPE zhien_product_db-currency  AS LISTBOX
                        VISIBLE LENGTH 25
                        OBLIGATORY
                        DEFAULT 'VND'.


TYPES ty_t_product TYPE STANDARD TABLE OF zhien_product_db.

DATA : gt_product TYPE ty_t_product.

DATA: lv_String TYPE String,
      lt_fieldcat TYPE slis_t_fieldcat_alv,
      ls_fieldcat TYPE slis_fieldcat_alv,
      ls_layout   TYPE slis_layout_alv.




INITIALIZATION.
* Initialize data for dropdownlist
  PERFORM init_data.

START-OF-SELECTION.
*- 1. Get Data from product table
  PERFORM get_product CHANGING gt_product.
*- 2. Write data
  PERFORM write_product USING gt_product.

*  PERFORM build_fieldcat.
*  PERFORM layout_setup.
*  PERFORM display_data.


*&---------------------------------------------------------------------*
*& Form GET_PRODUCT
*&---------------------------------------------------------------------*
*& Get Data from product table
*&---------------------------------------------------------------------*
*&      <-- U_t_product
*&---------------------------------------------------------------------*
FORM get_product  CHANGING C_t_product TYPE ty_t_product.
  SELECT * FROM zhien_product_db AS t
           INTO TABLE @c_t_product UP  TO 10 ROWS
           WHERE t~productid IN @so_proid
             AND ( ( ( t~pricep * 100 IN @so_ppri ) AND t~currency = 'VND' )
                OR ( ( t~pricep * 100 IN @so_ppri ) AND t~currency = 'USD' ) )
             AND  t~currency = @p_CURR.
  IF sy-subrc = 0.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_PRODUCT
*&---------------------------------------------------------------------*
*& Write data
*&---------------------------------------------------------------------*
*&      --> U_t_product
*&---------------------------------------------------------------------*
FORM write_product  USING    U_t_product TYPE ty_t_product.

  DATA: lv_sum   TYPE p DECIMALS 2,
        lv_sum_2 TYPE zhien_product_db-pricep.
  SKIP 1.
  WRITE:/ sy-uline(65).
  WRITE:/
        '|' , 2 'STT' ,          5   '|',
              6 'PRODUCTID',      15 '|',
              16 'PRODUCT NAME',  35 '|',
              36 'YEAR' ,         40 '|',
              45 'PRICE' ,        56 '|',
              57 'CURRENCY',      65 '|',
                  sy-uline(65).


  IF U_t_product IS NOT INITIAL.

    LOOP AT U_t_product INTO DATA(ls_product).
      lv_sum += ls_product-pricep.
      WRITE:/'|' ,2   sy-tabix LEFT-JUSTIFIED,                                          5 '|',
                 6   ls_product-productid CENTERED COLOR 6,                             15 '|',
                 16   ls_product-productname,                                           35 '|',
                 36   ls_product-yearp,                                                 40 '|',
                 41   ls_product-pricep CURRENCY ls_product-currency CENTERED,          56 '|',
                 57   ls_product-currency CENTERED,                                     65 '|'.
    ENDLOOP.
    WRITE:/ sy-uline(65).
    WRITE :/'|' , 16   'TOTAL: ' ,
                  40   lv_sum CURRENCY ls_product-currency CENTERED,
                  57   ls_product-currency CENTERED,                65 '|'.
    WRITE:/ sy-uline(65).

*    ULINE.

*    CALL FUNCTION 'ZKHOI_TINH_TONG'
*      EXPORTING
*        iv_year                 = p_year
*      IMPORTING
*        ev_tong                 = lv_sum_2
*      TABLES
*        it_product              = U_t_product
*      EXCEPTIONS
*        check_year_greater_zero = 1
*        OTHERS                  = 2.
*    IF sy-subrc = 0.
** Implement suitable error handling here
*      WRITE: 'Tong cua nam ', p_year , ' : ' , lv_sum_2 CURRENCY ls_product-currency.
*    ENDIF.
*
*    ULINE.
*    lv_String = p_pron.
*    CALL FUNCTION 'ZDAT_TINH_TONG_THEO_TEXT'
*      EXPORTING
*        iv_input_text         = lv_String
*      IMPORTING
*        ev_sum_product        = lv_sum_2
*      TABLES
*        it_product            = U_t_product
*      EXCEPTIONS
*        not_special_character = 1
*        OTHERS                = 2.
*    WRITE: 'San pham :', p_pron , ' : ' , lv_sum_2 CURRENCY ls_product-currency.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.



  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_data .

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = CONV vrm_id( 'p_CURR' )
      values          = VALUE vrm_values( ( key = 'VND' text = 'VND' )
                                        ( key = 'USD' text = 'USD' ) )
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE 'Cannot initialize List Box Distance Unit.' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_fieldcat .
  CLEAR ls_fieldcat.
  REFRESH lt_fieldcat.

*    ls_fieldcat-key = space.
*  ls_fieldcat-fieldname = 'CARRID'.
*  ls_fieldcat-seltext_s = 'Air.L'.
*  ls_fieldcat-seltext_m = 'AirLine'.
*  ls_fieldcat-seltext_l = 'Airline'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*  CLEAR ls_fieldcat.

  ls_fieldcat-key = 'X'.
  ls_fieldcat-fieldname = 'productid'.
  ls_fieldcat-seltext_s = 'pro id'.
  ls_fieldcat-seltext_m = 'product id'.
  ls_fieldcat-seltext_l = 'product id'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-key = space.
  ls_fieldcat-fieldname = 'productname'.
  ls_fieldcat-seltext_s = 'pro.name'.
  ls_fieldcat-seltext_m = 'product name'.
  ls_fieldcat-seltext_l = 'product name'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-key = space.
  ls_fieldcat-fieldname = 'yearp'.
  ls_fieldcat-seltext_s = 'year'.
  ls_fieldcat-seltext_m = 'year'.
  ls_fieldcat-seltext_l = 'year'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-key = space.
  ls_fieldcat-fieldname = 'PRICEP'.
  ls_fieldcat-seltext_s = 'Pro.pr'.
  ls_fieldcat-seltext_m = 'Pro price'.
  ls_fieldcat-seltext_l = 'Pro price'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.


  ls_fieldcat-key = space.
  ls_fieldcat-fieldname = 'CURRENCY'.
  ls_fieldcat-seltext_s = 'Pro.C'.
  ls_fieldcat-seltext_m = 'Product Curr'.
  ls_fieldcat-seltext_l = 'Product Currency'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form layout_setup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM layout_setup .

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      = ' '
*     I_BUFFER_ACTIVE         = ' '
      i_callback_program      = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     I_BACKGROUND_ID         = ' '
*     I_GRID_TITLE            =
*     I_GRID_SETTINGS         =
      is_layout               = ls_layout
      it_fieldcat             = lt_fieldcat
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
*     IT_SORT                 =
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_DEFAULT               = 'X'
*     I_SAVE                  = ' '
*     IS_VARIANT              =
*     IT_EVENTS               =
*     IT_EVENT_EXIT           =
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     I_HTML_HEIGHT_TOP       = 0
*     I_HTML_HEIGHT_END       = 0
*     IT_ALV_GRAPHICS         =
*     IT_HYPERLINK            =
*     IT_ADD_FIELDCAT         =
*     IT_EXCEPT_QINFO         =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER =
*     IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = gt_product
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc = 0.
*     Implement suitable error handling here
  ENDIF.

ENDFORM.


FORM top_of_page.

  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.

  ls_header-typ = 'H'.
  ls_header-info = 'This is header text'.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'S'.
  ls_header-info = 'This is Selection text'.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'A'.
  ls_header-info = 'This is Action text'.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary       = lt_header.
  IF sy-subrc = 0.
    CLEAR sy-subrc.
  ENDIF.


ENDFORM.

FORM USER_COMMAND USING iv_ucomm TYPE sy-ucomm
                        is_seltext TYPE slis_selfield.

READ TABLE gt_product INTO DATA(ls_product) INDEX is_seltext-tabindex.
  IF sy-subrc = 0.
  MESSAGE i000(ZHIEN_MSG) WITH ls_product-productid
                               ls_product-productname
                               ls_product-pricep  .
  ENDIF.

ENDFORM.
