*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM08PAI
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
    WHEN 'CREATE'.
      CLEAR GT_DETAIL.
      APPEND INITIAL LINE TO GT_DETAIL.
      GD_FLAG_RESET_TC = ABAP_TRUE.

      gd_screen_mode = gc_mode_create.
      LEAVE SCREEN.
    WHEN 'CHANGE'.
      CASE gd_screen_mode.
        WHEN gc_mode_change or gc_mode_create.
          gd_screen_mode = gc_mode_display.
        WHEN gc_mode_display.
          gd_screen_mode = gc_mode_change.
        WHEN OTHERS.
      ENDCASE.
      LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR scr_okcode.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_INPUTS  INPUT
*&---------------------------------------------------------------------*
*       VALIDATE DATA
*----------------------------------------------------------------------*
MODULE validate_inputs INPUT.
  IF ZSHIENDIALG_DM08D-SEATSMAX < ZSHIENDIALG_DM08D-seatsocc.
    SET CURSOR FIELD 'ZSHIENDIALG_DM08D-SEATSMAX' LINE tc_detail_list-current_line .
    MESSAGE 'Cappacity cannot be less than the number of occupied seats' TYPE 'E'.
  ENDIF.

    IF ZSHIENDIALG_DM08D-SEATSMAX_B < ZSHIENDIALG_DM08D-seatsocc_B.
    SET CURSOR FIELD 'ZSHIENDIALG_DM08D-SEATSMAX_B' LINE tc_detail_list-current_line .
    MESSAGE 'Cappacity cannot be less than the number of occupied seats' TYPE 'E'.
  ENDIF.

    IF ZSHIENDIALG_DM08D-SEATSMAX_F < ZSHIENDIALG_DM08D-seatsocc_F.
    SET CURSOR FIELD 'ZSHIENDIALG_DM08D-SEATSMAX_F' LINE tc_detail_list-current_line .
    MESSAGE 'Cappacity cannot be less than the number of occupied seats' TYPE 'E'.
  ENDIF.

  IF GD_SCREEN_MODE = GC_MODE_cREATE AND ZSHIENDIALG_DM08D-FLDATE < SY-datum.
    SET CURSOR FIELD 'ZSHIENDIALG_DM08D-FLDATE' LINE 1 .
    MESSAGE 'Flight date cannot be date in the past.' TYPE 'E'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE SCR_OKCODE.
    WHEN 'SAVE'.
      IF GD_SCREEN_MODE = GC_MODE_CREATE.
        PERFORM CREATE_DATA.
      ELSEIF GD_SCREEN_MODE = GC_MODE_CHANGE.
        PERFORM UPDATE_DATA.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

*  CLEAR SCR_OKCODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MODIFY_DATA  INPUT
*&---------------------------------------------------------------------*
*       modify data
*----------------------------------------------------------------------*
MODULE modify_data INPUT.
  IF GD_SCREEN_MODE = GC_MODE_CREATE.
    ZSHIENDIALG_DM08D-CARRID = ZSHIENDIALG_DM08H-CARRID.
    ZSHIENDIALG_DM08D-CONNID = ZSHIENDIALG_DM08H-CONNID.
  ENDIF.
  MODIFY  GT_DETAIL FROM ZSHIENDIALG_DM08D INDEX tc_detail_list-current_line.
ENDMODULE.
