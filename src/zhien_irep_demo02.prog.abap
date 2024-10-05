*&---------------------------------------------------------------------*
*& Report ZHIEN_IREP_DEMO01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_IREP_DEMO02 LINE-SIZE 250.

TYPES: BEGIN OF TY_FLIGHT_SCH,
         CARRID         TYPE SPFLI-CARRID,
         CONNID         TYPE SPFLI-CONNID,
         COUNTRYFR      TYPE SPFLI-COUNTRYFR,
         CITYFROM       TYPE SPFLI-CITYFROM,
         AIRPFROM       TYPE SPFLI-AIRPFROM,
         COUNTRYTO      TYPE SPFLI-COUNTRYTO,
         CITYTO         TYPE SPFLI-CITYTO,
         AIRPTO         TYPE SPFLI-AIRPTO,
         FLTIME         TYPE SPFLI-FLTIME,
         DEPTIME        TYPE SPFLI-DEPTIME,
         ARRTIME        TYPE SPFLI-ARRTIME,
         PERIOD         TYPE SPFLI-PERIOD,
         SCHEDULED_LINE TYPE I,
       END OF TY_FLIGHT_SCH.

DATA: GT_FLIGHT_SCH TYPE STANDARD TABLE OF TY_FLIGHT_SCH.

DATA: GT_SFLIGHT TYPE STANDARD TABLE OF SFLIGHT.

DATA: GD_CARRID TYPE SPFLI-CARRID,
      GD_CONNID TYPE SPFLI-CONNID.
SELECT-OPTIONS: S_CARRID FOR GD_CARRID,
S_CONNID FOR GD_CONNID.

START-OF-SELECTION.
* Get SPFLI (Flights Schedule) join SFLIGHT (Flights)
  PERFORM GET_FLIGHT_SCHEDULE.
* WRITE report
  PERFORM WRITE_REPORT.

TOP-OF-PAGE.
  PERFORM WRITE_TOP_PAGE.

AT LINE-SELECTION.
* Get data SFLIGHT
  PERFORM GET_SFLIGHT.

*WRITE SFLIGHT report
  PERFORM WRITE_SFLIGHT_REPORT.



*&---------------------------------------------------------------------*
*& Form get_flight_schedule
*&---------------------------------------------------------------------*
*& Get SPFLI (Flights Schedule) join SFLIGHT (Flights)
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_FLIGHT_SCHEDULE .
  SELECT  T1~CARRID,
          T1~CONNID,
          T1~COUNTRYFR,
          T1~CITYFROM,
          T1~AIRPFROM,
          T1~COUNTRYTO,
          T1~CITYTO,
          T1~AIRPTO,
          T1~FLTIME,
          T1~DEPTIME,
          T1~ARRTIME,
          T1~PERIOD,
          COUNT( T2~FLDATE ) AS SCHEDULED_ITEM
      FROM SPFLI AS T1 LEFT JOIN SFLIGHT AS T2
        ON     T1~CARRID = T2~CARRID
        AND    T1~CONNID = T2~CONNID
        WHERE  T1~CARRID IN @S_CARRID
        AND    T1~CONNID IN @S_CONNID
      GROUP BY T1~CARRID,
               T1~CONNID,
               T1~COUNTRYFR,
               T1~CITYFROM,
               T1~AIRPFROM,
               T1~COUNTRYTO,
               T1~CITYTO,
               T1~AIRPTO,
               T1~FLTIME,
               T1~DEPTIME,
               T1~ARRTIME,
               T1~PERIOD
      ORDER BY T1~CARRID,
               T1~CONNID
      INTO TABLE @GT_FLIGHT_SCH.

  IF SY-SUBRC <> 0.
* TO DO
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form write_report
*&---------------------------------------------------------------------*
*& WRITE report
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM WRITE_REPORT .

*  DATA: LD_LINENO TYPE I.

  LOOP AT  GT_FLIGHT_SCH INTO DATA(LS_FLIGHT_SCH).
    WRITE: /(5) SY-TABIX, SY-VLINE,
            (8) LS_FLIGHT_SCH-CARRID HOTSPOT COLOR COL_KEY, SY-VLINE,
           (11) LS_FLIGHT_SCH-CONNID HOTSPOT COLOR COL_KEY, SY-VLINE,
           (16) LS_FLIGHT_SCH-COUNTRYFR, SY-VLINE,
           (15) LS_FLIGHT_SCH-CITYFROM, SY-VLINE,
           (12) LS_FLIGHT_SCH-AIRPFROM, SY-VLINE,
           (16) LS_FLIGHT_SCH-COUNTRYTO, SY-VLINE,
           (15) LS_FLIGHT_SCH-CITYTO, SY-VLINE,
           (14) LS_FLIGHT_SCH-AIRPTO, SY-VLINE,
           (12) LS_FLIGHT_SCH-FLTIME, SY-VLINE,
           (15) LS_FLIGHT_SCH-DEPTIME, SY-VLINE,
           (15) LS_FLIGHT_SCH-ARRTIME, SY-VLINE,
            (7) LS_FLIGHT_SCH-PERIOD, SY-VLINE,
           (18) LS_FLIGHT_SCH-SCHEDULED_LINE HOTSPOT COLOR COL_KEY,  SY-VLINE.
*      LD_LINENO += 1.
*
*      IF LD_LINENO MOD 20 = 0.
*        NEW-PAGE.
*      ENDIF.
    GD_CARRID = LS_FLIGHT_SCH-CARRID.
    GD_CONNID = LS_FLIGHT_SCH-CONNID.
    HIDE: GD_CARRID, GD_CONNID .
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_TOP_PAGE
*&---------------------------------------------------------------------*
*& TOP OF PAGE
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM WRITE_TOP_PAGE .
* write Usernone, DATE, TIME
  WRITE: /(25) 'Usernane: '    ,  SY-UNAME.
  WRITE: /(25) 'Reported Date:',  SY-DATUM.
  WRITE: /(25) 'Reported Time ',  SY-UZEIT.

  SKIP 1.

  FORMAT COLOR COL_HEADING.
  WRITE:/(5) TEXT-H13, SY-VLINE,
         (8) TEXT-H01, SY-VLINE,
        (11) TEXT-H02, SY-VLINE,
        (16) TEXT-H03, SY-VLINE,
        (15) TEXT-H04, SY-VLINE,
        (12) TEXT-H05, SY-VLINE,
        (16) TEXT-H06, SY-VLINE,
        (15) TEXT-H07, SY-VLINE,
        (14) TEXT-H08, SY-VLINE,
        (12) TEXT-H09, SY-VLINE,
        (15) TEXT-H10, SY-VLINE,
        (15) TEXT-H11, SY-VLINE,
         (7) TEXT-H12, SY-VLINE.
  FORMAT COLOR OFF.
  FORMAT COLOR COL_TOTAL.
  WRITE: (18) TEXT-H14.
  FORMAT COLOR OFF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SFLIGHT
*&---------------------------------------------------------------------*
*& GET SFLIGHT
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SFLIGHT .
  SELECT  CARRID,
          CONNID,
          FLDATE,
          PRICE,
          CURRENCY,
          PLANETYPE,
          SEATSMAX,
          SEATSOCC,
          PAYMENTSUM,
          SEATSMAX_B,
          SEATSOCC_B,
          SEATSMAX_F,
          SEATSOCC_F
      FROM SFLIGHT
      INTO CORRESPONDING FIELDS OF TABLE @GT_SFLIGHT
      WHERE CARRID = @GD_CARRID
      AND   CONNID = @GD_CONNID
    ORDER BY FLDATE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_SFLIGHT_REPORT
*&---------------------------------------------------------------------*
*& WRITE SFLIGHT report
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM WRITE_SFLIGHT_REPORT .
* write Usernane, DATE, TIME
  WRITE: /(25) 'Usernane: '    ,  SY-UNAME.
  WRITE: /(25) 'Reported Date:',  SY-DATUM.
  WRITE: /(25) 'Reported Time ',  SY-UZEIT.

  SKIP 1.
  WRITE: /(25) 'Airline: '    ,  GD_CARRID.
  WRITE: /(25) 'Flight Number:', GD_CONNID.

  SKIP 1.

  FORMAT COLOR COL_HEADING.
  WRITE:/(5) TEXT-H13, SY-VLINE,
        (12) TEXT-H15, SY-VLINE,
        (11) TEXT-H16, SY-VLINE,
        (17) TEXT-H17, SY-VLINE,
        (17) TEXT-H18, SY-VLINE,
        (17) TEXT-H19, SY-VLINE,
        (14) TEXT-H20, SY-VLINE,
        (18) TEXT-H21.

  FORMAT COLOR OFF.

  LOOP AT GT_SFLIGHT INTO DATA(LS_SFLIGHT).
    WRITE: /(5)  SY-TABIX, SY-VLINE,
            (12) LS_SFLIGHT-FLDATE, SY-VLINE,
            (11) LS_SFLIGHT-PLANETYPE,SY-VLINE,
            (17) | { LS_SFLIGHT-SEATSOCC } / { LS_SFLIGHT-SEATSMAX   } (seats) |, SY-VLINE,
            (17) | { LS_SFLIGHT-SEATSOCC_B }/{ LS_SFLIGHT-SEATSMAX_B } (seats) |, SY-VLINE,
            (17) | { LS_SFLIGHT-SEATSOCC_F }/{ LS_SFLIGHT-SEATSMAX_F } (seats) |, SY-VLINE,
            (10) LS_SFLIGHT-PRICE CURRENCY LS_SFLIGHT-CURRENCY, (3) LS_SFLIGHT-CURRENCY, SY-VLINE,
            (13) LS_SFLIGHT-PAYMENTSUM CURRENCY LS_SFLIGHT-CURRENCY, (3) LS_SFLIGHT-CURRENCY .

ENDLOOP.


  CLEAR: GD_CARRID, GD_CONNID.
ENDFORM.
