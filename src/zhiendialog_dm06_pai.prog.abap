*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM06_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.
  CASE scr_okcode. "SY-ucomm. "
    WHEN   'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CRESCR'.
*      CLEAR zshiendialg_t05.
*     LOOP AT SCREEN INTO DATA(scr).
*    IF scr-name = 'BTNCREATE'.
*      scr-required = '1'.
*      MODIFY SCREEN FROM scr.
*    ENDIF.
*  ENDLOOP.
*   PERFORM on_action_exit. " Example method name
      CALL SCREEN 200.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA: gd_set_green TYPE sy-dynnr
        .
  CASE scr_okcode.
    WHEN 'DISSCR'.

      SELECT SINGLE *
        FROM spfli INTO CORRESPONDING FIELDS OF zshiendialg_t05
        WHERE carrid = zshiendialg_t05-carrid AND connid = zshiendialg_t05-connid.
      IF sy-subrc = 0.
        gd_set_green = 200.
        CALL SCREEN gd_set_green  .

      ENDIF.
    WHEN 'CHASCR'.

      SELECT SINGLE *
            FROM spfli INTO CORRESPONDING FIELDS OF zshiendialg_t05
            WHERE carrid = zshiendialg_t05-carrid AND connid = zshiendialg_t05-connid.
      IF sy-subrc = 0.
*        gd_set_green = 200.
        CALL SCREEN 200.
      ENDIF.
    WHEN 'CRESCR'.
*      CLEAR zshiendialg_t05 .
      gd_set_green = 200.
      CALL SCREEN gd_set_green.
*     LOOP AT SCREEN INTO DATA(scr).
*    IF scr-name = 'BTNCREATE'.
*      scr-required = '1'.
*      MODIFY SCREEN FROM scr.
*    ENDIF.
*  ENDLOOP.
*   PERFORM on_action_exit. " Example method name


    WHEN 'DISLSCR'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_INPUT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_input INPUT.
  PERFORM check_airline.
  PERFORM check_airnum.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0200 INPUT.
  CASE scr_okcode. "SY-ucomm. "
    WHEN   'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VH_CONNID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE vh_connid INPUT.
  PERFORM vh_connid.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VH_CITYFROM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE vh_cityfrom INPUT.
  PERFORM vh_city_field  .
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VH_CITYTO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE vh_cityto INPUT.
  PERFORM vh_cityto_field  .
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE scr_okcode.
    WHEN 'SAVE'.
      PERFORM update_spfli.
    WHEN 'CRESCR'.
      "DO SOMETHING
      PERFORM Insert_spfli.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
