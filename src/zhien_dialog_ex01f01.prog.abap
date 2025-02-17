*&---------------------------------------------------------------------*
*& Include          ZHIEN_DIALOG_EX01F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_purorder
*&---------------------------------------------------------------------*
*& Get purchar order
*&---------------------------------------------------------------------*

FORM get_purorder  .
  CLEAR yshien_purorder.
*  GET PURORDER
  SELECT SINGLE  purchase_order
                 order_date
                 vendor
                 company_code
                 currency
     FROM ythien_purorder
     INTO CORRESPONDING FIELDS OF yshien_purorder
     WHERE purchase_order = scr_purchase_order.
  IF sy-subrc = 0.
*     Get ccode name
    SELECT SINGLE name1
      INTO scr_name1
      FROM lfa1
      WHERE lifnr = yshien_purorder-vendor.
*     Get vendor name
    SELECT SINGLE butxt
      INTO scr_butxt
      FROM t001
      WHERE bukrs = yshien_purorder-company_code.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_purordit
*&---------------------------------------------------------------------*
*& Get purchar order item
*&---------------------------------------------------------------------*

FORM get_purordit .
*  GET PURORD Item
  SELECT *
     FROM ythien_purordit
     INTO CORRESPONDING FIELDS OF TABLE gt_detail
     WHERE purchase_order = scr_purchase_order.
  IF sy-subrc <> 0.
    MESSAGE 'No item line to be displayed' TYPE 'S'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_DATA
*&---------------------------------------------------------------------*
*& Create data
*&---------------------------------------------------------------------*
FORM create_data.
  DATA: ls_detail   TYPE yshien_purordit,
        ls_purordit TYPE ythien_purordit,
        ls_purorder TYPE ythien_purorder,
        lt_purordit TYPE TABLE OF ythien_purordit.

  TRY.
      " Create Header
      IF yshien_purorder IS NOT INITIAL.
        MOVE-CORRESPONDING yshien_purorder TO ls_purorder.
        INSERT ythien_purorder FROM ls_purorder.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_sql_error.
          MESSAGE 'Error inserting PO Header' TYPE 'E'.
        ENDIF.

        " Create Items after header success
        IF gt_detail IS NOT INITIAL.
          LOOP AT gt_detail INTO ls_detail.
            MOVE-CORRESPONDING ls_detail TO ls_purordit.
            INSERT ls_purordit INTO TABLE lt_purordit.
          ENDLOOP.

          INSERT ythien_purordit FROM TABLE lt_purordit.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE cx_sy_sql_error.
            MESSAGE 'Error inserting PO Items' TYPE 'E'.
          ELSE.
            COMMIT WORK AND WAIT.
            MESSAGE 'Data inserted successfully' TYPE 'S'.
          ENDIF.
        ENDIF.
      ENDIF.

    CATCH cx_sy_sql_error INTO DATA(lx_error).
      ROLLBACK WORK.
      MESSAGE lx_error->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form UPDATE_DATA
*&---------------------------------------------------------------------*
*& Update data
*&---------------------------------------------------------------------*
FORM update_data .
  DATA: ls_detail   TYPE yshien_purordit,
        ls_purordit TYPE ythien_purordit,
        lt_purordit TYPE STANDARD TABLE OF ythien_purordit.

*  CHECK gt_Detail IS NOT INITIAL.
  IF gt_Detail IS NOT INITIAL.
    LOOP AT gt_Detail INTO ls_Detail.
      CLEAR ls_purordit.
      MOVE-CORRESPONDING ls_detail TO ls_purordit.
      APPEND ls_purordit TO lt_purordit.
    ENDLOOP.
  ENDIF.
  TRY.
*  IF lt_purordit IS NOT INITIAL.
      MODIFY  ythien_purordit FROM TABLE lt_purordit.
*  ENDIF.
      IF sy-subrc <> 0.
        MESSAGE 'Updating failed.' TYPE 'E' DISPLAY LIKE 'I'.
      ELSE.
        gd_screen_mode = gc_mode_display.
        COMMIT WORK AND WAIT.

        MESSAGE 'Update po success.' TYPE 'S'.
      ENDIF.
    CATCH cx_sy_sql_error INTO DATA(lx_error).
      ROLLBACK WORK.
      MESSAGE lx_error->get_text( ) TYPE 'E'..
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form prepare_data
*&---------------------------------------------------------------------*
*& Prepare data
*&---------------------------------------------------------------------*

FORM prepare_data .
  IF scr_purchase_order IS NOT INITIAL.
    PERFORM get_purorder.
    PERFORM get_purordit.
*      CALL SCREEN 0200.
    DESCRIBE TABLE gt_detail LINES tc_detail_list-lines.
    CALL SCREEN 0200.
  ELSE.
    MESSAGE 'Please input Purchase Order' TYPE 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_comcodename
*&---------------------------------------------------------------------*
*& Get company code name
*&---------------------------------------------------------------------*
FORM get_comcodename .
  CLEAR: scr_butxt.

  SELECT SINGLE butxt
    FROM t001
    INTO scr_butxt
    WHERE bukrs = yshien_purorder-company_code.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_vendorname
*&---------------------------------------------------------------------*
*& get vendor name
*&---------------------------------------------------------------------*
FORM get_vendorname .
  CLEAR: scr_name1.

  SELECT SINGLE name1
    FROM lfa1
    INTO scr_name1
    WHERE lifnr = yshien_purorder-vendor.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_currency
*&---------------------------------------------------------------------*
*& Get currency
*&---------------------------------------------------------------------*
FORM get_currency .
  CLEAR: yshien_purorder-currency.

  SELECT SINGLE waers
    FROM t001
    INTO yshien_purorder-currency
    WHERE bukrs = yshien_purorder-company_code.
ENDFORM.
