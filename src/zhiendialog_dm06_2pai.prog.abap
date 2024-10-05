*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM06_2PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.
  CASE scr_okcode.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_INPUTS_0100  INPUT
*&---------------------------------------------------------------------*
*       validate inputs
*----------------------------------------------------------------------*
MODULE validate_inputs_0100 INPUT.
*  * Check airline and flisht number is intial or not
  IF   zshiendialg_t05-carrid IS INITIAL
    OR zshiendialg_t05-connid IS INITIAL.

    IF scr_okcode <> 'CREATE' AND scr_okcode <> 'LIST'.
*      MESSAGE ID 'ZHIEN_DEMO06' TYPE 'E' NUMBER 007.
      MESSAGE e007(zhien_demo06).

    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE scr_okcode.
    WHEN 'DISPLAY'.
      PERFORM get_flight_data.
      gd_screen_mode = gc_screenm_display.

      CALL SCREEN 200.
    WHEN 'CHANGE'.
      PERFORM get_flight_data.
      gd_screen_mode = gc_screenm_change.
      CALL SCREEN 200.
    WHEN 'CREATE'.
      CLEAR ZSHIENDIALG_T05.

      gd_screen_mode = gc_screenm_create.
      CALL SCREEN 200.
    WHEN 'LIST'.
      MESSAGE 'Not implemented yet!' TYPE 'I'.
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
  CASE scr_okcode.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE SCR_OKCODE.
    WHEN 'SAVE'.
      IF GD_SCREEN_MODE = GC_sCREENM_CHANGE.
         PERFORM UPDATE_FLIGHT_SCH.
      ELSEIF GD_SCREEN_MODE = GC_sCREENM_CREATE.
        PERFORM CREATE_FLIGHT_SCH.
      ENDIF.

    WHEN 'CREATE'.


    WHEN 'CHANGE'.
      GD_SCREEN_MODE = GC_SCREENM_CHANGE.
    WHEN 'DISPLAY'.
      PERFORM SHOW_POPUP_CHANGE.

      GD_SCREEN_MODE = GC_SCREENM_DISPLAY.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
