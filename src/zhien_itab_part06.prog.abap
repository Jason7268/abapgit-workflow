*&---------------------------------------------------------------------*
*& Report ZHIEN_ITAB_PART06
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_ITAB_PART06.

*-- 1 - Sort
TYPES: BEGIN OF TY_SPFLI,
         CARRID      TYPE SPFLI-CARRID, "Airline
         CONNID      TYPE SPFLI-CONNID, "Flight Number
         CITYFROM    TYPE SPFLI-CITYFROM, "Departure City
         CITYTO      TYPE SPFLI-CITYTO, " Arrival city
         COUNTRYFR   TYPE SPFLI-COUNTRYFR, "Departure Country
         COUNTRYTO   TYPE SPFLI-COUNTRYTO, "Arrival Country
         NOTE        TYPE TEXT40,
         REVENUE_USD TYPE P LENGTH 8 DECIMALS 2,
         PASSENGER   TYPE INT8,
       END OF TY_SPFLI.

*-- 1. Basic Table Creation -
*DATA:GT_FLISCH TYPE STANDARD TABLE OF TY_SPFLI
*         WITH NON-UNIQUE KEY CITYFROM CITYTO.
*DATA: GS_FLISCH TYPE TY_SPFLI.

*SELECT * FROM SPFLI
*  INTO CORRESPONDING FIELDS OF TABLE GT_FLISCH.

* SORT GT_FLISCH. "CITYFRM/CITT TO
* SORT GT_FLISCH BY COUNTRYFR DESCENDING
*                    CITYFROM ASCENDING.
*
*  SORT GT_FLISCH BY COUNTRYFR.

*    LOOP AT GT_FLISCH INTO DATA(GS_FLISCH).
*  WRITE:/ SY-TABIX,
*          GS_FLISCH-CARRID ,
*          GS_FLISCH-CONNID  ,
*          GS_FLISCH-CITYFROM ,
*          GS_FLISCH-CITYTO ,
*          GS_FLISCH-COUNTRYFR,
*          GS_FLISCH-COUNTRYTO.
*ENDLOOP.

*SORT GT_FLISCH.
*DELETE ADJACENT DUPLICATES FROM GT_FLISCH.

*SORT GT_FLISCH BY COUNTRYFR." FIRTS SORT AFTER DELE TO GROUOP LIKE DATA TO DELE
*DELETE ADJACENT DUPLICATES FROM GT_FLISCH COMPARING COUNTRYFR.
*
*LOOP AT GT_FLISCH INTO GS_FLISCH.
*  WRITE:/ 'DEL DUP',
*          SY-TABIX,
*          GS_FLISCH-CARRID ,
*          GS_FLISCH-CONNID  ,
*          GS_FLISCH-CITYFROM ,
*          GS_FLISCH-CITYTO ,
*          GS_FLISCH-COUNTRYFR,
*          GS_FLISCH-COUNTRYTO.
*ENDLOOP.

*- 3 COLLECT
DATA: GT_FLIREV TYPE STANDARD TABLE OF TY_SPFLI.
DATA: GS_FLIREV TYPE TY_SPFLI.

GS_FLIREV = VALUE #(  CARRID = 'VA'
                      CONNID = '0224'
                      CITYFROM = 'HO CHI MINH'
                      CITYTO = 'DA LAT'
                      COUNTRYFR = 'VN'
                      COUNTRYTO = 'VN'
                      REVENUE_USD = ' 230000'
                      PASSENGER = 5600 ) .
APPEND GS_FLIREV TO GT_FLIREV.

GS_FLIREV = VALUE #( CARRID = 'VJ'
                      CONNID  = '6324'
                      CITYFROM = 'HO CHI MINH'
                      CITYTO = 'DA LAT'
                      COUNTRYFR = 'VN'
                      COUNTRYTO = 'VN'
                      REVENUE_USD = '189000'
                      PASSENGER = 3900 ) .
APPEND GS_FLIREV TO GT_FLIREV.

GS_FLIREV = VALUE #( CARRID = 'BB'"'
                      CONNID = '5460'
                      CITYFROM = 'HO CHI MINH'
                      CITYTO = 'DA LAT'
                      COUNTRYFR = 'VN'
                      COUNTRYTO = 'VN'
                      REVENUE_USD = '8900'
                      PASSENGER = 1251 ).
APPEND GS_FLIREV TO GT_FLIREV.

*TYPES: BEGIN OF TY_SUMREV,
*         CITYFROM    TYPE SPFLI-CITYFROM, "Departure City
*         CITYTO      TYPE SPFLI-CITYTO, " Arrival city
*         COUNTRYFR   TYPE SPFLI-COUNTRYFR, "Departure Country
*         COUNTRYTO   TYPE SPFLI-COUNTRYTO, "Arrival Country
*         NOTE        TYPE TEXT40,
*         REVENUE_USD TYPE P LENGTH 8 DECIMALS 2,
*         PASSENGER   TYPE INT8,
*       END OF TY_SUMREV.
*DATA: GT_SUMREV TYPE STANDARD TABLE OF TY_SUMREV.
*DATA: GS_SUMREV TYPE TY_SUMREV.
*
*LOOP AT GT_FLIREV INTO GS_FLIREV.
*  MOVE-CORRESPONDING GS_FLIREV TO GS_SUMREV.
*  COLLECT GS_SUMREV INTO GT_SUMREV.
*ENDLOOP.
*
**CL_DEMO_OUTPUT=>DISPLAY(
**  DATA     = GT_FLIREV                 " Text or Data
***  NAME    =                  " Name
***  EXCLUDE =                  " Exclude structure components
***  INCLUDE =                  " Include structure components
**).
*
*CL_DEMO_OUTPUT=>DISPLAY(
*  DATA     = GT_SUMREV                 " Text or Data
**  NAME    =                  " Name
**  EXCLUDE =                  " Exclude structure components
**  INCLUDE =                  " Include structure components
*).

*--4 COPY ---
DATA: GT_FLIREV2 TYPE STANDARD TABLE OF TY_SPFLI.

GS_FLIREV = VALUE #( CARRID = 'BB'"'
                      CONNID = '4560'
                      CITYFROM = 'HO CHI MINH'
                      CITYTO = 'DA LAT'
                      COUNTRYFR = 'VN'
                      COUNTRYTO = 'VN'
                      REVENUE_USD = '8900'
                      PASSENGER = 1251 ).
APPEND GS_FLIREV TO GT_FLIREV2.

*GT_FLIREV2 = GT_FLIREV. " LOST OLD DATA TABLE DESTINATION
APPEND LINES OF GT_FLIREV TO GT_FLIREV2.

CL_DEMO_OUTPUT=>DISPLAY(
  DATA     = GT_FLIREV2                " Text or Data
*  NAME    =                  " Name
*  EXCLUDE =                  " Exclude structure components
*  INCLUDE =                  " Include structure components
).

*--5 GET ITAB INFORMATION ---
DESCRIBE TABLE GT_FLIREV2 KIND DATA(VKIND)
                          LINES DATA(V_LINE)
                          OCCURS DATA(V_OCCURS).

WRITE: / 'INFOR TABL: ', VKIND, V_LINE, V_OCCURS.
