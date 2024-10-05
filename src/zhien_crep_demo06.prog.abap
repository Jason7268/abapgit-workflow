*&---------------------------------------------------------------------*
*& Report ZHIEN_CREP_DEMO04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_crep_demo06.

TYPES: BEGIN OF ty_log_report.
         INCLUDE STRUCTURE spfli.
TYPES:   status  TYPE c,
         message TYPE text150,
       END OF ty_log_report.
TYPES: ty_t_log_report TYPE STANDARD TABLE OF ty_log_report.
TYPES: ty_t_spfliul TYPE STANDARD TABLE OF ty_log_report.


TYPES: BEGIN OF ty_upload,
         col1 TYPE string,
       END OF ty_upload,
       ty_t_upload TYPE STANDARD TABLE OF ty_upload..






*Block 1: Create Flight Schedule Options
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: r_creone RADIOBUTTON GROUP rb1 USER-COMMAND rbcm DEFAULT 'X',
              r_upload RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK b01.
* Block 2: Create a Flight Schedule
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS: p_carrid TYPE spfli-carrid     MODIF ID bl2,
              p_connid TYPE spfli-connid    MODIF ID bl2,
              p_ctryfr TYPE spfli-countryfr MODIF ID bl2,
              p_cityfr TYPE spfli-cityfrom  MODIF ID bl2,
              p_airpfr TYPE spfli-airpfrom  MODIF ID bl2,
              p_ctryto TYPE spfli-countryto MODIF ID bl2,
              p_cityto TYPE spfli-cityto    MODIF ID bl2,
              p_airpto TYPE spfli-airpto    MODIF ID bl2,
              p_fltime TYPE spfli-fltime    MODIF ID bl2,
              p_deptim TYPE spfli-deptime   MODIF ID bl2,
              p_arrtim TYPE spfli-arrtime   MODIF ID bl2,
              p_distan TYPE spfli-distance  MODIF ID bl2.
  PARAMETERS: p_disunt TYPE spfli-distid AS LISTBOX
                        VISIBLE LENGTH 25
                        OBLIGATORY
                        DEFAULT 'KM'
                        MODIF ID bl2,
              p_fltype TYPE spfli-fltype    MODIF ID bl2,
              p_period TYPE spfli-period    MODIF ID bl2.
SELECTION-SCREEN END OF BLOCK b02.

*Block 3: Upload multiple Flight Schedule
SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-b03.
  PARAMETERS: p_path TYPE string MODIF ID bl3.
SELECTION-SCREEN END OF BLOCK b03.

INITIALIZATION.
* Initialize data for dropdownlist
  PERFORM init_data.

AT SELECTION-SCREEN OUTPUT.
*Change screen when change Radio button
  PERFORM change_sel_screen.

AT SELECTION-SCREEN.
*Input validation I
  PERFORM validate_inputs.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
* File Open Dialog
  PERFORM open_file_dialog.


START-OF-SELECTION.
*Main processing
  PERFORM main_processing.

*&---------------------------------------------------------------------*
*& Form change_sel_screen
*&---------------------------------------------------------------------*
*& Change screen when change Radio button
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_sel_screen .
  DATA: ld_arrival_date TYPE d,
        ld_duration     TYPE i.
  LOOP AT SCREEN.
*    IF USER CHOOSE CREATE A Fli Sche
    IF r_creone = abap_true.
*      HIDE Upload block 3
      IF screen-group1 = 'BL3'.
        screen-active = '0'.
      ELSEIF screen-group1 = 'BL2'. "Show Create block 2
        screen-active = '1'.
      ENDIF.
*    IF USER CHOOSE Upload Fli Sche
    ELSE.
*      Show Upload BLOCK 3
      IF screen-group1 = 'BL3'.
        screen-active = '1'.
      ELSEIF screen-group1 = 'BL2'. "Hide Create block 2
        screen-active = '0'.
      ENDIF.
    ENDIF.
** Set screen required (icon only, no message)
    IF screen-name = 'P_CARRID' OR
   screen-name = 'P_CONNID' OR
   screen-name = 'P_CTRYFR' OR
   screen-name = 'P_CTRYTO' OR
   screen-name = 'P_CITYFR' OR
   screen-name = 'P_CITYTO' OR
   screen-name = 'P_AIRPFR' OR
   screen-name = 'P_AIRPTO'.
      screen-required = '2'.
    ENDIF.
** Disable field Flight duration
    IF screen-name = 'P_FLTIME'.
      screen-input = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
**Calculate Flight duration
  ld_arrival_date = sy-datum.
  ld_arrival_date += p_period.
  CALL FUNCTION 'SWI_DURATION_DETERMINE'
    EXPORTING
      start_date = sy-datum
      end_date   = ld_arrival_date
      start_time = p_deptim
      end_time   = p_arrtim
    IMPORTING
      duration   = ld_duration. " Flight Duration in seconds
  p_fltime   = ld_duration / 60.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form validate_inputs
*&---------------------------------------------------------------------*
*& *Input validation I
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_inputs .

  CHECK sy-ucomm <> 'RBCM'.

** 1. Validate Required Fields
  IF r_creone = abap_true.
    PERFORM: check_required_fields USING p_carrid TEXT-t01,
    check_required_fields USING p_connid 'Flight Number',
    check_required_fields USING p_ctryfr 'Country From',
    check_required_fields USING p_ctryto 'Country To',
    check_required_fields USING p_cityfr 'City From',
    check_required_fields USING p_cityto 'City To',
    check_required_fields USING p_airpfr 'Airport From',
    check_required_fields USING p_airpto 'Airport To'.
** . Validate Airline Code with Table Airline Master
    IF p_carrid IS NOT INITIAL.
      PERFORM check_airline_master USING p_carrid.
**  Validate Country Name with Table Country Master
      IF p_ctryfr IS NOT INITIAL.
        PERFORM check_country_master USING p_ctryfr. "CHECK COUNTRY FROM
        PERFORM check_country_master USING p_ctryto. "CHECK COUNTRY TO
      ENDIF.
      IF p_cityfr IS NOT INITIAL.
        PERFORM check_country_master USING p_ctryto. "CHECK COUNTRY TO
      ENDIF.

    ENDIF.
  ELSE.
    PERFORM check_required_fields USING p_path 'Local File'.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_data
*&---------------------------------------------------------------------*
*& Initialize data for dropdownlist
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_data .

* INIT_DATA
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = CONV vrm_id( 'P_DISUNT' )
      values          = VALUE vrm_values( ( key = 'KM' text = 'Kilometers' )
                                        ( key = 'MI' text = 'Miles' ) )
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE 'Cannot initialize List Box Distance Unit.' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_REQUIRED_FIELDS
*&---------------------------------------------------------------------*
*& Validate Required Fields
*&---------------------------------------------------------------------*
*&      --> P_CARRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM check_required_fields  USING    u_value TYPE any
                                     u_field_name TYPE string.
  IF u_value IS INITIAL.
    MESSAGE | Vui lòng nhập dữ liệu vào trường { u_field_name }.| TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AIRLINE_MASTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_CARRID
*&---------------------------------------------------------------------*
FORM check_airline_master  USING    u_carrid TYPE scarr-carrid.
  SELECT SINGLE carrid FROM scarr
     INTO @DATA(ls_scarr)
    WHERE carrid = @u_carrid.
  IF sy-subrc <> 0.
    MESSAGE | Invalid airline code : { u_carrid }. Please retry with different code. | TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COUNTRY_MASTER
*&---------------------------------------------------------------------*
*&  Validate Country Name with Table Country Master
*&---------------------------------------------------------------------*
*&      --> P_CTRYFR
*&---------------------------------------------------------------------*
FORM check_country_master  USING    u_country TYPE t005-land1.
  SELECT SINGLE land1 FROM t005
    INTO @DATA(ls_land1)
   WHERE land1 = @u_country.
  IF sy-subrc <> 0.
    MESSAGE | Invalid Country code : { u_country }. Please retry with different code. | TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form OPEN_FILE_DIALOG
*&---------------------------------------------------------------------*
*& File Open Dialog
*&---------------------------------------------------------------------*

FORM open_file_dialog .
  DATA: lt_file_table TYPE filetable,
        ld_rc         TYPE i.
  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title            = CONV string( 'OPEN FLIGHT SHEDULE FILE' ) " Title Of File Open Dialog
      default_extension       = CONV string( 'TXT' )                 " Default Extension
*     DEFAULT_FILENAME        =                  " Default File Name
*     FILE_FILTER             =                  " File Extension Filter String
*     WITH_ENCODING           =                  " File Encoding
*     INITIAL_DIRECTORY       =                  " Initial Directory
*     MULTISELECTION          =                  " Multiple selections poss.
    CHANGING
      file_table              = lt_file_table    " Table Holding Selected Files
      rc                      = ld_rc             " Return Code, Number of Files or -1 If Error Occurred
*     USER_ACTION             =                  " User Action (See Class Constants ACTION_OK, ACTION_CANCEL)
*     FILE_ENCODING           =
    EXCEPTIONS
      file_open_dialog_failed = 1                " "Open File" dialog failed
      cntl_error              = 2                " Control error
      error_no_gui            = 3                " No GUI available
      not_supported_by_gui    = 4                " GUI does not support this
      OTHERS                  = 5
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE lt_file_table INDEX 1 INTO DATA(ls_file).
    IF sy-subrc = 0.
      p_path = ls_file-filename.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN_PROCESSING
*&---------------------------------------------------------------------*
*& Main processing
*&---------------------------------------------------------------------*
FORM main_processing .

** 1. Create one Flight Schedule
* 1.1. Create a work area form Selection Screen fields
*1.2. INSERT into table SPFLI
* 1.3. Output insert result with WRITE
*2. Upload multiple Flight Schedules (Exercise/Bonus)
* 2.1. Call GUI_UPLOAD
*2.2. SPLIT by ',' into an all characters work area
*2.3. INSERT into table SPFLI I
* 2.4. Output insert result with WRITE

  DATA: lt_log_report TYPE ty_t_log_report.
  DATA: lt_db_data TYPE ty_t_log_report.
  DATA: ls_spfli TYPE spfli.
*  DATA: LS_DB_DATA TYPE TY_T_LOG_REPORT.
  DATA: lt_spfli TYPE spfli.
  DATA: lt_upload TYPE ty_t_upload.


*  DATA: LT_UPLOAD TYPE STANDARD TABLE OF TY_UPLOAD.
  IF r_creone =  abap_true.
* Create a work area form Selection Screen fields
    PERFORM create_wa_from_sel CHANGING ls_spfli.
* INSERT into table SPFLI
    PERFORM insert_spfli USING ls_spfli
                          CHANGING lt_log_report.

** Upload multiple Flight Schedules
  ELSE.
    PERFORM upload_data_to_itab USING p_path
                                CHANGING lt_upload.
    IF lt_upload IS NOT INITIAL.
      PERFORM move_data_to_itsch USING lt_upload
                                 CHANGING lt_db_data .
      IF lt_db_data IS NOT INITIAL.

        LOOP AT lt_db_data INTO DATA(ls_db_data).
          PERFORM insert_spfli USING ls_db_data
            CHANGING lt_log_report.
        ENDLOOP.

      ENDIF.
    ENDIF.

  ENDIF.
* Output insert result with WRITE
  PERFORM output_log_report USING lt_log_report.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_WA_FROM_SEL
*&---------------------------------------------------------------------*
*& Create a work area form Selection Screen fields
*&---------------------------------------------------------------------*
*&      <-- LS_SPFLI
*&---------------------------------------------------------------------*
FORM create_wa_from_sel  CHANGING c_s_spfli TYPE spfli.
  c_s_spfli = VALUE spfli(  carrid    =   p_carrid
                      Connid    =   p_connid
                      Countryfr =   p_ctryfr
                      Cityfrom  =   p_cityfr
                      Airpfrom  =   p_airpfr
                      Countryto =   p_ctryto
                      Cityto    =   P_cityto
                      airpto    =   p_airpto
                      fltime    =   p_fltime
                      deptime   =   p_deptim
                      arrtime   =   p_arrtim
                      distance  =   p_distan
                      distid    =   p_disunt
                      fltype    =   p_fltype
                      period    =   p_period ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_SPFLI
*&---------------------------------------------------------------------*
*& INSERT into table SPFLI
*&---------------------------------------------------------------------*
*&      --> LS_SPFLI
*&      <-- LT_LOG_REPORT
*&---------------------------------------------------------------------*
FORM insert_spfli  USING    u_s_spfli
                   CHANGING c_t_log_report TYPE ty_t_log_report.

  DATA: ls_log_report TYPE ty_log_report.

  CHECK u_s_spfli IS NOT INITIAL.

  INSERT spfli FROM u_s_spfli.

  IF sy-subrc = 0.
    MOVE-CORRESPONDING u_s_spfli TO ls_log_report.
    ls_log_report-status = 'S'.
    ls_log_report-message = 'Data has been inserted successfully into flight Schedule.'.
  ELSE.
    MOVE-CORRESPONDING u_s_spfli TO ls_log_report.
    ls_log_report-status = 'E'.
    ls_log_report-message = 'Inserting error. Please check duplicated keys'.
  ENDIF.

  APPEND ls_log_report TO c_t_log_report.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form OUTPUT_LOG_REPORT
*&---------------------------------------------------------------------*
*& Output insert result with WRITE
*&---------------------------------------------------------------------*
*&      --> LT_LOG_REPORT
*&---------------------------------------------------------------------*
FORM output_log_report  USING    u_t_log_report TYPE ty_t_log_report.
  FORMAT COLOR COL_HEADING.
  WRITE: /(5)   'No.',
          (10) 'Airlie',
          (10) 'Flight No.',
          (10) 'STATUS',
          (100) 'MESSAGE'.
  FORMAT COLOR OFF.
  LOOP AT u_t_log_report INTO DATA(ls_log).
    WRITE: /(5)   sy-tabix,
            (10) ls_log-carrid,
            (10) ls_log-connid,
            (10) ls_log-status,
            (100) ls_log-message.
  ENDLOOP.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form UPLOAD_DATA_TO_ITAB
*&---------------------------------------------------------------------*
*& Up load multi row
*&---------------------------------------------------------------------*
*&      --> P_PATH
*&      <-- LT_UPLOAD
*&---------------------------------------------------------------------*
FORM upload_data_to_itab  USING    u_path
                          CHANGING c_t_upload TYPE ty_t_upload.
  DATA: Lv_subrc(2).
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = u_path
      filetype                = 'ASC'
      has_field_separator     = 'X'
*
    TABLES
      data_tab                = c_t_upload
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    lv_subrc = sy-subrc.
    MESSAGE | ERROR : { sy-subrc }.PLEASE CHECK FILE AGAIN . | TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MOVE_DATA_TO_ITSCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_UPLOAD
*&      <-- LT_DB_DATA
*&---------------------------------------------------------------------*
FORM move_data_to_itsch  USING    u_t_upload  TYPE  ty_t_upload
                         CHANGING c_t_db_data TYPE  ty_t_log_report.
  DATA : ls_upload  TYPE ty_upload,
         ls_db_data TYPE spfli.
  DATA: lfltime   TYPE string,
        ldistance TYPE string,
        lperiod   TYPE string,
        ldeptime  TYPE string,
        larrtime  TYPE string.
  DATA: lt_parts TYPE TABLE OF string,
        lv_part  TYPE string.



  LOOP AT u_t_upload INTO ls_upload.

    " SPLIT STRING BY '|' TO GET DATA
    SPLIT ls_upload-col1 AT '|' INTO ls_db_data-carrid   ls_db_data-connid    ls_db_data-countryfr ls_db_data-cityfrom
                                     ls_db_data-airpfrom ls_db_data-countryto ls_db_data-cityto    ls_db_data-airpto
                                     lfltime ldeptime larrtime ldistance ls_db_data-distid ls_db_data-fltype lperiod .

    ls_db_data-fltime = CONV s_fltime( lfltime ).

    REPLACE ALL OCCURRENCES OF ',' IN ldistance WITH space.
    ls_db_data-distance = CONV s_distance( ldistance ).
*    REPLACE ALL OCCURRENCES OF ',' IN LPERIOD WITH ''. "delete ',' in string to get number
*    LS_DB_DATA-PERIOD = CONV S_PERIOD( LPERIOD ).
    REPLACE ALL OCCURRENCES OF ':' IN ldeptime WITH space. " delete ':' to save time
    ls_db_data-deptime = CONV s_dep_time( ldeptime ).

    REPLACE ALL OCCURRENCES OF ':' IN larrtime  WITH space.  " delete ':' to save time
    ls_db_data-arrtime = CONV s_arr_time( larrtime ).
    " Thêm dữ liệu vào bảng đích
    APPEND ls_db_data TO c_t_db_data.
  ENDLOOP.
ENDFORM.

*Connid
*Countryfr
*Cityfrom
*Airpfrom
*Countryto
*Cityto
*airpto
*FLTIME
*DEPTIME
*ARRTIME
*DISTANCE
*DISTID
*FLTYPE
*PERIOD
