*&---------------------------------------------------------------------*
*& Include          ZHIEN_EX_ALVF01
*&---------------------------------------------------------------------*
*&---------------------- -----------------------------------------------*
*&---------------------- -----------------------------------------------*
*& Form getso_data
*&---------------------------------------------------------------------*
*& *Get sale data
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM getso_data USING U_R_vbeln TYPE ty_r_vbeln
                CHANGING c_t_saledoc TYPE ty_t_saledoc.
  SELECT  v~vbeln
          v~kunnr
          k~adrnr
    FROM  vbak AS v INNER JOIN kna1 AS k
      ON  v~kunnr = k~kunnr
    INTO TABLE c_t_saledoc UP TO 20 ROWS
    WHERE v~vbeln IN U_R_vbeln.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_address
*&---------------------------------------------------------------------*
*& get address of cus from address number
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_address USING    u_t_saledoc    TYPE ty_t_saledoc
                 CHANGING c_t_addresscus TYPE ty_t_addresscus.
  CHECK u_t_saledoc  IS NOT INITIAL.
  SELECT  addrnumber
          name1
          city1
    FROM adrc INTO TABLE c_t_addresscus
    FOR ALL ENTRIES IN u_t_saledoc
    WHERE addrnumber = u_t_saledoc-adrnr.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form move_data_output
*&---------------------------------------------------------------------*
*& merge data sale and infor cus to table output
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM move_data_output USING    u_t_addresscus  TYPE ty_t_addresscus
                      CHANGING c_t_saledoc    TYPE ty_t_saledoc.
*  DATA ls_outputalv  TYPE gt_outputalv.
  SORT c_t_saledoc BY vbeln.
  LOOP AT  c_t_saledoc INTO DATA(ls_saledoc).
*    ls_outputalv-VBELN      = ls_saledoc-VBELN.
*    ls_outputalv-KUNNR      = ls_saledoc-KUNNR.
*    ls_outputalv-ADDRNUMBER = ls_saledoc-ADRNR.
    READ TABLE u_t_addresscus  INTO DATA(ls_addresscus) WITH KEY addrnumber =  ls_saledoc-adrnr.
    IF sy-subrc = 0.
      ls_saledoc-name1 =  ls_addresscus-name1.
      ls_saledoc-city1 =  ls_addresscus-city1.
    ENDIF.
    MODIFY c_t_saledoc FROM ls_saledoc .
  ENDLOOP.

*  DESCRIBE TABLE c_t_saledoc.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_fieldcat
*&---------------------------------------------------------------------*
*& build fieldcat ALV
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_fieldcat  CHANGING  c_t_fieldcat TYPE slis_t_fieldcat_alv.
  DATA ls_fieldcat TYPE slis_fieldcat_alv.
  CLEAR ls_fieldcat.
  REFRESH c_t_fieldcat.

  ls_fieldcat-key = 'X'.
  ls_fieldcat-fieldname = 'vbeln'.
  ls_fieldcat-seltext_s = 'Sale Do'.
  ls_fieldcat-seltext_m = 'Sale Document'.
  ls_fieldcat-seltext_l = 'Sale Document'.
  APPEND ls_fieldcat TO c_t_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-key = 'X'.
  ls_fieldcat-fieldname = 'kunnr'.
  ls_fieldcat-seltext_s = 'Customer'.
  ls_fieldcat-seltext_m = 'Customer'.
  ls_fieldcat-seltext_l = 'Customer'.
  APPEND ls_fieldcat TO c_t_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-key = space.
  ls_fieldcat-fieldname = 'adrnr'.
  ls_fieldcat-seltext_s = 'Address'.
  ls_fieldcat-seltext_m = 'Address'.
  ls_fieldcat-seltext_l = 'Address'.
  APPEND ls_fieldcat TO c_t_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-key = space.
  ls_fieldcat-fieldname = 'name1'.
  ls_fieldcat-seltext_s = 'Name'.
  ls_fieldcat-seltext_m = 'Name'.
  ls_fieldcat-seltext_l = 'Name'.
  APPEND ls_fieldcat TO c_t_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-key = space.
  ls_fieldcat-fieldname = 'city1'.
  ls_fieldcat-seltext_s = 'City'.
  ls_fieldcat-seltext_m = 'City'.
  ls_fieldcat-seltext_l = 'City'.
  APPEND ls_fieldcat TO c_t_fieldcat.
  CLEAR ls_fieldcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form layout_setup
*&---------------------------------------------------------------------*
*& layout setup alv
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM layout_setup CHANGING ls_layout TYPE slis_layout_alv..
*  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = abap_true.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& display data alv
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data  USING    u_t_fieldcat TYPE slis_t_fieldcat_alv
                            u_s_layout   TYPE slis_layout_alv
                            u_t_saledoc  TYPE ty_t_saledoc.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      = ' '
*     I_BUFFER_ACTIVE         = ' '
      i_callback_program      = sy-repid
      I_CALLBACK_PF_STATUS_SET          = 'SET_PF_STATUS'
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     I_BACKGROUND_ID         = ' '
*     I_GRID_TITLE            =
*     I_GRID_SETTINGS         =
      is_layout               = u_s_layout
      it_fieldcat             = u_t_fieldcat
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
*     IT_SORT                 =
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_DEFAULT               = 'X'
*     I_SAVE                  = ' '
*     IS_VARIANT              =
*     IT_EVENTS               =
*     IT_EVENT_EXIT           =
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     I_HTML_HEIGHT_TOP       = 0
*     I_HTML_HEIGHT_END       = 0
*     IT_ALV_GRAPHICS         =
*     IT_HYPERLINK            =
*     IT_ADD_FIELDCAT         =
*     IT_EXCEPT_QINFO         =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER =
*     IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = u_t_saledoc
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc = 0.
*     Implement suitable error handling here
  ENDIF.
ENDFORM.

*SET PF-STATUS 'STATUS_TEST'.
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STATUS_TEST1'.
                  "Copy of 'STANDARD' pf_status from fgroup SALV
ENDFORM.

FORM top_of_page.

  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.

  ls_header-typ = 'H'.
  ls_header-info = 'This is header text'.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'S'.
  ls_header-info = 'This is Selection text'.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  ls_header-typ = 'A'.
  ls_header-info = 'This is Action text'.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

                          .
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.


  IF sy-subrc = 0.
    CLEAR sy-subrc.
  ENDIF.
ENDFORM.

FORM user_command USING iv_ucomm     TYPE sy-ucomm
                        is_seltext   TYPE slis_selfield.
*                        u_t_saledoc  TYPE ty_t_saledoc.


  READ TABLE gt_saledoc INTO DATA(ls_saledoc) INDEX is_seltext-tabindex.
  IF sy-subrc = 0.

    MESSAGE i001(Zhien_MSG) WITH ls_saledoc-vbeln
                                 ls_saledoc-kunnr
                                 ls_saledoc-name1
                                 ls_saledoc-city1.
  ENDIF.

ENDFORM.


**&---------------------------------------------------------------------*
*& Form main_process
*&---------------------------------------------------------------------*
*& main process
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM main_process .

DATA: lt_saledoc    TYPE  ty_t_saledoc,
      lt_addresscus TYPE  ty_t_addresscus,
      lt_outputalv  TYPE  ty_t_outputalv,
      lt_fieldcat   TYPE slis_t_fieldcat_alv,
      ls_fieldcat   TYPE slis_fieldcat_alv,
      ls_layout     TYPE slis_layout_alv.

*Get sale data
PERFORM getso_data USING    s_vbeln[]
                   CHANGING lt_saledoc.

*get address of cus from address number
  PERFORM get_address USING    lt_saledoc
                      CHANGING lt_addresscus.

*merge data sale and infor cus to table output
  PERFORM move_data_output USING    lt_addresscus
                           CHANGING lt_saledoc.
* get data for  gt_saledoc to use for user command
  gt_saledoc  = lt_saledoc.
*build fieldcat ALV
  PERFORM build_fieldcat CHANGING lt_fieldcat.
* layout setup ALV
  PERFORM layout_setup CHANGING ls_layout.

* display data ALV
  PERFORM display_data USING    lt_fieldcat
                                ls_layout
                                lt_saledoc.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SH_VBELN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sh_vbeln .
  select VBELN, ERDAT, ERNAM from vbak INTO TABLE @DATA(LT_VBAK) UP TO 50 ROWS.
 IF sy-subrc NE 0.
*   do somthing
  ENDIF.


CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
  EXPORTING
*   DDIC_STRUCTURE         = ' '
    retfield               = 'vbeln'
*   PVALKEY                = ' '
*   DYNPPROG               = sy-cprog
*   DYNPNR                 = ' '
*   DYNPROFIELD            = 's_vbeln-low'
*   STEPL                  = 0
*   WINDOW_TITLE           =
*   VALUE                  = ' '
   VALUE_ORG              = 'S'
*   MULTIPLE_CHOICE        = ' '
*   DISPLAY                = ' '
*   CALLBACK_PROGRAM       = ' '
*   CALLBACK_FORM          = ' '
*   CALLBACK_METHOD        =
*   MARK_TAB               =
* IMPORTING
*   USER_RESET             =
  tables
    value_tab              = LT_VBAK
*   FIELD_TAB              =
*   RETURN_TAB             = lt_return
*   DYNPFLD_MAPPING        =
 EXCEPTIONS
   PARAMETER_ERROR        = 1
   NO_VALUES_FOUND        = 2
   OTHERS                 = 3
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form Handle_Ucomm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM Handle_Ucomm .
    CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' .
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
