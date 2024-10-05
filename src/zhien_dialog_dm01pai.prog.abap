*&---------------------------------------------------------------------*
*& Include          ZHIEN_DIALOG_DM01PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  UCOMM_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ucomm_0100 INPUT.


  CASE SCR_OKCODE. "/ SY-UCOMM
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'OK'.
        IF SCR_INPUT1 IS NOT INITIAL.
          SCR_OUTPUT1 = |Hello world { SCR_INPUT1 } !|.
        ENDIF.
     WHEN 'SHELLO'.
        IF SCR_INPUT1 IS NOT INITIAL.
          SCR_OUTPUT1 = |Hello { SCR_INPUT1 } : How are you?|.
        ENDIF.
     WHEN 'STHANKS'.
        IF SCR_INPUT1 IS NOT INITIAL.
          SCR_OUTPUT1 = |Thank you { SCR_INPUT1 } !|.
        ENDIF.
     WHEN 'SBYE'.
        IF SCR_INPUT1 IS NOT INITIAL.
          SCR_OUTPUT1 = |Bye bye { SCR_INPUT1 } !|.
        ENDIF.
    WHEN OTHERS.
  ENDCASE.
  CLEAR SCR_OKCODE.
ENDMODULE.
