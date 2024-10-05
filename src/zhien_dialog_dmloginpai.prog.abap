*&---------------------------------------------------------------------*
*& Include          ZHIEN_DIALOG_DEMOLOGINPAI
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
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE scr_okcode.
    WHEN 'LOGIN'.
      PERFORM login.
      CALL SCREEN 0600.
     WHEN 'FIND'.
      CLEAR scr_password.
      PERFORM FIND_PASS.
      IF scr_password is NOT INITIAL.
        CALL SCREEN 0700.
      ENDIF.

    WHEN 'SIGNUP'.
      CLEAR zhien_login.
      CALL SCREEN 0400 STARTING AT 10 11
                       ENDING AT 70 20.
    WHEN 'PUSH1'. " tab strip 1
      ts_control-activetab = 'PUSH1'.
    WHEN 'PUSH2'. " tab strip 2
      ts_control-activetab = 'PUSH2'.
    WHEN 'PRINT'.
      PERFORM PRINT_SFLIGHT.
    WHEN OTHERS.
  ENDCASE.
  CLEAR scr_okcode.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0300 INPUT.
  CASE scr_okcode.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  IF scr_okcode = 'SAVE'.
    PERFORM check_save_user.
  ENDIF.

  CLEAR scr_okcode.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FIELD_SELECTION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE field_selection INPUT.
  DATA: ld_answer TYPE c.
  CASE scr_okcode.
    WHEN 'DELETE'.
      READ TABLE gt_detail INTO gs_detail INDEX tc_detail_list-current_line.
      IF sy-subrc IS INITIAL.
*        Ask confirm before delete
        PERFORM show_popup_change USING ld_answer .

        IF ld_answer = '1'.
          DELETE zhien_login FROM @gs_detail.
*          DELETE FROM zhien_login WHERE username = gs_detail-username AND name2 = gs_detail-name2.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
            MESSAGE 'Record deleted successfully' TYPE 'S'.
          ELSE.
            MESSAGE 'Record deleted fail' TYPE 'E'.
          ENDIF.
        ENDIF.


      ENDIF.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.
  CASE scr_okcode.
    WHEN 'SAVE'.
      PERFORM check_save_user.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
  CLEAR scr_okcode.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0600 INPUT.
  CASE scr_okcode.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.
    CASE scr_okcode.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
  CLEAR scr_okcode.
ENDMODULE.
