*&---------------------------------------------------------------------*
*& Report ZHIEN_CREP_DEMO04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_CREP_DEMO05.

*Block 1: Create Flight Schedule Options
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-B01.
  PARAMETERS: R_CREONE RADIOBUTTON GROUP RB1 USER-COMMAND RBCM DEFAULT 'X',
              R_UPLOAD RADIOBUTTON GROUP RB1.
SELECTION-SCREEN END OF BLOCK B01.
* Block 2: Create a Flight Schedule
SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-B02.
  PARAMETERS: P_CARRID TYPE SPFLI-CARRID MODIF ID BL2,
              P_CONNID TYPE SPFLI-CONNID MODIF ID BL2,
              P_CTRYFR TYPE SPFLI-COUNTRYFR MODIF ID BL2,
              P_CITYFR TYPE SPFLI-CITYFROM MODIF ID BL2,
              P_AIRPFR TYPE SPFLI-AIRPFROM MODIF ID BL2,
              P_CTRYTO TYPE SPFLI-COUNTRYTO MODIF ID BL2,
              P_CITYTO TYPE SPFLI-CITYTO MODIF ID BL2,
              P_AIRPTO TYPE SPFLI-AIRPTO MODIF ID BL2,
              P_FLTIME TYPE SPFLI-FLTIME MODIF ID BL2,
              P_DEPTIM TYPE SPFLI-DEPTIME MODIF ID BL2,
              P_ARRTIM TYPE SPFLI-ARRTIME MODIF ID BL2,
              P_DISTAN TYPE SPFLI-DISTANCE MODIF ID BL2.
  PARAMETERS: P_DISUNT TYPE SPFLI-DISTID AS LISTBOX
                        VISIBLE LENGTH 25
                        OBLIGATORY
                        DEFAULT 'KM'
                        MODIF ID BL2,
              P_FLTYPE TYPE SPFLI-FLTYPE MODIF ID BL2,
              P_PERIOD TYPE SPFLI-PERIOD MODIF ID BL2.
SELECTION-SCREEN END OF BLOCK B02.

*Block 3: Upload multiple Flight Schedule
SELECTION-SCREEN BEGIN OF BLOCK B03 WITH FRAME TITLE TEXT-B03.
  PARAMETERS: P_PATH TYPE STRING MODIF ID BL3.
SELECTION-SCREEN END OF BLOCK B03.

INITIALIZATION.
* Initialize data for dropdownlist
  PERFORM INIT_DATA.

AT SELECTION-SCREEN OUTPUT.
*Change screen when change Radio button
  PERFORM CHANGE_SEL_SCREEN.

AT SELECTION-SCREEN.
*Input validation I
  PERFORM VALIDATE_INPUTS.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_PATH.
* File Open Dialog
    PERFORM OPEN_FILE_DIALOG.


START-OF-SELECTION.
*Main processing
*&---------------------------------------------------------------------*
*& Form change_sel_screen
*&---------------------------------------------------------------------*
*& Change screen when change Radio button
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_SEL_SCREEN .
  DATA: LD_ARRIVAL_DATE TYPE D,
        LD_DURATION     TYPE I.
  LOOP AT SCREEN.
*    IF USER CHOOSE CREATE A Fli Sche
    IF R_CREONE = ABAP_TRUE.
*      HIDE Upload block 3
      IF SCREEN-GROUP1 = 'BL3'.
        SCREEN-ACTIVE = '0'.
      ELSEIF SCREEN-GROUP1 = 'BL2'. "Show Create block 2
        SCREEN-ACTIVE = '1'.
      ENDIF.
*    IF USER CHOOSE Upload Fli Sche
    ELSE.
*      Show Upload BLOCK 3
      IF SCREEN-GROUP1 = 'BL3'.
        SCREEN-ACTIVE = '1'.
      ELSEIF SCREEN-GROUP1 = 'BL2'. "Hide Create block 2
        SCREEN-ACTIVE = '0'.
      ENDIF.
    ENDIF.
** Set screen required (icon only, no message)
    IF SCREEN-NAME = 'P_CARRID' OR
   SCREEN-NAME = 'P_CONNID' OR
   SCREEN-NAME = 'P_CTRYFR' OR
   SCREEN-NAME = 'P_CTRYTO' OR
   SCREEN-NAME = 'P_CITYFR' OR
   SCREEN-NAME = 'P_CITYTO' OR
   SCREEN-NAME = 'P_AIRPFR' OR
   SCREEN-NAME = 'P_AIRPTO'.
      SCREEN-REQUIRED = '2'.
    ENDIF.
** Disable field Flight duration
    IF SCREEN-NAME = 'P_FLTIME'.
      SCREEN-INPUT = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
**Calculate Flight duration
  LD_ARRIVAL_DATE = SY-DATUM.
  LD_ARRIVAL_DATE += P_PERIOD.
  CALL FUNCTION 'SWI_DURATION_DETERMINE'
    EXPORTING
      START_DATE = SY-DATUM
      END_DATE   = LD_ARRIVAL_DATE
      START_TIME = P_DEPTIM
      END_TIME   = P_ARRTIM
    IMPORTING
      DURATION   = LD_DURATION. " Flight Duration in seconds
  P_FLTIME   = LD_DURATION / 60.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form validate_inputs
*&---------------------------------------------------------------------*
*& *Input validation I
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATE_INPUTS .

  CHECK SY-UCOMM <> 'RBCM'.

** 1. Validate Required Fields
  IF R_CREONE = ABAP_TRUE.
    PERFORM: CHECK_REQUIRED_FIELDS USING P_CARRID TEXT-T01,
    CHECK_REQUIRED_FIELDS USING P_CONNID 'Flight Number',
    CHECK_REQUIRED_FIELDS USING P_CTRYFR 'Country From',
    CHECK_REQUIRED_FIELDS USING P_CTRYTO 'Country To',
    CHECK_REQUIRED_FIELDS USING P_CITYFR 'City From',
    CHECK_REQUIRED_FIELDS USING P_CITYTO 'City To',
    CHECK_REQUIRED_FIELDS USING P_AIRPFR 'Airport From',
    CHECK_REQUIRED_FIELDS USING P_AIRPTO 'Airport To'.
  ELSE.
    PERFORM CHECK_REQUIRED_FIELDS USING P_PATH 'Local File'.
  ENDIF.
** 2. Validate Airline Code with Table Airline Master
  PERFORM CHECK_AIRLINE_MASTER USING P_CARRID.

** 3. Validate Country Name with Table Country Master
  PERFORM CHECK_COUNTRY_MASTER USING P_CTRYFR.
  PERFORM CHECK_COUNTRY_MASTER USING P_CTRYTO.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_data
*&---------------------------------------------------------------------*
*& Initialize data for dropdownlist
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_DATA .

* INIT_DATA
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = CONV VRM_ID( 'P_DISUNT' )
      VALUES          = VALUE VRM_VALUES( ( KEY = 'KM' TEXT = 'Kilometers' )
                                        ( KEY = 'MI' TEXT = 'Miles' ) )
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
    MESSAGE 'Cannot initialize List Box Distance Unit.' TYPE 'E'.
  ENDIF.

*  DATA LP_ID TYPE INT8.
*  LP_ID = P_DISUNT.

*  DATA ls_vrmvalue TYPE lt_vrm_values WITH HEADER LINE.

*  LS_VRM_VALUES-KEY = 'MI'.
*  LS_VRM_VALUES-TEXT = 'Kilometers' .
*  APPEND LS_VRM_VALUES TO LT_VRM_VALUES.
*     ID     = CONV VRM_ID( 'P_DISUNT' )
*     VALUES = VALUE VRM_VALUES (KEY = 'KM' TEXT = 'Kilometers' )
*     (KEY   = 'MI' TEXT = 'Miles' ) )

*
*  TYPES: BEGIN OF T_VRM_VALUE,
*           KEY(40)  TYPE C,
*           TEXT(80) TYPE C,
*         END OF T_VRM_VALUE.
*  DATA LT_VRM_VALUES TYPE STANDARD TABLE OF T_VRM_VALUE WITH HEADER LINE.
*
*
*  LT_VRM_VALUES-KEY = 'KM'.
*  LT_VRM_VALUES-TEXT = 'Kilometers' .
*  APPEND LT_VRM_VALUES.
*
*  LT_VRM_VALUES-KEY = 'MI'.
*  LT_VRM_VALUES-TEXT = 'MILES' .
*  APPEND LT_VRM_VALUES.
*
*  CALL FUNCTION 'VRM_SET_VALUES'
*    EXPORTING
*      ID              = LP_ID
*      VALUES          = LT_VRM_VALUES
*    EXCEPTIONS
*      ID_ILLEGAL_NAME = 1
*      OTHERS          = 2.
*  IF SY-SUBRC <> 0.
*    MESSAGE 'Cannot initialize List Box Distance Unit.' TYPE 'E'.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_REQUIRED_FIELDS
*&---------------------------------------------------------------------*
*& Validate Required Fields
*&---------------------------------------------------------------------*
*&      --> P_CARRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_REQUIRED_FIELDS  USING    U_VALUE TYPE ANY
                                     U_FIELD_NAME TYPE STRING.
  IF U_VALUE IS INITIAL.
    MESSAGE | Vui lòng nhập dữ liệu vào trường { U_FIELD_NAME }.| TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AIRLINE_MASTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_CARRID
*&---------------------------------------------------------------------*
FORM CHECK_AIRLINE_MASTER  USING    U_CARRID TYPE SCARR-CARRID.
  SELECT SINGLE CARRID FROM SCARR
     INTO @DATA(LS_SCARR)
    WHERE CARRID = @U_CARRID.
  IF SY-SUBRC <> 0.
    MESSAGE | Invalid airline code : { U_CARRID }. Please retry with different code. | TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COUNTRY_MASTER
*&---------------------------------------------------------------------*
*&  Validate Country Name with Table Country Master
*&---------------------------------------------------------------------*
*&      --> P_CTRYFR
*&---------------------------------------------------------------------*
FORM CHECK_COUNTRY_MASTER  USING    U_COUNTRY TYPE T005-LAND1.
  SELECT SINGLE LAND1 FROM T005
    INTO @DATA(LS_LAND1)
   WHERE LAND1 = @U_COUNTRY.
  IF SY-SUBRC <> 0.
    MESSAGE | Invalid Countru code : { U_COUNTRY }. Please retry with different code. | TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form OPEN_FILE_DIALOG
*&---------------------------------------------------------------------*
*& File Open Dialog
*&---------------------------------------------------------------------*

FORM OPEN_FILE_DIALOG .
  DATA: LT_FILE_TABLE TYPE FILETABLE,
        LD_RC TYPE I.
  CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG(
    EXPORTING
      WINDOW_TITLE            = CONV STRING( 'OPEN FLIGHT SHEDULE FILE' )" Title Of File Open Dialog
      DEFAULT_EXTENSION       = CONV STRING( 'TXT' )                 " Default Extension
*      DEFAULT_FILENAME        =                  " Default File Name
*      FILE_FILTER             =                  " File Extension Filter String
*      WITH_ENCODING           =                  " File Encoding
*      INITIAL_DIRECTORY       =                  " Initial Directory
*      MULTISELECTION          =                  " Multiple selections poss.
    CHANGING
      FILE_TABLE              =  LT_FILE_TABLE    " Table Holding Selected Files
      RC                      =  LD_RC             " Return Code, Number of Files or -1 If Error Occurred
*      USER_ACTION             =                  " User Action (See Class Constants ACTION_OK, ACTION_CANCEL)
*      FILE_ENCODING           =
      EXCEPTIONS
        FILE_OPEN_DIALOG_FAILED = 1                " "Open File" dialog failed
        CNTL_ERROR              = 2                " Control error
        ERROR_NO_GUI            = 3                " No GUI available
        NOT_SUPPORTED_BY_GUI    = 4                " GUI does not support this
        OTHERS                  = 5
  ).
  IF SY-SUBRC <> 0.
   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    READ TABLE LT_FILE_TABLE INDEX 1 INTO DATA(LS_FILE).
    IF SY-SUBRC = 0.
      P_PATH = LS_FILE-FILENAME.
    ENDIF.
  ENDIF.
ENDFORM.
