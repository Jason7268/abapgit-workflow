*&---------------------------------------------------------------------*
*& Include          ZHIEN_SO_UPLOADF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form main_processing
*&---------------------------------------------------------------------*
*& Main Processing
*&---------------------------------------------------------------------*

FORM main_processing .
*  DATA: lt_upload TYPE ty_t_upload.
*    DATA: lt_db_datahd TYPE ty_t_log.

  DATA: lt_soheader    TYPE STANDARD TABLE OF  zhien_vbak,  "internal table so header
        lt_soitem      TYPE STANDARD TABLE OF zhien_vbap,  "internal table so item
        lt_material    TYPE ty_t_material,   "internal table material
        lt_customer    TYPE ty_t_customer, "internal table customer
        lt_ordernumb   TYPE ty_t_ordernumb, "internal table list so number IN ZHIEN_VBAK
        lt_ordernumb2  TYPE ty_t_ordernumb, "internal table list so number to count so number error
        lt_ordernumb3  TYPE ty_t_ordernumb, "internal table list so number IN SO HEADER UPLOAD TO COUNT SO UPLOADED
        lt_itemnumb    TYPE ty_t_itemnumb, "internal table item number to check exist
        lt_comcode     TYPE ty_t_comcode , "internal table company code to check exist
        lt_upload1     TYPE ty_t_upload, "internal table upload data
        lt_upload2     TYPE ty_t_upload, "internal table upload data
        lt_error       TYPE ty_t_log, "internal table error
        lt_error_final TYPE ty_t_log, "internal table error
        lv_flag        TYPE char1,    " FLAG TO SHOW ALV LIST ERROR
        lt_fieldcat    TYPE slis_t_fieldcat_alv,           " show alv
        ls_fieldcat    TYPE slis_fieldcat_alv,
        ls_layout      TYPE slis_layout_alv.


  " call upload file
  REFRESH : lt_upload1, lt_upload2 .
  PERFORM upload_file USING p_psohd CHANGING lt_upload1.
  PERFORM upload_file USING p_psoit CHANGING lt_upload2.

  " get master data to check exist
  PERFORM get_material CHANGING lt_material.
  SORT lt_material BY matnr ASCENDING.

* *get list customer number to check exist
  PERFORM get_customer CHANGING lt_customer.
  SORT lt_customer BY kunnr ASCENDING.

*get list vbeln number to check exist
  PERFORM get_ordernumb CHANGING lt_ordernumb.
  SORT lt_ordernumb BY vbeln ASCENDING.

*get list vbeln vblp number from item to check exist
  PERFORM get_itemnumb CHANGING lt_itemnumb .
  SORT lt_itemnumb BY zzvbeln zzvbelp ASCENDING.

* get list vbeln vblp number from item to check exist
  PERFORM get_comcode CHANGING lt_comcode .
  SORT lt_comcode BY bukrs ASCENDING.

  " process data for header
*-----------------------PROCESS DATA FOR HEADER--------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------------
  PERFORM process_data_head USING   lt_upload1     " data uoload for header
                                    lt_customer    " itab for check customer
                                    lt_ordernumb   " itab for check order number
                                    lt_comcode     " itab for check company code
                           CHANGING lt_soheader    " itab header data
                                    lt_error      " itab error
                                    lt_ordernumb3.  " itab for get order number upload

*  prepdate data for insert
  DELETE ADJACENT DUPLICATES FROM lt_error COMPARING ALL FIELDS. "Del duplicate itab erro

  PERFORM insert_header USING lt_soheader.

*  WAIT UP TO 3 SECONDS.
  MOVE-CORRESPONDING lt_error TO lt_error_final.
  REFRESH lt_error.
*  get list vbeln number again to check exist
  REFRESH lt_ordernumb.
  PERFORM get_ordernumb CHANGING lt_ordernumb.
  SORT lt_ordernumb BY vbeln ASCENDING.

*-----------------------PROCESS DATA FOR ITEM--------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------------
  PERFORM process_data_item USING   lt_upload2     " data uoload for header
                                    lt_material    " itab for check material
                                    lt_ordernumb   " itab for check head order number
                                    lt_itemnumb    "itab for check item number
                           CHANGING lt_soitem      " itab item data
                                    lt_error      " itab error
                                    lt_ordernumb3.  " itab for get order number upload
  SORT lt_soitem BY zzvbeln zzvbelp.
  DESCRIBE TABLE lt_soitem LINES DATA(lv_countit).
  IF lv_countit > 0.

*  prepdate data for insert
    DELETE ADJACENT DUPLICATES FROM lt_error COMPARING ALL FIELDS. "Del duplicate itab erro

    " move data to other itbab to del duplicate- to count so error
    REFRESH lt_ordernumb2.
*    MOVE-CORRESPONDING lt_error TO lt_ordernumb2.
    APPEND LINES OF lt_error TO lt_ordernumb2.

    DELETE ADJACENT DUPLICATES FROM lt_ordernumb2 COMPARING vbeln.
    SORT lt_ordernumb2 by vbeln.
    PERFORM del_error_item USING    lt_ordernumb2   " itab error.     " Del line error from item
                           CHANGING lt_soitem.     " itab item data
"   Insert data to item so
    PERFORM insert_item   USING lt_soitem.
*                          CHANGING lt_error.

    DELETE ADJACENT DUPLICATES FROM lt_error COMPARING ALL FIELDS. "Del duplicate itab erro
    IF lt_error IS NOT INITIAL.
      MOVE-CORRESPONDING lt_error TO lt_error_final KEEPING TARGET LINES.
    ENDIF.
  ENDIF.

    DELETE ADJACENT DUPLICATES FROM lt_error_final COMPARING ALL FIELDS.
    SORT lt_error_final BY vbeln.

        " move data to other itbab to del duplicate- to count so error
    REFRESH lt_ordernumb2.
*    MOVE-CORRESPONDING lt_error TO lt_ordernumb2.
    APPEND LINES OF lt_error_final TO lt_ordernumb2.

    " get so number erro final
   " del duplicate and count line
    DELETE ADJACENT DUPLICATES FROM lt_ordernumb2 COMPARING vbeln.
    SORT lt_ordernumb2 by vbeln.

   " get so number upload from file
   " del duplicate and count line
  DELETE ADJACENT DUPLICATES FROM lt_ordernumb3 COMPARING vbeln.
  SORT lt_ordernumb3 BY vbeln.

  DATA: lt_ordernumb4  TYPE  ty_t_ordernumb.
  "slect base on lt_ordernumb3 to get so upload success
  SELECT DISTINCT h~zzvbeln AS vbeln
    INTO CORRESPONDING FIELDS OF TABLE @lt_ordernumb4
    FROM         zhien_vbak AS h
      INNER JOIN zhien_vbap AS i
       ON h~zzvbeln = i~zzvbeln
    FOR ALL ENTRIES IN @lt_ordernumb3
    WHERE h~zzvbeln = @lt_ordernumb3-vbeln.

  DELETE ADJACENT DUPLICATES FROM lt_ordernumb4 COMPARING vbeln.
  SORT lt_ordernumb4 BY vbeln.

  " Count so number upload
   DESCRIBE TABLE lt_ordernumb3 LINES gv_counthd. "count so number
  DESCRIBE TABLE lt_ordernumb4 LINES gv_soupload. "count so number
  DESCRIBE TABLE lt_ordernumb2 LINES gv_countso_error. " count so error
*  gv_soupload      = gv_counthd - gv_countso_error. " get so uploaded

*       build fieldcat ALV
  PERFORM build_fieldcat CHANGING lt_fieldcat.
*       layout setup ALV
  PERFORM layout_setup CHANGING ls_layout.

*    SORT lt_error by vbeln level ASCENDING.
*    DELETE ADJACENT DUPLICATES FROM lt_error COMPARING ALL FIELDS. "Del duplicate itab erro
*       display data ALV
  PERFORM display_data USING    lt_fieldcat
                                ls_layout
                                lt_error_final.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form open_file_dialog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM open_file_dialog CHANGING   u_value TYPE string.
  CLEAR u_value.
  DATA: lt_file_table TYPE filetable,
        ld_rc         TYPE i.
  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title            = CONV string( 'OPEN SO TEMPLATE FILE' ) " Title Of File Open Dialog
      default_extension       = CONV string( 'TXT' )                 " Default Extension
    CHANGING
      file_table              = lt_file_table    " Table Holding Selected Files
      rc                      = ld_rc             " Return Code, Number of Files or -1 If Error Occurred
    EXCEPTIONS
      file_open_dialog_failed = 1                " "Open File" dialog failed
      cntl_error              = 2                " Control error
      error_no_gui            = 3                " No GUI available
      not_supported_by_gui    = 4                " GUI does not support this
      OTHERS                  = 5
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE lt_file_table INDEX 1 INTO DATA(ls_file).
    IF sy-subrc = 0.
      u_value = ls_file-filename.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form validate_inputs
*&---------------------------------------------------------------------*
*& validate_inputs data
*&---------------------------------------------------------------------*

FORM validate_inputs .
  PERFORM check_required_fields USING p_psohd 'Local Header File '.
  PERFORM check_required_fields USING p_psoit 'Local Item File' .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_required_fields
*&---------------------------------------------------------------------*
*& Check input data
*&---------------------------------------------------------------------*

FORM check_required_fields  USING    u_value TYPE any
                                     u_field_name TYPE string.

  IF u_value IS INITIAL.
    MESSAGE | Vui lòng nhập dữ liệu vào trường { u_field_name }.| TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_data_to_itab
*&---------------------------------------------------------------------*
*& Get data from local to table
*&---------------------------------------------------------------------*
*&      --> P_PSOHD
*&      <-- LT_UPLOAD
*&---------------------------------------------------------------------*
FORM upload_file  USING    u_path TYPE string
                          CHANGING c_t_upload TYPE ty_t_upload.
  DATA: Lv_subrc(2).
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = u_path
      filetype                = 'ASC'
      has_field_separator     = 'X'
      codepage                = '4110'
    TABLES
      data_tab                = c_t_upload
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    lv_subrc = sy-subrc.
    MESSAGE | ERROR : { sy-subrc }.PLEASE CHECK FILE AGAIN . | TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_material
*&---------------------------------------------------------------------*
*& get material
*&---------------------------------------------------------------------*
*&      <-- LT_MATERIAL
*&---------------------------------------------------------------------*
FORM get_material  CHANGING c_t_material TYPE ty_t_material.
  SELECT DISTINCT zzmatnr
    FROM zhien_mara
    INTO TABLE @c_t_material.
  IF sy-subrc <> 0.
    "DO SOMETHING
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form lt_customer
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_MATERIAL
*&---------------------------------------------------------------------*
FORM get_customer  CHANGING c_t_customer TYPE ty_t_customer.
  SELECT DISTINCT zzcustomer
FROM zhien_kna1
    INTO TABLE @c_t_customer.
  IF sy-subrc <> 0.
    "DO SOMETHING
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_ordernumb
*&---------------------------------------------------------------------*
*& get list orderhead number
*&---------------------------------------------------------------------*
*&      <-- LT_ORDERNUMB
*&---------------------------------------------------------------------*
FORM get_ordernumb  CHANGING u_t_ordernumb.

  SELECT DISTINCT zzvbeln
FROM zhien_vbak
    INTO TABLE @u_t_ordernumb.
  IF sy-subrc <> 0.
    "DO SOMETHING
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_itemnumb
*&---------------------------------------------------------------------*
*& get item number and vbelp
*&---------------------------------------------------------------------*
*&      <-- LT_ITEMNUMB
*&---------------------------------------------------------------------*
FORM get_itemnumb  CHANGING u_t_itemnumb TYPE ty_t_itemnumb.
  SELECT DISTINCT zzvbeln, zzvbelp
FROM zhien_vbap
    INTO TABLE @u_t_itemnumb.
  IF sy-subrc <> 0.
    "DO SOMETHING
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_comcode
*&---------------------------------------------------------------------*
*& get company code
*&---------------------------------------------------------------------*
*&      <-- LT_ITEMNUMB
*&---------------------------------------------------------------------*
FORM get_comcode CHANGING u_t_comcode TYPE ty_t_comcode.
  SELECT DISTINCT bukrs
FROM t001
    INTO TABLE @u_t_comcode.
  IF sy-subrc <> 0.
    "DO SOMETHING
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form process_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_UPLOAD1
*&      --> LT_UPLOAD2
*&      <-- LT_SOHEADER
*&      <-- LT_SOITEM
*&---------------------------------------------------------------------*
FORM process_data_head USING    u_t_upload TYPE ty_t_upload
                                u_t_customer  TYPE ty_t_customer
                                u_t_ordernumb TYPE ty_t_ordernumb
                                u_t_comcode TYPE ty_t_comcode
                       CHANGING c_t_soheader  TYPE ty_t_soheader
                                c_t_error     TYPE ty_t_log
                                c_t_ordernumb3  TYPE ty_t_ordernumb.
  DATA: lv_flag       TYPE char1.
  " lv_headnumber TYPE zhien_vbak-zzvbeln.
  "process data for header
  DATA: lv_wkurs    TYPE string,
        lv_menge    TYPE string,
        lv_netpr    TYPE string,
        lv_TAXRT    TYPE string,
        ls_header   TYPE zhien_vbak,
        ls_item     TYPE zhien_vbap,
        ls_data     TYPE ty_upload,
        ls_error    TYPE ty_log,
        lv_sonumber TYPE ty_ordernumb
        .

  LOOP AT  u_t_upload INTO ls_data.
    CLEAR lv_flag .
    TRY .
        SPLIT ls_data-col1 AT '|' INTO  ls_header-zzvbeln
                                  ls_header-zzcustomer
                                  ls_header-zzstatu
                                  ls_header-zzerdat
                                  ls_header-zzernam
                                  ls_header-zzwaers
                                  lv_wkurs
                                  ls_header-zzpotxt
                                  ls_header-zzbukrs.

        IF lv_wkurs >= 10000.  " process when lv_wkurs >= 10000.
          CLEAR lv_wkurs.
          ls_error-vbeln = ls_header-zzvbeln.
          ls_error-level = 'Header'.
          ls_error-message = 'Entry is too long: Only 4 digits are allowed in the whole number part'.
          APPEND ls_error TO c_t_error.
          lv_flag = abap_true .
          CLEAR : ls_error.
        ELSE.
          ls_header-zzwkurs  =  CONV zdehien_wkurs( lv_wkurs ).
        ENDIF.
      CATCH cx_sy_conversion_no_number INTO DATA(lv_ex).
        ls_error-vbeln = ls_header-zzvbeln.
        ls_error-level = 'Header'.
        ls_error-message = lv_ex->get_text( ).
        lv_flag  = abap_true.
        APPEND ls_error TO c_t_error.
        CLEAR ls_error.


    ENDTRY.

    CLEAR : ls_error.
    PERFORM validate_header USING ls_header
                                  u_t_customer
                                  u_t_ordernumb
                                  u_t_comcode
                            CHANGING c_t_error " validate header data
                                     lv_flag.   " flag error

    IF ls_error IS NOT INITIAL. "validate data get error
*      APPEND ls_error TO c_t_error.

    ENDIF.
    IF lv_flag IS INITIAL.
      "validate data no error
      APPEND ls_header TO c_t_soheader .
    ENDIF.

    "Save so number from upload data
    APPEND ls_header-zzvbeln TO c_t_ordernumb3.
    " gv_counthd += 1.

    CLEAR: ls_data,ls_header, ls_error,lv_flag,lv_sonumber .

  ENDLOOP.

ENDFORM.

FORM process_data_item USING  u_t_upload    TYPE ty_t_upload
                              u_t_material  TYPE ty_t_material
                              u_t_ordernumb TYPE ty_t_ordernumb
                              u_t_itemnumb  TYPE ty_t_itemnumb
                     CHANGING c_t_soitem    TYPE ty_t_soitem
                              c_t_error     TYPE ty_t_log
                              c_t_ordernumb3  TYPE ty_t_ordernumb.
  DATA: lv_flag       TYPE Char1,
        lv_headnumber TYPE zhien_vbak-zzvbeln.
  "process data for header
  DATA: lv_wkurs  TYPE string,
        lv_menge  TYPE string,
        lv_netpr  TYPE string,
        lv_TAXRT  TYPE string,
        ls_header TYPE zhien_vbak,
        ls_item   TYPE zhien_vbap,
        ls_data   TYPE ty_upload,
        ls_error  TYPE ty_log.

  "process data for item
  CLEAR: ls_data,ls_item.
  LOOP AT  u_t_upload INTO ls_data.
    TRY .
        SPLIT ls_data-col1 AT '|' INTO  ls_item-zzvbeln
                                        ls_item-zzvbelp
                                        ls_item-zzmatnr
                                        lv_menge
                                        ls_item-zzmeins
                                        lv_netpr
                                        lv_TAXRT
                                        ls_item-zzeindt
                                        ls_item-zzittxt
                                        ls_item-zzwerks.
        ls_item-zzmenge  =  CONV meng15( lv_menge ).
        ls_item-zznetpr  =  CONV netpr( lv_netpr ).
        ls_item-zztaxrt  =  CONV kbetr_kond( lv_TAXRT ).

      CATCH cx_sy_conversion_no_number INTO DATA(lv_ex).
        ls_error-vbeln = ls_item-zzvbeln.
        ls_error-level = 'Item'.
        ls_error-message = lv_ex->get_text( ).
        lv_flag  = abap_true.
        APPEND ls_error TO c_t_error.
        CLEAR ls_error.
    ENDTRY.

    " Validate item data
    PERFORM validate_item USING ls_item
                                u_t_material
                                u_t_ordernumb
                                u_t_itemnumb
                          CHANGING c_t_error
                                   lv_flag.   " flag error

    IF lv_flag IS NOT INITIAL. "validate data get error
*
*      APPEND ls_error     TO c_t_error.
*      CLEAR: ls_data,ls_header, ls_error.
    ELSE.                      "validate data no error
      APPEND ls_item TO c_t_soitem .
    ENDIF.

        "Save so number from upload data
    IF lv_headnumber is INITIAL or lv_headnumber <> ls_item-zzvbeln.
      lv_headnumber = ls_item-zzvbeln.
*      lv_sonumber-vbeln = ls_item-zzvbeln.
      APPEND lv_headnumber TO c_t_ordernumb3.
    ENDIF.

    CLEAR: ls_data,ls_item, ls_error, lv_flag,lv_headnumber.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form validate_header
*&---------------------------------------------------------------------*
*& process data for header and item
*&---------------------------------------------------------------------*
*&      --> LS_HEADER
*&      <-- LS_ERROR
*&---------------------------------------------------------------------*
FORM validate_header  USING    u_s_header   TYPE zhien_vbak
                               u_t_customer TYPE ty_t_customer
                               u_t_ordernumb TYPE ty_t_ordernumb
                               u_t_comcode TYPE ty_t_comcode
                      CHANGING c_t_error    TYPE ty_t_log
                               c_flag       TYPE char1.
  DATA ls_error TYPE ty_log.
  DATA lv_flag TYPE char1. " flag to add error
  DATA lv_customer TYPE char10.

  " ADD LEADING ZERO to customer id
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = u_s_header-zzcustomer
    IMPORTING
      output = lv_customer.
  "check customer exist
  READ TABLE u_t_customer WITH KEY kunnr = lv_customer TRANSPORTING NO FIELDS
  BINARY SEARCH.
  IF sy-subrc <> 0.
    ls_error-vbeln = u_s_header-zzvbeln.
    ls_error-level = 'Header'.
    ls_error-message = |Customer: | && u_s_header-zzcustomer && | does not exist|.
    lv_flag  = abap_true.
    APPEND ls_error TO c_t_error.
    CLEAR ls_error.
  ENDIF.

  DATA lv_type TYPE datatype_d.
  " CHECK COMPANY CODE IS NUMBER
  READ TABLE u_t_comcode WITH KEY bukrs = u_s_header-zzbukrs TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    ls_error-vbeln = u_s_header-zzvbeln.
    ls_error-level = 'Header'.
    ls_error-message = |Company code: | && u_s_header-zzbukrs && | is not exist!|.
    lv_flag  = abap_true.
    APPEND ls_error TO c_t_error.
    CLEAR ls_error.
  ENDIF.


  "check order number exist
  READ TABLE u_t_ordernumb WITH KEY vbeln = u_s_header-zzvbeln TRANSPORTING NO FIELDS
  BINARY SEARCH.
  IF sy-subrc = 0.
    ls_error-vbeln = u_s_header-zzvbeln.
    ls_error-level = 'Header'.
    ls_error-message = |Sales order already exist|.
    lv_flag  = abap_true.
    APPEND ls_error TO c_t_error.
    CLEAR ls_error.
  ENDIF.

  IF lv_flag IS INITIAL..
    CLEAR ls_error.
  ELSE.
    c_flag = lv_flag.
  ENDIF.
  CLEAR lv_flag.
  " Add more header validations as needed
ENDFORM.
*&---------------------------------------------------------------------*
*& Form validate_item
*&---------------------------------------------------------------------*
*& validate item
*&---------------------------------------------------------------------*
*&      --> LS_ITEM
*&      --> U_T_MATERIAL
*&      <-- LS_ERROR
*&---------------------------------------------------------------------*
FORM validate_item  USING    u_s_item      TYPE zhien_vbap
                             u_t_material  TYPE ty_t_material
                             u_t_ordernumb TYPE ty_t_ordernumb
                             u_t_itemnumb TYPE ty_t_itemnumb
                    CHANGING c_t_error     TYPE ty_t_log
                             c_flag        TYPE char1.
  DATA ls_error TYPE ty_log.

  DATA lv_flag TYPE char1. " flag to add error

  DATA lv_material TYPE char18.

  " ADD LEADING ZERO to customer id
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = u_s_item-zzmatnr
    IMPORTING
      output = lv_material.

  " check if material is not intial
  IF u_s_item-zzmatnr IS INITIAL.
    ls_error-vbeln = u_s_item-zzvbeln.
    ls_error-level = 'Item'.
    ls_error-message = |Item | && u_s_item-zzvbelp && |- Materials cannot be left blank|.
    lv_flag = abap_true.
    APPEND ls_error TO c_t_error.
    CLEAR ls_error.
  ELSE.   " Check if material exists

    READ TABLE u_t_material WITH KEY matnr = lv_material TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      ls_error-vbeln = u_s_item-zzvbeln.
      ls_error-level = 'Item'.
      ls_error-message = |Item | && u_s_item-zzvbelp && |- Material | && u_s_item-zzmatnr && | does not exist|.
      lv_flag = abap_true.
      APPEND ls_error TO c_t_error.
      CLEAR ls_error.
    ENDIF.

  ENDIF.

  " Check quantity
  IF u_s_item-zzmenge <= 0.
    ls_error-vbeln = u_s_item-zzvbeln.
    ls_error-level = 'Item'.
    ls_error-message = | Item - | && u_s_item-zzvbelp && |- Quantity must be greater than zero|.
    lv_flag = abap_true.
    APPEND ls_error TO c_t_error.
    CLEAR ls_error.
  ENDIF.

  "check order number exist
  READ TABLE u_t_ordernumb WITH KEY vbeln = u_s_item-zzvbeln TRANSPORTING NO FIELDS
  BINARY SEARCH.
  IF sy-subrc <> 0.
    ls_error-vbeln = u_s_item-zzvbeln.
    ls_error-level = 'Item'.
    ls_error-message = |Sales order does not exist|.
    lv_flag  = abap_true.
    APPEND ls_error TO c_t_error.
    CLEAR ls_error.
  ENDIF.

  "check item number exist
  READ TABLE u_t_itemnumb WITH KEY zzvbeln = u_s_item-zzvbeln
                                   zzvbelp = u_s_item-zzvbelp
                          TRANSPORTING NO FIELDS
                          BINARY SEARCH.
  IF sy-subrc = 0.
    ls_error-vbeln = u_s_item-zzvbeln.
    ls_error-level = 'Item'.
    ls_error-message = |Sales order and Item - | && u_s_item-zzvbelp && | were exist|.
    lv_flag  = abap_true.
    APPEND ls_error TO c_t_error.
    CLEAR ls_error.
  ENDIF.

  "Check date
  DATA(lv_date) = u_s_item-zzeindt  . " YYYYMMDD
  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = lv_date
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_msg).
    ls_error-vbeln = u_s_item-zzvbeln.
    ls_error-level = 'Item'.
    ls_error-message = |Item | && u_s_item-zzvbelp && |-| && lv_msg.
    lv_flag = abap_true.
    APPEND ls_error TO c_t_error.
    CLEAR ls_error.
  ELSE.
    " do something
  ENDIF.

  IF lv_flag IS INITIAL..
    CLEAR ls_error.
  ELSE.
    c_flag = lv_flag.
  ENDIF.

  CLEAR lv_flag.
  " Add more item validations as needed
ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_fieldcat
*&---------------------------------------------------------------------*
*& build fieldcat for alv list
*&---------------------------------------------------------------------*
*&      <-- LT_FIELDCAT
*&---------------------------------------------------------------------*
FORM build_fieldcat  CHANGING c_t_fieldcat TYPE slis_t_fieldcat_alv.
  DATA ls_fieldcat TYPE slis_fieldcat_alv.
  CLEAR ls_fieldcat.
  REFRESH c_t_fieldcat.

  ls_fieldcat-key = 'X'.
  ls_fieldcat-fieldname = 'Vbeln'.
  ls_fieldcat-seltext_s = 'Sale Order'.
  ls_fieldcat-seltext_m = 'Sale Order Number'.
  ls_fieldcat-seltext_l = 'Sale Order Number'.
  APPEND ls_fieldcat TO c_t_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-key = 'X'.
  ls_fieldcat-fieldname = 'Level'.
  ls_fieldcat-seltext_s = 'Level'.
  ls_fieldcat-seltext_m = 'Level'.
  ls_fieldcat-seltext_l = 'Level'.
  APPEND ls_fieldcat TO c_t_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-key = space.
  ls_fieldcat-fieldname = 'Message'.
  ls_fieldcat-seltext_s = 'Error mess'.
  ls_fieldcat-seltext_m = 'Error message'.
  ls_fieldcat-seltext_l = 'Error message'.
  APPEND ls_fieldcat TO c_t_fieldcat.
  CLEAR ls_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form layout_setup
*&---------------------------------------------------------------------*
*& Set up layout
*&---------------------------------------------------------------------*
*&      <-- LS_LAYOUT
*&---------------------------------------------------------------------*
FORM layout_setup  CHANGING ls_layout TYPE slis_layout_alv..
  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = abap_true.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& display data alv
*&---------------------------------------------------------------------*
*&      --> LT_FIELDCAT
*&      --> LS_LAYOUT
*&      --> LT_ERROR
*&---------------------------------------------------------------------*
FORM display_data  USING    u_t_fieldcat TYPE slis_t_fieldcat_alv
                            u_s_layout   TYPE slis_layout_alv
                            u_t_error    TYPE ty_t_log.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
*     i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      is_layout                = u_s_layout
      it_fieldcat              = u_t_fieldcat
    TABLES
      t_outtab                 = u_t_error
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc = 0.
*     Implement suitable error handling here
  ENDIF.

ENDFORM.

*SET PF-STATUS 'STATUS_TEST'.
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STATUS_TEST'.
  "Copy of 'STANDARD' pf_status from fgroup SALV
ENDFORM.

FORM top_of_page.

  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.

  ls_header-typ = 'H'.
  ls_header-info = |Total So: | && gv_counthd.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'S'.
  ls_header-info = |So Uploaded: | && gv_soupload.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'A'.
  ls_header-info = |So Error: | && gv_countso_error.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

  IF sy-subrc = 0.
    CLEAR sy-subrc.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form Handle_Ucomm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM Handle_Ucomm .
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' .
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SOHEADER
*&---------------------------------------------------------------------*
FORM insert_header  USING    u_t_soheader TYPE ty_t_soheader.
  DATA: ls_return TYPE bapiret2,
        lv_rows   TYPE i.
  DATA: lt_vbak TYPE STANDARD TABLE OF zhien_vbak.

  IF u_t_soheader IS NOT INITIAL.
    MOVE-CORRESPONDING u_t_soheader TO lt_vbak.
    TRY.
        INSERT zhien_vbak FROM TABLE @lt_vbak.
        IF sy-subrc = 0.
          MESSAGE s208(00) WITH 'Inserted records successfully.'.
        ENDIF.
*    " Commit the database changes
        COMMIT WORK AND WAIT.

      CATCH cx_sy_open_sql_db INTO DATA(lx_root).
        " Handle exceptions
        MESSAGE e208(00) WITH 'Error during insert:' lx_root->get_text( )
          INTO ls_return-message.
        ls_return-type = 'E'.

        " Rollback in case of error
        ROLLBACK WORK.
    ENDTRY.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SOITEM
*&---------------------------------------------------------------------*
FORM insert_item  USING    u_t_soitem TYPE ty_t_soitem.
*                  CHANGING c_t_error  TYPE ty_t_log.
  TRY .
      MODIFY zhien_vbap FROM TABLE @u_t_soitem.
          IF sy-subrc = 0. " check if success
            COMMIT WORK AND WAIT.
            MESSAGE 'Insert success' TYPE 'S'.
          ELSE.  " do it false
*        Rollback in case of error
             MESSAGE 'Insert false' TYPE 'E'.
            ROLLBACK WORK.
          ENDIF.
  CATCH cx_sy_open_sql_db INTO DATA(lv_EX).
    MESSAGE |Insert false -| && lv_ex->get_text( ) TYPE 'E'.
  ENDTRY.

*  DATA: lt_vbap TYPE STANDARD TABLE OF zhien_vbap.
*  DATA: ls_log TYPE ty_log.

*  IF u_t_soitem IS NOT INITIAL.
*    MOVE-CORRESPONDING u_t_soitem TO lt_vbap.
**    INSERT zhien_vbak from TABLE @u_t_soheader.
**    IF s.
**    Use TRY-CATCH for error handling
*
*
*    LOOP AT lt_vbap INTO DATA(ls_vbap).
*      TRY.
*          "Insert data to Zhien_vbap
*          INSERT Zhien_vbap FROM @ls_vbap.
*
*          IF sy-subrc = 0. " check if success
*            COMMIT WORK AND WAIT.
**            ls_log-vbeln   =  ls_vbap-zzvbeln.
**            ls_log-message = ls_vbap-zzvbelp && |Inserted records successfully.|.
*          ELSE.  " do it false
**        Rollback in case of error
*            ROLLBACK WORK.
*            ls_log-vbeln   =  ls_vbap-zzvbeln.
*            ls_log-level   =  |Item|.
*            ls_log-message = ls_vbap-zzvbelp && |- Inserted records false, Please check data.|.
*          ENDIF.
*
*        CATCH cx_sy_open_sql_db INTO DATA(lf_err).
*          ls_log-vbeln   =  ls_vbap-zzvbeln.
*          ls_log-level   =  |Item|.
*          ls_log-message =  ls_vbap-zzvbelp && | - | && lf_err->get_text( ) .
*
*      ENDTRY.
*      IF ls_log IS NOT INITIAL.
*        APPEND ls_log TO c_t_error.
*        CLEAR ls_log.
*      ENDIF.
*
*    ENDLOOP.
**    WRITE:/.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_error_head
*&---------------------------------------------------------------------*
*& Delete data line error at header
*&---------------------------------------------------------------------*
*&      --> LT_ERROR
*&      <-- LT_SOHEADER
*&---------------------------------------------------------------------*
FORM del_error_head    USING    u_t_error    TYPE ty_t_ordernumb
                       CHANGING c_t_soheader  TYPE ty_t_soheader.
  LOOP AT u_t_error  ASSIGNING FIELD-SYMBOL(<fs_error>) .
    DELETE c_t_soheader WHERE zzvbeln = <fs_error>-vbeln.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form del_error_item
*&---------------------------------------------------------------------*
*& Delete data line error at item
*&---------------------------------------------------------------------*
*&      --> LT_ERROR
*&      <-- LT_SOITEM
*&---------------------------------------------------------------------*
FORM del_error_item    USING     u_t_error    TYPE ty_t_ordernumb
                       CHANGING c_t_soitem    TYPE ty_t_soitem.
  LOOP AT u_t_error  ASSIGNING FIELD-SYMBOL(<fs_error>) .
    DELETE c_t_soitem WHERE zzvbeln = <fs_error>-vbeln.
  ENDLOOP.
ENDFORM.
