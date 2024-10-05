*&---------------------------------------------------------------------*
*& Include          SAPMYHIENDIALOG_DM03PAI
*&---------------------------------------------------------------------*
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

*  PERFORM VH_CARRID.
    PERFORM VH_CARRID_2.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VH_FLDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE vh_fldate INPUT.
          CALL FUNCTION 'F4_DATE'
*           EXPORTING
*             DATE_FOR_FIRST_MONTH               = SY-DATUM
*             DISPLAY                            = ' '
*             FACTORY_CALENDAR_ID                = ' '
*             GREGORIAN_CALENDAR_FLAG            = ' '
*             HOLIDAY_CALENDAR_ID                = ' '
*             PROGNAME_FOR_FIRST_MONTH           = ' '
*             DATE_POSITION                      = ' '
           IMPORTING
             SELECT_DATE                        = SCR_FLDATE
*             SELECT_WEEK                        =
*             SELECT_WEEK_BEGIN                  =
*             SELECT_WEEK_END                    =
           EXCEPTIONS
             CALENDAR_BUFFER_NOT_LOADABLE       = 1
             DATE_AFTER_RANGE                   = 2
             DATE_BEFORE_RANGE                  = 3
             DATE_INVALID                       = 4
             FACTORY_CALENDAR_NOT_FOUND         = 5
             HOLIDAY_CALENDAR_NOT_FOUND         = 6
             PARAMETER_CONFLICT                 = 7
             OTHERS                             = 8
                    .
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
*  PERFORM
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VH_DEPTIME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE vh_deptime INPUT.
  PERFORM VH_TIME_FIELD CHANGING SCR_DEPTIME.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VH_AIRTIME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE vh_arrtime INPUT.
  PERFORM VH_TIME_FIELD CHANGING SCR_ARRTIME.
ENDMODULE.
