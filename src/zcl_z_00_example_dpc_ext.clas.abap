class ZCL_Z_00_EXAMPLE_DPC_EXT definition
  public
  inheriting from ZCL_Z_00_EXAMPLE_DPC
  create public .

public section.
protected section.

  methods PRODUCTSET_GET_ENTITY
    redefinition .
  methods PRODUCTSET_GET_ENTITYSET
    redefinition .
  methods PRODUCTSET_CREATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_00_EXAMPLE_DPC_EXT IMPLEMENTATION.


  method PRODUCTSET_CREATE_ENTITY.

  DATA: ls_headerdata TYPE bapi_epm_product_header,
        ls_product    LIKE er_entity,
        lt_return     TYPE STANDARD TABLE OF bapiret2.

  io_data_provider->read_entry_data( IMPORTING es_data = ls_product ).

  ls_headerdata-product_id     = ls_product-productid.
  ls_headerdata-category       = ls_product-category.
  ls_headerdata-name           = ls_product-name.
  ls_headerdata-supplier_id  = ls_product-supplierid.
  ls_headerdata-measure_unit   = 'EA'.
  ls_headerdata-currency_code  = 'EUR'.
  ls_headerdata-tax_tarif_code = '1'.
  ls_headerdata-type_code      = 'PR'.

  CALL FUNCTION 'BAPI_EPM_PRODUCT_CREATE'
    EXPORTING
      headerdata = ls_headerdata
*     PERSIST_TO_DB      = ABAP_TRUE
    TABLES
*     CONVERSION_FACTORS =
      return     = lt_return.

  IF lt_return IS NOT INITIAL.
    mo_context->get_message_container( )->add_messages_from_bapi(
      it_bapi_messages         = lt_return
      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid            = /iwbep/cx_mgw_busi_exception=>business_error
        message_container = mo_context->get_message_container( ).
  ENDIF.

  er_entity = ls_product.

ENDMETHOD.


METHOD productset_get_entity.
    DATA: ls_entity     LIKE er_entity,
          ls_product_id TYPE bapi_epm_product_id,
          ls_headerdata TYPE bapi_epm_product_header.
    io_tech_request_context->get_converted_keys(
    IMPORTING
    es_key_values = ls_entity ).
    ls_product_id-product_id = ls_entity-productid.
    CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_DETAIL'
      EXPORTING
        product_id = ls_product_id
      IMPORTING
        headerdata = ls_headerdata
* TABLES
*       CONVERSION_FACTORS =
*       RETURN     =
      .
    er_entity-productid = ls_headerdata-product_id.
    er_entity-category = ls_headerdata-category.
    er_entity-name = ls_headerdata-name.
    Er_entity-supplierid = ls_headerdata-supplier_id.
  ENDMETHOD.


  METHOD productset_get_entityset.
    DATA: lr_filter                TYPE REF TO /iwbep/if_mgw_req_filter,
        lt_filter_select_options TYPE /iwbep/t_mgw_select_option,
        ls_filter_select_options TYPE /iwbep/s_mgw_select_option,
        ls_select_option         TYPE /iwbep/s_cod_select_option,
        lt_selparamproductid     TYPE STANDARD TABLE OF bapi_epm_product_id_range,
        ls_selparamproductid     TYPE bapi_epm_product_id_range,
        lt_selparamcategories    TYPE STANDARD TABLE OF bapi_epm_product_categ_range,
        ls_selparamcategories    TYPE bapi_epm_product_categ_range.

  DATA: lt_headerdata TYPE STANDARD TABLE OF bapi_epm_product_header,
        ls_headerdata TYPE bapi_epm_product_header,
        ls_product    LIKE LINE OF et_entityset.

DATA: lv_maxrows            TYPE bapi_epm_max_rows,
        lv_top                TYPE i,
        lv_skip               TYPE i,
        lv_start              TYPE i,
        lv_end                TYPE i,
        lv_has_inlinecount(1) TYPE c.


  lr_filter = io_tech_request_context->get_filter( ).
  lt_filter_select_options = lr_filter->get_filter_select_options( ).

  lv_maxrows-bapimaxrow = 0.
  lv_top = io_tech_request_context->get_top( ).
  lv_skip = io_tech_request_context->get_skip( ).
  lv_has_inlinecount = io_tech_request_context->has_inlinecount( ).
  IF ( lv_top IS NOT INITIAL ).
    lv_maxrows-bapimaxrow = lv_top + lv_skip.
  ENDIF.


  LOOP AT lt_filter_select_options INTO ls_filter_select_options.
    IF ls_filter_select_options-property EQ 'PRODUCTID'.
      LOOP AT ls_filter_select_options-select_options INTO ls_select_option.
        ls_selparamproductid-sign = ls_select_option-sign.
        ls_selparamproductid-option = ls_select_option-option.
        ls_selparamproductid-low = ls_select_option-low.
        ls_selparamproductid-high = ls_select_option-high.
        APPEND ls_selparamproductid TO lt_selparamproductid.
      ENDLOOP.
    ELSEIF ls_filter_select_options-property EQ 'CATEGORY'.
      LOOP AT ls_filter_select_options-select_options INTO ls_select_option.
        ls_selparamcategories-sign = ls_select_option-sign.
        ls_selparamcategories-option = ls_select_option-option.
        ls_selparamcategories-low = ls_select_option-low.
        ls_selparamcategories-high = ls_select_option-high.
        APPEND ls_selparamcategories TO lt_selparamcategories.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_LIST'
EXPORTING
      max_rows           = lv_maxrows

    TABLES
      headerdata         = lt_headerdata
      selparamproductid  = lt_selparamproductid
*     SELPARAMSUPPLIERNAMES =
      selparamcategories = lt_selparamcategories
*     RETURN             =
    .
  lv_start = 1.
  IF lv_skip IS NOT INITIAL.
    lv_start = lv_skip + 1.
  ENDIF.
  IF lv_top IS NOT INITIAL.
    lv_end = lv_top + lv_start - 1.
  ELSE.
    lv_end = lines( lt_headerdata ).
  ENDIF.

  IF lv_has_inlinecount EQ abap_true.
    es_response_context-inlinecount = lines( lt_headerdata ).
  ENDIF.

  LOOP AT lt_headerdata INTO ls_headerdata.
    ls_product-productid = ls_headerdata-product_id.
    ls_product-category = ls_headerdata-category.
    ls_product-name = ls_headerdata-name.
    APPEND ls_product TO et_entityset.
  ENDLOOP.

  ENDMETHOD.
ENDCLASS.
