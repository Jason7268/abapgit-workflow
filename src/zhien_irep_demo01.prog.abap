*&---------------------------------------------------------------------*
*& Report ZHIEN_IREP_DEMO01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_irep_demo01 LINE-SIZE 250.

TYPES: BEGIN OF TY_FLIGHT_SCH,
          CARRID    TYPE SPFLI-CARRID,
          CONNID    TYPE SPFLI-CONNID,
          COUNTRYFR TYPE SPFLI-COUNTRYFR,
          CITYFROM  TYPE SPFLI-CITYFROM,
          AIRPFROM  TYPE SPFLI-AIRPFROM,
          COUNTRYTO TYPE SPFLI-COUNTRYTO,
          CITYTO    TYPE SPFLI-CITYTO,
          AIRPTO    TYPE SPFLI-AIRPTO,
          FLTIME    TYPE SPFLI-FLTIME,
          DEPTIME   TYPE SPFLI-DEPTIME,
          ARRTIME   TYPE SPFLI-ARRTIME,
          PERIOD    TYPE SPFLI-PERIOD,
          SCHEDULED_LINE TYPE I,
       END OF TY_FLIGHT_SCH.

DATA: GT_FLIGHT_SCH TYPE STANDARD TABLE OF TY_FLIGHT_SCH.
DATA: gd_carrid TYPE spfli-carrid,
      gd_connid TYPE spfli-connid.
SELECT-OPTIONS: s_carrid FOR gd_carrid,
s_connid FOR gd_connid.

START-OF-SELECTION.
* Get SPFLI (Flights Schedule) join SFLIGHT (Flights)
  PERFORM get_flight_schedule.
* WRITE report
  PERFORM write_report.

  TOP-OF-PAGE.
  PERFORM WRITE_TOP_PAGE.
*&---------------------------------------------------------------------*
*& Form get_flight_schedule
*&---------------------------------------------------------------------*
*& Get SPFLI (Flights Schedule) join SFLIGHT (Flights)
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_flight_schedule .
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
FORM write_report .

  DATA: LD_LINENO TYPE I.

  LOOP AT  GT_FLIGHT_SCH INTO DATA(LS_FLISCH).
    WRITE: /(5) SY-TABIX, SY-VLINE,
            (8) LS_FLISCH-CARRID, SY-VLINE,
           (11) LS_FLISCH-CONNID, SY-VLINE,
           (16) LS_FLISCH-COUNTRYFR, SY-VLINE,
           (15) LS_FLISCH-CITYFROM, SY-VLINE,
           (12) LS_FLISCH-AIRPFROM, SY-VLINE,
           (16) LS_FLISCH-COUNTRYTO, SY-VLINE,
           (15) LS_FLISCH-CITYTO, SY-VLINE,
           (14) LS_FLISCH-AIRPTO, SY-VLINE,
           (12) LS_FLISCH-FLTIME, SY-VLINE,
           (15) LS_FLISCH-DEPTIME, SY-VLINE,
           (15) LS_FLISCH-ARRTIME, SY-VLINE,
            (7) LS_FLISCH-PERIOD, SY-VLINE,
           (18) LS_FLISCH-SCHEDULED_LINE,  SY-VLINE.
      LD_LINENO += 1.

      IF LD_LINENO MOD 20 = 0.
        NEW-PAGE.
      ENDIF.
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
FORM write_top_page .
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
