*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM05_PAI
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
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0200 INPUT.
  CASE scr_okcode.
    WHEN   'BACK' OR 'CANC'.
      LEAVE TO SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA :  gd_set_green  TYPE sy-dynnr.
  CASE scr_okcode.
    WHEN 'NSCR'. " Next screen

      MESSAGE 'Next screen testing begin: ' TYPE 'I'.

      SELECT SINGLE *
        FROM scarr
        WHERE carrid = scarr-carrid.

    WHEN 'SSCR'.   "Set screen

      gd_set_green = 300.
      SET SCREEN gd_set_green.

      MESSAGE 'Set screen testing begin: ' TYPE 'I'.

      SELECT SINGLE *
        FROM scarr
        WHERE carrid = scarr-carrid.

    WHEN 'LSCR'. "Leave screen

      MESSAGE 'Leave screen testing begin: ' TYPE 'I'.
      gd_set_green = 400.
      SET SCREEN gd_set_green.

      MESSAGE 'Before leaving screen: ' TYPE 'I'.

      LEAVE SCREEN.

      MESSAGE 'After leaving screen: ' TYPE 'I'.

      SELECT SINGLE *
        FROM scarr
        WHERE carrid = scarr-carrid.
    WHEN 'CSCR'. "Leave screen
      MESSAGE 'Call screen testing begin: ' TYPE 'I'.

      SELECT SINGLE *
        FROM scarr
        WHERE carrid = scarr-carrid.

      gd_set_green = 500.
      CALL SCREEN gd_set_green.

      MESSAGE 'After Call screen: ' TYPE 'I'.

     WHEN 'CSCRP'. "Leave screen
      MESSAGE 'Call screen testing begin: ' TYPE 'I'.

      SELECT SINGLE *
        FROM scarr
        WHERE carrid = scarr-carrid.

      gd_set_green = 500.
      CALL SCREEN gd_set_green STARTING AT 10 2 ENDING AT 72 30 .

      MESSAGE 'After Call screen: ' TYPE 'I'.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0300 INPUT.
  CASE scr_okcode.
    WHEN   'BACK' OR 'CANC'.
      LEAVE TO SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0400 INPUT.
  CASE scr_okcode.
    WHEN   'BACK' OR 'CANC'.
      LEAVE TO SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0500 INPUT.
  CASE scr_okcode.
    WHEN   'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
