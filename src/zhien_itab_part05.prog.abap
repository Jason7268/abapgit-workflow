*&---------------------------------------------------------------------*
*& Report ZHIEN_ITAB_PART05
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_ITAB_PART05.

*----Hash TABLE

*-- 1. Basic Table Creation -

*-- 10. Clear an Internal Table -
TYPES: BEGIN OF TY_SPFLI,
         CARRID    TYPE SPFLI-CARRID, "Airline
         CONNID    TYPE SPFLI-CONNID, "Flight Number
         CITYFROM  TYPE SPFLI-CITYFROM, "Departure City
         CITYTO    TYPE SPFLI-CITYTO, " Arrival city
         COUNTRYFR TYPE SPFLI-COUNTRYFR, "Departure Country
         COUNTRYTO TYPE SPFLI-COUNTRYTO, "Arrival Country
         NOTE      TYPE TEXT40,
       END OF TY_SPFLI.

*-- 1. Basic Table Creation -
       DATA:GT_H_FLISCH TYPE HASHED TABLE OF TY_SPFLI
                WITH UNIQUE KEY CARRID CONNID.
       DATA: GS_FLISCH TYPE TY_SPFLI.

*-- 2. Basic Appending Data --
*GS_FLISCH-CARRID = 'VA'.
*GS_FLISCH-CONNID = '2268'.
*GS_FLISCH-CITYFROM = 'HA NOI'.
*GS_FLISCH-CITYTO ='DA NANG'.
*GS_FLISCH-COUNTRYFR = 'VN'.
*GS_FLISCH-COUNTRYTO = 'VN'.
*APPEND GS_FLISCH TO GT_H_FLISCH.

*-- 3. Basic Inserting Data --
*GS_FLISCH-CARRID = 'VA'.
*GS_FLISCH-CONNID = '2268'.
*GS_FLISCH-CITYFROM = 'HA NOI'.
*GS_FLISCH-CITYTO ='DA NANG'.
*GS_FLISCH-COUNTRYFR = 'VN'.
*GS_FLISCH-COUNTRYTO = 'VN'.
*INSERT GS_FLISCH INTO TABLE GT_H_FLISCH.

"TEST DUPLICATE
*GS_FLISCH-CARRID = 'VA'.
*GS_FLISCH-CONNID = '2268'.
*GS_FLISCH-CITYFROM = 'HA NOI'.
*GS_FLISCH-CITYTO ='DA NANG'.
*GS_FLISCH-COUNTRYFR = 'VN'.
*GS_FLISCH-COUNTRYTO = 'VN'.
*INSERT GS_FLISCH INTO TABLE GT_H_FLISCH.
*WRITE: / SY-SUBRC .

SELECT * FROM SPFLI INTO CORRESPONDING FIELDS OF TABLE GT_H_FLISCH
    UP TO 30 ROWS.

*-- 4. SINGLE ACCESS: Basic Read Data --
*READ TABLE GT_H_FLISCH INTO GS_FLISCH  "Hash access
*  WITH TABLE KEY CARRID = 'DL'
*                 CONNID = '1699'.

*LOOP AT GT_H_FLISCH INTO GS_FLISCH.
*  WRITE:/ GS_FLISCH-CARRID ,
*          GS_FLISCH-CONNID  ,
*          GS_FLISCH-CITYFROM ,
*          GS_FLISCH-CITYTO ,
*          GS_FLISCH-COUNTRYFR,
*          GS_FLISCH-COUNTRYTO.
*ENDLOOP.

*READ TABLE GT_H_FLISCH INTO GS_FLISCH "Linear search
*  WITH KEY CITYFROM = 'NEW YORK'.
*
*IF SY-SUBRC = 0.
*  WRITE:/ SY-TABIX,
*          GS_FLISCH-CARRID ,
*          GS_FLISCH-CONNID  ,
*          GS_FLISCH-CITYFROM ,
*          GS_FLISCH-CITYTO ,
*          GS_FLISCH-COUNTRYFR,
*          GS_FLISCH-COUNTRYTO.
*ENDIF.
*-- 5. LOOP ACCESS: Basic Loop --
*LOOP AT GT_H_FLISCH INTO GS_FLISCH.
*  WRITE:/ SY-TABIX,
*          GS_FLISCH-CARRID ,
*          GS_FLISCH-CONNID  ,
*          GS_FLISCH-CITYFROM ,
*          GS_FLISCH-CITYTO ,
*          GS_FLISCH-COUNTRYFR,
*          GS_FLISCH-COUNTRYTO.
*ENDLOOP.

*READ TABLE GT_H_FLISCH INTO GS_FLISCH INDEX 1. " no read index

*-- 6. SINGLE ACCESS WITH >, <, <= , >=, <>, IN, LIKE: Basic Read Data --
*-- No Diff

*-- 7. Modifying Data using Work Area --
*-- No Diff/ no modify
*LOOP AT GT_H_FLISCH INTO GS_FLISCH.
*    IF GS_FLISCH-COUNTRYFR <> GS_FLISCH-COUNTRYTO.
*      GS_FLISCH-NOTE = 'International'.
*    ELSE.
*      GS_FLISCH-NOTE = 'Domestic'.
*     " GS_FLISCH-CARRID = '**'.
*    ENDIF.
*    MODIFY GT_H_FLISCH FROM GS_FLISCH. " Get sy-tabix to edit, buts hash tb not have
*  ENDLOOP.

*-- 8. Modifying Data using Field Symbol --
FIELD-SYMBOLS: <GFS_FLISCH> TYPE TY_SPFLI.
LOOP AT GT_H_FLISCH ASSIGNING <GFS_FLISCH>.
  IF <GFS_FLISCH>-COUNTRYFR <> <GFS_FLISCH>-COUNTRYTO .
    <GFS_FLISCH>-NOTE = 'Intenation'.
  ELSE.
    <GFS_FLISCH>-NOTE = 'Domestic'.
  ENDIF.

ENDLOOP.

LOOP AT GT_H_FLISCH INTO GS_FLISCH.
  WRITE:/ SY-TABIX,
          GS_FLISCH-CARRID ,
          GS_FLISCH-CONNID  ,
          GS_FLISCH-CITYFROM ,
          GS_FLISCH-CITYTO ,
          GS_FLISCH-COUNTRYFR,
          GS_FLISCH-COUNTRYTO,
          GS_FLISCH-NOTE.
ENDLOOP.

*-- 9. Delete a record from Internal Table --
