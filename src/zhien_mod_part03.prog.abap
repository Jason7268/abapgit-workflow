*&---------------------------------------------------------------------*
*& Report ZHIEN_MOD_PART03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_MOD_PART03 NO STANDARD PAGE HEADING.

*- Declare an include and double click to user forward mavigation
INCLUDE ZHIEN_MOD03_INCL_DEFINITIONS.


**** Declare Selection Screen ***›
PARAMETERS: P_CARRID TYPE SPFLI-CARRID OBLIGATORY.
**** Excute Event **
START-OF-SELECTION.

*-- Subroutine
*-.1 Create Subroutine with using parameter.
*-.2 Create Subroutine with using parameter and type.
*-.3 Create Subroutine with using  VALUE() parameter .
*-.4 Create Subroutine with CHANGING parameters.
*-.5 Pass internal table into subrountine(ANY TABLE/STANDAED TABLE/SORTED TABLE/HASHED TABLE)
*-.6 Pass internal table into subrountine(TYPE TABLE).
*-.7 BEST PRATICES
*-++ 1. Always using Type
*-++ 2. Use USING for input para/ Donot change data of USING
*-++ 3. Use CHAGING for output/changing parameter
*-++ 4. Should not user ANY TABLE if you are not doing dynamic programming
*-++ 5. Declare TABLE TYPE and use it instead of ANY TABLE : TYPES: <ITAB NAME> TYPE STANDARD TABLE OF <STRUCTURE NAME>
*-++ 6. DO NOT use TABLES parameter


*-.8 CODING CONVENTION (RULES OD CODING)

*-9. Local Data

DATA: GD_CONNID_DUMMY TYPE SPFLI-CONNID.
* Write input parameters
PERFORM WRITE_INPUT_PARAMS USING P_CARRID GD_CONNID_DUMMY.

* Get data Flight Schedule
  PERFORM GET_DATA_FLISCH USING P_CARRID
                          CHANGING GT_FLISCH.



*Get data of Country Nome
*  PERFORM GET_DATA_COUNTRYNAME CHANGING GT_S_COUNTRY
  SELECT LAND1 AS COUNTRYCD
  LANDX AS COUNTRYNAME
  FROM T005T INTO TABLE GT_S_COUNTRY
  WHERE SPRAS = SY-LANGU.
    IF SY-SUBRC <> 0.
      " No need to handle error
    ENDIF.

* Modify data of Flight Schedule for outputing
  PERFORM MODIFY_FLISH_SCHDULE
         USING GT_S_AIRLINE
               GT_S_COUNTRY
         CHANGING GT_FLISCH.


** Output data
*  CL_DEMO_OUTPUT=>DISPLAY(
*  DATA = GT_FLISCH " TEXT OR DATA
*  ).

  FORMAT COLOR COL_HEADING.
  WRITE: /(6) 'Airlie',
          (10) 'Flight no.',
          (15) 'City from',
          (15) 'City to',
          (10) 'Country FROM',
          (10) 'COUNTRY TO'.
  FORMAT COLOR OFF.

LOOP AT GT_FLISCH INTO DATA(GF_FLISCH).
    WRITE: /(6)  GF_FLISCH-CARRID ,
            (10) GF_FLISCH-CONNID  ,
            (15) GF_FLISCH-CITYFROM ,
            (15) GF_FLISCH-CITYTO ,
            (10) GF_FLISCH-COUNTRYFR,
            (10) GF_FLISCH-COUNTRYTO.
ENDLOOP.

*&---------------------------------------------------------------------*
*& Form GET_DATA_FLISCH
*&---------------------------------------------------------------------*
*& Get data Flight Schedule
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
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
* Get data of Airline Name
  SELECT CARRID
  CARRNAME
  FROM SCARR INTO TABLE GT_S_AIRLINE.
  IF SY-SUBRC <> 0.
    " No need to handle error
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_INPUT_PARAMS
*&---------------------------------------------------------------------*
*& Write input parameters
*&---------------------------------------------------------------------*
*&      --> P_CARRID
*&---------------------------------------------------------------------*
FORM WRITE_INPUT_PARAMS  USING VALUE(U_P_CARRID) TYPE SPFLI-CARRID
                                     U_P_CONNID TYPE SPFLI-CONNID.
  WRITE: / 'Input Airline:', U_P_CARRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FLISH_SCHDULE
*&---------------------------------------------------------------------*
*& Modify data of Flight Schedule for outputing
*&---------------------------------------------------------------------*
*&      --> GT_S_AIRLINE
*&      --> GT_S_COUNTRY
*&      <-- GT_FLISCH
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
      <LFS_FLISCH>-COUNTRYTONM = LS_COUNTRYFR-COUNTRYNAME.
    ENDIF.
  ENDLOOP.

ENDFORM.
