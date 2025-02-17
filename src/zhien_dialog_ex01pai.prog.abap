*&---------------------------------------------------------------------*
*& Include          ZHIEN_DIALOG_EX01PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.
  CASE scr_okcode.
    WHEN   'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR scr_okcode.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE scr_okcode.
    WHEN 'DISPLAY'.
      gd_screen_mode = gc_mode_display.
      CLEAR scr_okcode.
      PERFORM prepare_data.

    WHEN 'CREATE'.
      CLEAR: gt_detail, yshien_purorder .
      APPEND INITIAL LINE TO gt_detail.
      gd_screen_mode = gc_mode_create.
      gd_flag_reset_tc = abap_true.
      CLEAR scr_okcode.
*      LEAVE SCREEN.
      REFRESH CONTROL 'tc_detail_list' FROM SCREEN '0200'.
      CALL SCREEN 0200.
    WHEN 'CHANGE'.
      gd_screen_mode = gc_mode_change.
      CLEAR scr_okcode.
      PERFORM prepare_data.
*      LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR scr_okcode.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0200 INPUT.
  DATA : l_msg       TYPE string VALUE 'Warning Message',  " your text
         p_wa_answer TYPE char1.
  CASE scr_okcode.
    WHEN   'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CHANGE'.
      CASE gd_screen_mode.
        WHEN gc_mode_change OR gc_mode_create.
          gd_screen_mode = gc_mode_display.
        WHEN gc_mode_display.
          gd_screen_mode = gc_mode_change.
        WHEN OTHERS.
      ENDCASE.
      LEAVE SCREEN.
    WHEN 'INSERT'.
      APPEND INITIAL LINE TO gt_detail.
      tc_detail_list-lines = tc_detail_list-lines + 1.
*      LEAVE SCREEN.
    WHEN 'DELETE'.
      IF lines( gt_detail ) > 0.
        DATA(lv_lines) = REDUCE i( INIT x = 0 FOR wa IN gt_detail WHERE (  marked = 'X' ) NEXT x = x + 1 ).

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = l_msg
            text_question         = 'Do you really want to delete these Items?'
            text_button_1         = 'Yes'(002)
            text_button_2         = 'No'(005)
            default_button        = '1'
            display_cancel_button = ''
          IMPORTING
            answer                = p_wa_answer.

        IF p_wa_answer = '1'. " yes to delete
* remove marked lines
          LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>) WHERE     marked = 'X'.

            DELETE FROM ythien_purordit WHERE purchase_order = <fs_detail>-purchase_order
                                          AND line_item = <fs_detail>-line_item.
            DELETE TABLE gt_detail FROM <fs_detail>.
            tc_detail_list-lines = tc_detail_list-lines - 1.
          ENDLOOP.
          IF sy-subrc <> 0.
            GET CURSOR FIELD fld LINE linno OFFSET off.
            SET CURSOR FIELD fld LINE linno OFFSET off.
            IF fld CP 'yshien_purordit*' AND sy-subrc = 0.
              linno = linno + tc_detail_list-top_line - 1.

              READ TABLE gt_detail INDEX linno ASSIGNING <fs_detail>.

              DELETE FROM ythien_purordit WHERE purchase_order = <fs_detail>-purchase_order
                                            AND line_item      = <fs_detail>-line_item.
              IF sy-subrc = 0.
                DELETE gt_detail INDEX linno.
              ENDIF.
            ENDIF.
            tc_detail_list-lines = tc_detail_list-lines - 1.
          ENDIF.

        ENDIF.
        LEAVE SCREEN.
      ELSE.
        MESSAGE 'Please select a row for deletion' TYPE 'S'.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.
  CLEAR scr_okcode.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE scr_okcode.
    WHEN 'OK' OR space.
* Get COMCODE NAME
      IF yshien_purorder-company_code IS NOT INITIAL.
        PERFORM get_comcodename.
        PERFORM get_currency.
      ENDIF.
* Get Vendor NAME
      IF yshien_purorder-vendor IS NOT INITIAL.
        PERFORM get_vendorname.
      ENDIF.
      LEAVE SCREEN.
    WHEN 'SAVE'.
      IF gd_screen_mode = gc_mode_create.
        PERFORM create_data.
      ELSEIF gd_screen_mode = gc_mode_change.
        PERFORM update_data.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MODIFY_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_data INPUT.
  IF gd_screen_mode = gc_mode_create OR
     gd_screen_mode = gc_mode_change.
    yshien_purordit-purchase_order = yshien_purorder-purchase_order.
  ENDIF.
  MODIFY  gt_detail FROM yshien_purordit INDEX tc_detail_list-current_line.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_INPUTS  INPUT
*&---------------------------------------------------------------------*
*       Validate data
*----------------------------------------------------------------------*
MODULE validate_inputs_item INPUT.
  IF  gd_screen_mode = gc_mode_change OR
      gd_screen_mode = gc_mode_create.

    IF yshien_purordit-mat_code   IS INITIAL  OR
       yshien_purordit-line_item  IS INITIAL  OR
       yshien_purordit-mat_code   IS INITIAL  OR
       yshien_purordit-short_text IS INITIAL  OR
       yshien_purordit-quantity   IS INITIAL  OR
       yshien_purordit-unit       IS INITIAL  OR
       yshien_purordit-net_price  IS INITIAL  .
      MESSAGE 'Please fill all data' TYPE 'E'.
    ENDIF.
*  Check matnr
    IF yshien_purordit-mat_code IS NOT INITIAL.
      SELECT SINGLE COUNT( * )
       FROM mara
       WHERE matnr = yshien_purordit-mat_code.
      IF sy-subrc <> 0.
        " Record exists
        SET CURSOR FIELD 'YSHIEN_PURORDER-MAT_CODE'  .
        MESSAGE 'Material does not exists' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_INPUTS_HEADER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_inputs_header INPUT.
  IF  gd_screen_mode = gc_mode_change OR
      gd_screen_mode = gc_mode_create.
*  Check purchase order
    IF gd_screen_mode = gc_mode_create.
      IF yshien_purorder-purchase_order IS NOT INITIAL.
        SELECT SINGLE COUNT( * )
         FROM ythien_purorder
         WHERE purchase_order = yshien_purorder-purchase_order.
        IF sy-subrc = 0.
          " Record exists
          SET CURSOR FIELD 'YSHIEN_PURORDER-purchase_order'  .
          MESSAGE 'Purchase Order Number exists' TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

*  Check Company code
    IF yshien_purorder-company_code IS NOT INITIAL.
      SELECT SINGLE COUNT( * )
       FROM t001
       WHERE bukrs = yshien_purorder-company_code.
      IF sy-subrc <> 0.
        " Record exists
        SET CURSOR FIELD 'YSHIEN_PURORDER-COMPANY_CODE'  .
        MESSAGE 'Company code does not  exists' TYPE 'E'.
      ENDIF.
    ENDIF.

*  Check Vendor
    IF yshien_purorder-vendor IS NOT INITIAL.
      SELECT SINGLE COUNT( * )
       FROM lfa1
       WHERE lifnr = yshien_purorder-vendor.
      IF sy-subrc <> 0.
        " Record exists
        SET CURSOR FIELD 'YSHIEN_PURORDER-VENDOR'  .
        MESSAGE 'Vendor does not exists' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.
