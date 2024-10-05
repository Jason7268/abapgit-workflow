*&---------------------------------------------------------------------*
*& Report ZHIEN_ITAB_PART02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_ITAB_PART02.
* &
*& BASIC INTERNAL TABLE
* &
*-- 0. What is HEADER LINE?
*- HEADER LINE is a special work area
*- It is created with internal table ith HEADER LINE
*-- 1. Create internal Table with TYPE and options WITH HEADER LINE
TYPES: BEGIN OF TY_SPFLI,
         CARRID    TYPE   SPFLI-CARRID, " Airline
         CONNID    TYPE   SPFLI-CONNID, " Flight Number
         CITYFROM  TYPE SPFLI-CITYFROM, " Departure City
         CITYTO    TYPE   SPFLI-CITYTO, " Arrival city
         COUNTRYFR TYPE SPFLI-COUNTRYFR, " Departure Country
         COUNTRYTO TYPE SPFLI-COUNTRYTO, " Arrival Country
         NOTE      TYPE     TEXT40,
       END OF TY_SPFLI.

*-- 1. Create internal Table with TYPE and options WITH HEADER LINE
*DATA: GT_SPFLI_WHL TYPE STANDARD TABLE OF TY_SPFLI WITH HEADER LINE.
*
**-- 2. Using internal table with HEADER LINE (APPEND, READ, LOOP)
*GT_SPFLI_WHL-CARRID = 'AA'.
*GT_SPFLI_WHL-CONNID = '4578'.
*GT_SPFLI_WHL-CITYFROM = 'BEIJING'.
*GT_SPFLI_WHL-CITYTO = 'HA NOI'.
*APPEND GT_SPFLI_WHL.
*
*GT_SPFLI_WHL-CARRID = 'VA'.
*GT_SPFLI_WHL-CONNID = '0125'.
*GT_SPFLI_WHL-CITYFROM = 'DA NANG'.
*GT_SPFLI_WHL-CITYTO = 'HA NOI'.
*APPEND GT_SPFLI_WHL.
*
*READ TABLE GT_SPFLI_WHL
*  WITH KEY CARRID = 'VA'.
*IF SY-SUBRC = 0.
*  WRITE: 'READ ', GT_SPFLI_WHL-CARRID, GT_SPFLI_WHL-CONNID.
*ENDIF.
*
*LOOP AT GT_SPFLI_WHL.
*  WRITE:/ 'LOOP: ',SY-TABIX, GT_SPFLI_WHL-CARRID, GT_SPFLI_WHL-CONNID.
*ENDLOOP.


*CL_DEMO_OUTPUT=>DISPLAY(
*  DATA    = GT_SPFLI_WHL[]                 " Text or Data , [] TRANFER TABLE
*  NAME    =                  " Name
*).
*CLEAR GT_SPFLI_WHL. "ONLY CLEAR WORK AREA, DONT CLEAR ITAB


*-- 3. Create internal Table with TYPE with no HEADER LINE
*DATA: GT_SPFLI TYPE STANDARD TABLE OF TY_SPFLI.
*DATA: GS_SPFLI TYPE TY_SPFLI.
*
**-- 4. Using internal table with no HEADER LINE (APPEND, READ, LOOP)
*GS_SPFLI-CARRID = 'AA'.
*GS_SPFLI-CONNID = '4578'.
*GS_SPFLI-CITYFROM = 'BEIJING'.
*GS_SPFLI-CITYTO = 'HA NOI'.
*APPEND GS_SPFLI TO GT_SPFLI.
*
*GS_SPFLI-CARRID = 'VA'.
*GS_SPFLI-CONNID = '0125'.
*GS_SPFLI-CITYFROM = 'DA NANG'.
*GS_SPFLI-CITYTO = 'HA NOI'.
*APPEND GS_SPFLI TO GT_SPFLI.
*
*CLEAR GS_SPFLI.
*READ TABLE GT_SPFLI INTO GS_SPFLI
*  WITH KEY CARRID = 'VA'.
*IF SY-SUBRC = 0.
*  WRITE: 'READ WITH WORK AREA', GS_SPFLI-CARRID, GS_SPFLI-CONNID.
*ENDIF.
*
*LOOP AT GT_SPFLI INTO GS_SPFLI.
*  WRITE:/ 'LOOP: ',SY-TABIX, GS_SPFLI-CARRID, GS_SPFLI-CONNID.
*ENDLOOP.
*
*CL_DEMO_OUTPUT=>DISPLAY(
*  DATA    = GT_SPFLI                 " Text or Data , [] TRANFER TABLE
**  NAME    =                  " Name
*).
*-- 5. Create internal table with OCCURRS n (very old and obsolete)

DATA: BEGIN OF GT_OLD_SPFLI OCCURS 100, "WITH HEADER LINE
         CARRID    TYPE   SPFLI-CARRID, " Airline
         CONNID    TYPE   SPFLI-CONNID, " Flight Number
         CITYFROM  TYPE SPFLI-CITYFROM, " Departure City
         CITYTO    TYPE   SPFLI-CITYTO, " Arrival city
         COUNTRYFR TYPE SPFLI-COUNTRYFR, " Departure Country
         COUNTRYTO TYPE SPFLI-COUNTRYTO, " Arrival Country
         NOTE      TYPE     TEXT40,
       END OF GT_OLD_SPFLI.
      GT_OLD_SPFLI-CARRID = 'AA'.

DATA: GT_OLD_SPFLI_2 TYPE TY_SPFLI OCCURS 0. "WITHOUT HEADER LINE
*       GT_OLD_SPFLI_2-CARRID = '100'.
