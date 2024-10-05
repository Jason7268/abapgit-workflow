*&---------------------------------------------------------------------*
*& Report ZHIEN_MOD_PART04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_MOD_PART04 NO STANDARD PAGE HEADING.

*- Declare an include and double click to user forward mavigation
INCLUDE ZHIEN_MOD04_INCL_DEFINITIONS.


**** Declare Selection Screen ***›
PARAMETERS: P_CARRID TYPE SPFLI-CARRID OBLIGATORY.
**** Excute Event **
START-OF-SELECTION.

*- MAIN PROCESSING
PERFORM MAIN_PROGRAM USING P_CARRID.



*&---------------------------------------------------------------------*
*& Form GET_DATA_FLISCH
*&---------------------------------------------------------------------*
*& Get data Flight Schedule
*&---------------------------------------------------------------------*
*& -->  U_P_CARRID       text
*& <--  C_T_FLISCH       text
*&---------------------------------------------------------------------*
FORM GET_DATA_FLISCH USING U_P_CARRID TYPE SPFLI-CARRID
                     CHANGING C_T_FLISCH TYPE TY_T_FLISCH.

  SELECT CARRID
          CONNID
          CITYFROM
          CITYTO
          COUNTRYFR
          COUNTRYTO
  FROM SPFLI INTO CORRESPONDING FIELDS OF TABLE C_T_FLISCH
  WHERE CARRID = U_P_CARRID.
  IF SY-SUBRC <> 0.
    MESSAGE 'Data not found' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_INPUT_PARAMS
*&---------------------------------------------------------------------*
*& Write input parameters
*&---------------------------------------------------------------------*
*&      --> P_CARRID
*&---------------------------------------------------------------------*
FORM WRITE_INPUT_PARAMS  USING VALUE(U_P_CARRID) TYPE SPFLI-CARRID.
       WRITE: / 'Input Airline:', U_P_CARRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FLISH_SCHDULE
*&---------------------------------------------------------------------*
*& Modify data of Flight Schedule for outputing
*&---------------------------------------------------------------------*
*&      --> GU_T_S_AIRLINE
*&      --> U_T_S_COUNTRY
*&      <-- C_T_FLISCH
*&---------------------------------------------------------------------*
FORM MODIFY_FLISH_SCHDULE  USING    U_T_S_AIRLINE TYPE TY_T_AIRLINE
                                    U_T_S_COUNTRY TYPE TY_T_COUNTRY
                           CHANGING C_T_FLISCH TYPE TY_T_FLISCH.
  LOOP AT C_T_FLISCH ASSIGNING FIELD-SYMBOL(<LFS_FLISCH>).
*Get and set Airline Name
    READ TABLE U_T_S_AIRLINE
    INTO DATA(LS_AIRLINE)
    WITH TABLE KEY CARRID = <LFS_FLISCH>-CARRID.
    IF SY-SUBRC = 0. " Success
      <LFS_FLISCH>-CARRNAME = LS_AIRLINE-CARRNAME.
    ENDIF.

*Get and set Country From Name
    READ TABLE U_T_S_COUNTRY
    INTO DATA(LS_COUNTRYFR)
    WITH TABLE KEY COUNTRYCD = <LFS_FLISCH>-COUNTRYFR.
    IF SY-SUBRC = 0. " Success
      <LFS_FLISCH>-COUNTRYFRNM = LS_COUNTRYFR-COUNTRYNAME.
    ENDIF.
*Get and set Country To Name
    READ TABLE U_T_S_COUNTRY
    INTO DATA(LS_COUNTRYTO)
    WITH TABLE KEY COUNTRYCD = <LFS_FLISCH>-COUNTRYTO.
    IF SY-SUBRC = 0. " Success
      <LFS_FLISCH>-COUNTRYTONM = LS_COUNTRYTO-COUNTRYNAME.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_AIRLINE_NAME
*&---------------------------------------------------------------------*
*& Get data of Airline Name
*&---------------------------------------------------------------------*
*&      <-- C_TS_AIRLINE
*&---------------------------------------------------------------------*
FORM GET_AIRLINE_NAME  CHANGING C_TS_AIRLINE TYPE TY_T_AIRLINE.
  SELECT CARRID CARRNAME
        FROM SCARR INTO TABLE C_TS_AIRLINE.
  IF SY-SUBRC <> 0.
    " No need to handle error
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_COUNTRY_NAME
*&---------------------------------------------------------------------*
*& Get data of Country Nome
*&---------------------------------------------------------------------*
*&      <-- C_T_S_COUNTRY
*&---------------------------------------------------------------------*
FORM GET_COUNTRY_NAME  CHANGING C_T_S_COUNTRY TYPE TY_T_COUNTRY.
  SELECT LAND1 AS COUNTRYCD
         LANDX AS COUNTRYNAME
      FROM T005T INTO TABLE C_T_S_COUNTRY
      WHERE SPRAS = SY-LANGU.
  IF SY-SUBRC <> 0.
    " No need to handle error
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form OUTPUT_REPORT
*&---------------------------------------------------------------------*
*& Output data
*&---------------------------------------------------------------------*
*&      --> U_T_FLISCH
*&---------------------------------------------------------------------*
FORM OUTPUT_REPORT  USING    U_T_FLISCH TYPE TY_T_FLISCH.
  FORMAT COLOR COL_HEADING.
  WRITE: /(10) 'Airlie',
          (20) 'Flight no.',
          (12) 'City from',
          (20) 'City to',
          (20) 'Country FROM',
          (20) 'COUNTRY TO'.
  FORMAT COLOR OFF.

  LOOP AT U_T_FLISCH INTO DATA(LS_FLISCH).
    WRITE: /(10) LS_FLISCH-CARRID ,
            (20) LS_FLISCH-CONNID  ,
            (12) LS_FLISCH-CITYFROM ,
            (20) LS_FLISCH-CITYTO ,
            (20) LS_FLISCH-COUNTRYFR,
            (20) LS_FLISCH-COUNTRYTO.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN_PROGRAM
*&---------------------------------------------------------------------*
*& *- MAIN PROCESSING
*&---------------------------------------------------------------------*
*&      --> U_P_CARRID
*&---------------------------------------------------------------------*
FORM MAIN_PROGRAM  USING U_P_CARRID TYPE SPFLI-CARRID.

* DecLare Flight schedule internal table
DATA: LT_FLISCH TYPE TY_T_FLISCH.

* Declare Airline Name internal table
DATA: LT_S_AIRLINE TYPE TY_T_AIRLINE .

* Declare Country Name internal table
DATA: LT_S_COUNTRY TYPE TY_T_COUNTRY .

* Write input parameters
  PERFORM WRITE_INPUT_PARAMS USING U_P_CARRID.

* Get data Flight Schedule
  PERFORM GET_DATA_FLISCH USING U_P_CARRID
                          CHANGING LT_FLISCH.

* Get data of Airline Name
  PERFORM GET_AIRLINE_NAME CHANGING LT_S_AIRLINE .


*Get data of Country Nome
  PERFORM GET_COUNTRY_NAME CHANGING LT_S_COUNTRY.


* Modify data of Flight Schedule for outputing
  PERFORM MODIFY_FLISH_SCHDULE
         USING LT_S_AIRLINE
               LT_S_COUNTRY
         CHANGING LT_FLISCH.


  PERFORM OUTPUT_REPORT USING LT_FLISCH.

ENDFORM.
