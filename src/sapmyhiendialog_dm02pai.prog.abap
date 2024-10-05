*&---------------------------------------------------------------------*
*& Include          SAPMYHIENDIALOG_DM02PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE SCR_OKCODE.
      WHEN 'SAVE'.
      MESSAGE 'Save data successfully!' TYPE 'I'.
    WHEN OTHERS.
  ENDCASE.

  CLEAR SCR_OKCODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_INPUT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_input INPUT.

  PERFORM CHECK_AIRLINE.
  PERFORM CHECK_TIME.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMM_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_comm_0100 INPUT.
    CASE SCR_OKCODE.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VH_CARRID  INPUT
*&---------------------------------------------------------------------*
*       Value Help for Airline
*----------------------------------------------------------------------*
MODULE vh_carrid INPUT.

  PERFORM VH_CARRID.

ENDMODULE.
