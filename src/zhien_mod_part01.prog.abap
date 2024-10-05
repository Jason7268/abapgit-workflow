*&---------------------------------------------------------------------*
*& Report ZHIEN_MOD_PART01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_MOD_PART01.

** 2 WAYS TO CREATE INCLUDE

*- 1 USE SE38
*INCLUDE ZHIEN_MOD01_INCL_DEF.

*- 2 Declare an include and double click to user forward mavigation
INCLUDE ZHIEN_MOD01_INCL_DEFINITIONS.


**** Declare Selection Screen ***›
PARAMETERS: P_CARRID TYPE SPFLI-CARRID OBLIGATORY.

**** Excute Event **
START-OF-SELECTION.

* Get data Flight Schedule
  SELECT CARRID
          CONNID
          CITYFROM
          CITYTO
          COUNTRYFR
          COUNTRYTO
  FROM SPFLI INTO CORRESPONDING FIELDS OF TABLE GT_FLISCH
  WHERE CARRID = P_CARRID.
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

*Get data of Country Nome
  SELECT LAND1 AS COUNTRYCO
  LANDX AS COUNTRYNAME
  FROM T005T INTO TABLE GT_S_COUNTRY
  WHERE SPRAS = SY-LANGU.
    IF SY-SUBRC <> 0.
      " No need to handle error
    ENDIF.

* Modify data of Flight Schedule for outputing
    LOOP AT GT_FLISCH ASSIGNING FIELD-SYMBOL(<GFS_FLISCH>).
*Get and set Airline Name
    READ TABLE GT_S_AIRLINE
    INTO DATA(GS_AIRLINE)
    WITH TABLE KEY CARRID = <GFS_FLISCH>-CARRID.
    IF SY-SUBRC = 0. " Success
      <GFS_FLISCH>-CARRNAME = GS_AIRLINE-CARRNAME.
    ENDIF.
*Get and set Country From Name
    READ TABLE GT_S_COUNTRY
    INTO DATA(GS_COUNTRYFR)
    WITH TABLE KEY COUNTRYCD = <GFS_FLISCH>-COUNTRYFR.
    IF SY-SUBRC = 0. " Success
      <GFS_FLISCH>-COUNTRYFRNM = GS_COUNTRYFR-COUNTRYNAME.
    ENDIF.
*Get and set Country To Name
    READ TABLE GT_S_COUNTRY
    INTO DATA(GS_COUNTRYTO)
    WITH TABLE KEY COUNTRYCD = <GFS_FLISCH>-COUNTRYTO.
    IF SY-SUBRC = 0. " Success
      <GFS_FLISCH>-COUNTRYTONM = GS_COUNTRYFR-COUNTRYNAME.
    ENDIF.
  ENDLOOP.

* Output data
  CL_DEMO_OUTPUT=>DISPLAY(
  DATA = GT_FLISCH " TEXT OR DATA
  ).
