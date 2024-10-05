*&---------------------------------------------------------------------*
*& Include          ZHIEN_MOD01_INCL_DEFINITIONS
*&---------------------------------------------------------------------*

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
       END OF TY_FLISCH,
       TY_T_FLISCH TYPE STANDARD TABLE OF TY_FLISCH.

*Declare Airline Name STRUCTURE
TYPES: BEGIN OF TY_AIRLINE,
         CARRID   TYPE SCARR-CARRID, " Airline
         CARRNAME TYPE SCARR-CARRNAME, " Airline Name
       END OF TY_AIRLINE,
       TY_T_AIRLINE TYPE SORTED TABLE OF TY_AIRLINE
                          WITH NON-UNIQUE KEY CARRID.

*Declare Country Name STRUCTURE
TYPES: BEGIN OF TY_COUNTRY,
         COUNTRYCD   TYPE T005T-LAND1, " Country codel
         COUNTRYNAME TYPE T005t-LANDX, " Country Nome
       END OF TY_COUNTRY,
       TY_T_COUNTRY TYPE SORTED TABLE OF TY_COUNTRY
                          WITH NON-UNIQUE KEY COUNTRYCD.
