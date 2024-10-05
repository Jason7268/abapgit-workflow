*&---------------------------------------------------------------------*
*& Include          ZHIEN_DIALOG_DEMOLOGINF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form LOGIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM login .
  IF zhien_login-username IS NOT INITIAL
    AND zhien_login-password IS NOT INITIAL .

    SELECT SINGLE * FROM zhien_login INTO @DATA(ls_login)
      WHERE username = @zhien_login-username AND password = @zhien_login-password.
    IF sy-suBRC = 0.
*      CALL SCREEN 0200.
      MESSAGE s008(zhien_demo06) WITH zhien_login-username.
    ELSE.
      MESSAGE e009(zhien_demo06).
    ENDIF.
  ELSE.
    MESSAGE e007(zhien_demo06).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_login
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_login .
  SELECT * FROM zhien_login
    INTO CORRESPONDING FIELDS OF TABLE gt_detail.
  IF sy-subrc <> 0.
    MESSAGE 'Data not fount ' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SAVE_USER
*&---------------------------------------------------------------------*
*& cHECK AND SAVE USER
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
FORM check_save_user .
  PERFORM check_data.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_data .
  IF zhien_login-username IS NOT INITIAL
    AND zhien_login-password IS NOT INITIAL
    AND zhien_login-name2 IS NOT INITIAL
    AND scr_password2 IS NOT INITIAL.
    IF zhien_login-password = scr_password2.
      PERFORM insert_user.
    ELSE.
      MESSAGE 'Repeat password must have like password' TYPE 'I'.
    ENDIF.

  ELSE.
    MESSAGE 'Please input all required fields.' TYPE 'I'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_USER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_user .
  DATA ls_zlogin TYPE zhien_login.

  MOVE-CORRESPONDING zhien_login TO ls_zlogin.

  INSERT zhien_login FROM ls_zlogin.

  IF sy-subrc = 0.
    CLEAR zhien_login.
    MESSAGE s010(zhien_demo06) WITH ls_zlogin-username ls_zlogin-name2.
  ELSE.
    MESSAGE e011(zhien_demo06).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SCARR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_scarr .
  SELECT * FROM scarr UP TO 10 ROWS
    INTO TABLE gt_scarr.
  IF sy-subrc = 0.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_POPUP_CHANGE
*&---------------------------------------------------------------------*
*& show_popup_change
*&---------------------------------------------------------------------*
FORM show_popup_change CHANGING C_answer TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR       = ' '
*     DIAGNOSE_OBJECT             = ' '
      text_question  = 'Data will deleted. Do you really want to delete it?'
      text_button_1  = 'Yes'(001)
      text_button_2  = 'No'(002)
      default_button = '1'
    IMPORTING
      answer         = ld_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIND_PASS
*&---------------------------------------------------------------------*
*& find_pass
*&---------------------------------------------------------------------*
FORM find_pass .
  IF zhien_login-username IS NOT INITIAL.
    SELECT SINGLE * FROM zhien_login INTO @DATA(ls_login)
          WHERE username = @zhien_login-username.
      IF sy-subrc = 0.
        scr_password = ls_login-password.
      ELSE.
        MESSAGE 'User not exist. PLease check again!' TYPE 'I'.
      ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_flight
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_sflight .
  SELECT * FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_sflight UP TO 50 ROWS.
  IF sy-subrc <> 0.
    MESSAGE 'Data not fount ' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_SFLIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_sflight .
  CALL FUNCTION '/1BCDWB/SF00000098'
*   EXPORTING
*     ARCHIVE_INDEX              =
*     ARCHIVE_INDEX_TAB          =
*     ARCHIVE_PARAMETERS         =
*     CONTROL_PARAMETERS         =
*     MAIL_APPL_OBJ              =
*     MAIL_RECIPIENT             =
*     MAIL_SENDER                =
*     OUTPUT_OPTIONS             =
*     USER_SETTINGS              = 'X'
*   IMPORTING
*     DOCUMENT_OUTPUT_INFO       =
*     JOB_OUTPUT_INFO            =
*     JOB_OUTPUT_OPTIONS         =
    TABLES
      gt_flight                  = gt_Sflight
*   EXCEPTIONS
*     FORMATTING_ERROR           = 1
*     INTERNAL_ERROR             = 2
*     SEND_ERROR                 = 3
*     USER_CANCELED              = 4
*     OTHERS                     = 5
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
