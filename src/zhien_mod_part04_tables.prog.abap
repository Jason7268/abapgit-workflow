*&---------------------------------------------------------------------*
*& Report ZHIEN_MOD_PART04_TABLES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_MOD_PART04_TABLES.

* Declare mont schedule structure
TYPES: BEGIN OF TY_FLISCH,
         CARRID      TYPE SPFLI-CARRID , " Airtinel
         CARRNAME    TYPE SCARR-CARRNAME, " Airline Name
         CONNID      TYPE SPFLI-CONNID, " Flight Number
         CITYFROM    TYPE SPFLI-CITYFROM,
         CITYTO      TYPE SPFLI-CITYTO,
         COUNTRYFR   TYPE SPFLI-COUNTRYFR, " Country From
         COUNTRYFRNM TYPE T005T-LANDX, " Country Name
         COUNTRYTO   TYPE SPFLI-COUNTRYTO, " Country to
         COUNTRYTONM TYPE T005T-LANDX, " Country None
       END OF TY_FLISCH.

DATA: GT_FLISCH TYPE STANDARD TABLE OF TY_FLISCH WITH HEADER LINE.

DATA: GT_FLISCH_NHL TYPE STANDARD TABLE OF TY_FLISCH.

START-OF-SELECTION.

  PERFORM FILL_ITAB_DATA TABLES GT_FLISCH.
*&---------------------------------------------------------------------*
*& Form FILL_ITAB_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FLISCH
*&---------------------------------------------------------------------*
FORM FILL_ITAB_DATA  TABLES   T_FLISCH STRUCTURE GT_FLISCH.

  T_FLISCH-CARRID = 'AZ'.

  APPEND T_FLISCH.

    T_FLISCH-CARRID = 'AA'.

  APPEND T_FLISCH.

ENDFORM.
