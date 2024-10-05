*&---------------------------------------------------------------------*
*& Report ZHIEN_ITAB_PART01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_ITAB_PART01.

*& WORK AREA & STRUCTURE
* &
*--STRUCTURE
*- 1. Creating a custom Structure in your program
TYPES: BEGIN OF TY_SPFLI,
         CARRID    TYPE   SPFLI-CARRID, " Airline
         CONNID    TYPE   SPFLI-CONNID, " Flight Number
         CITYFROM  TYPE SPFLI-CITYFROM, " Departure City
         CITYTO    TYPE   SPFLI-CITYTO, " Arrival city
         COUNTRYFR TYPE SPFLI-COUNTRYFR, " Departure Country
         COUNTRYTO TYPE SPFLI-COUNTRYTO, " Arrival Country
         NOTE      TYPE     TEXT40,
       END OF TY_SPFLI.

*- 2. Creating a custom Structure in SE11
*ZHIEN_SPFLI_DEMO

*------ WORK AREA
*
*-- WORK AREA
*- 1. Using TYPE TYPEstructure name (Table, Global Structure YSXXX_SPFLI_DEMO, local structure TY_SPFLI)
*DATA: GS_TBL_NAME TYPE SPFLI.
*
*SELECT * FROM SPFLI INTO GS_TBL_NAME UP TO 1 ROWS.
*  ENDSELECT.
*
*  WRITE: / GS_TBL_NAME-CARRID, GS_TBL_NAME-CONNID, GS_TBL_NAME-COUNTRYFR.

*- Global structure ZHIEN_SPFLI_DEMO
*  DATA: GS_GBL_SPFLI TYPE ZHIEN_SPFLI_DEMO.
*
*  SELECT * FROM SPFLI INTO CORRESPONDING FIELDS OF GS_GBL_SPFLI UP TO 1 ROWS
*    WHERE COUNTRYFR = 'DE'.
*  ENDSELECT.
*
*   WRITE: / GS_GBL_SPFLI-CARRID, GS_GBL_SPFLI-CONNID, GS_GBL_SPFLI-COUNTRYFR.

*- local structure
*DATA: GS_SPFLI TYPE ZHIEN_SPFLI_DEMO.
*
*SELECT * FROM SPFLI INTO CORRESPONDING FIELDS OF GS_SPFLI UP TO 1 ROWS
*  WHERE COUNTRYFR = 'JP'.
*ENDSELECT.
*WRITE: / GS_SPFLI-CARRID, GS_SPFLI-CONNID, GS_SPFLI-COUNTRYFR.

*- 2. TABLES
*TABLES: SPFLI, *SPFLI. " MAX CREATE 2 WORK AREA
*
*SELECT * FROM SPFLI UP TO 1 ROWS
*  WHERE COUNTRYFR = 'US'.
*  ENDSELECT.
*
*  WRITE: / SPFLI-CARRID, SPFLI-CONNID, SPFLI-COUNTRYFR, SPFLI-CITYFROM.
*
*  SELECT * FROM *SPFLI UP TO 1 ROWS
*  WHERE COUNTRYFR = 'JP'.
*  ENDSELECT.
*
*  WRITE: / *SPFLI-CARRID, *SPFLI-CONNID, *SPFLI-COUNTRYFR, *SPFLI-CITYFROM.
*
*  TABLES: ZHIEN_SPFLI_DEMO.
*
*SELECT * FROM SPFLI  INTO CORRESPONDING FIELDS OF ZHIEN_SPFLI_DEMO UP TO 1 ROWS
*  WHERE COUNTRYFR = 'US'.
*  ENDSELECT.
*
*  WRITE: /ZHIEN_SPFLI_DEMO.

*- MOVE DATA INTO WORK AREA
DATA: GS_SPFLI TYPE TY_SPFLI.
DATA: GS_SPFLI_TBL TYPE SPFLI.

SELECT * FROM SPFLI INTO GS_SPFLI_TBL UP TO 1 ROWS.
ENDSELECT.

MOVE-CORRESPONDING GS_SPFLI_TBL TO GS_SPFLI.

*WRITE: / GS_SPFLI-CARRID, GS_SPFLI-CONNID, GS_SPFLI-COUNTRYFR, GS_SPFLI-CITYFROM.
WRITE: / GS_SPFLI.