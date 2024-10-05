*&---------------------------------------------------------------------*
*& Report ZHIEN_IREP_DEMO01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_irep_demo04 LINE-SIZE 250 NO STANDARD PAGE HEADING.

TYPES: BEGIN OF ty_flight_sch,
         carrid         TYPE spfli-carrid,
         connid         TYPE spfli-connid,
         countryfr      TYPE spfli-countryfr,
         cityfrom       TYPE spfli-cityfrom,
         airpfrom       TYPE spfli-airpfrom,
         countryto      TYPE spfli-countryto,
         cityto         TYPE spfli-cityto,
         airpto         TYPE spfli-airpto,
         fltime         TYPE spfli-fltime,
         deptime        TYPE spfli-deptime,
         arrtime        TYPE spfli-arrtime,
         period         TYPE spfli-period,
         scheduled_line TYPE i,
       END OF ty_flight_sch.

DATA: gt_flight_sch TYPE STANDARD TABLE OF ty_flight_sch.

DATA: gt_sflight TYPE STANDARD TABLE OF sflight.

DATA: gd_carrid   TYPE spfli-carrid,
      gd_connid   TYPE spfli-connid,
      gd_checkbox TYPE c.
SELECT-OPTIONS: s_carrid FOR gd_carrid,
                s_connid FOR gd_connid.

INITIALIZATION.
  SET TITLEBAR 'SEL_SCREEN'.

START-OF-SELECTION.

* Get SPFLI (Flights Schedule) join SFLIGHT (Flights)
  PERFORM get_flight_schedule.
* WRITE report
  PERFORM write_report.

TOP-OF-PAGE.
  PERFORM write_top_page.

AT LINE-SELECTION.
* Get data SFLIGHT
  PERFORM get_sflight.

*WRITE SFLIGHT report
  PERFORM write_sflight_report.

TOP-OF-PAGE DURING LINE-SELECTION.
  PERFORM write_top_page_sflight.

AT USER-COMMAND.
* Handle user command
  PERFORM handle_ucomn.


*&---------------------------------------------------------------------*
*& Form get_flight_schedule
*&---------------------------------------------------------------------*
*& Get SPFLI (Flights Schedule) join SFLIGHT (Flights)
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_flight_schedule .
  SELECT  t1~carrid,
          t1~connid,
          t1~countryfr,
          t1~cityfrom,
          t1~airpfrom,
          t1~countryto,
          t1~cityto,
          t1~airpto,
          t1~fltime,
          t1~deptime,
          t1~arrtime,
          t1~period,
          COUNT( t2~fldate ) AS scheduled_item
      FROM spfli AS t1 LEFT JOIN sflight AS t2
        ON     t1~carrid = t2~carrid
        AND    t1~connid = t2~connid
        WHERE  t1~carrid IN @s_carrid
        AND    t1~connid IN @s_connid
      GROUP BY t1~carrid,
               t1~connid,
               t1~countryfr,
               t1~cityfrom,
               t1~airpfrom,
               t1~countryto,
               t1~cityto,
               t1~airpto,
               t1~fltime,
               t1~deptime,
               t1~arrtime,
               t1~period
      ORDER BY t1~carrid,
               t1~connid
      INTO TABLE @gt_flight_sch.

  IF sy-subrc <> 0.
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

  SET TITLEBAR 'REPORT_TITLE_1'.
  SET PF-STATUS 'REPORT_STS_1'.

*  DATA: LD_LINENO TYPE I.

  LOOP AT  gt_flight_sch INTO DATA(ls_flight_sch).
    WRITE: / gd_checkbox AS CHECKBOX,
            (3) sy-tabix, sy-vline,
            (8) ls_flight_sch-carrid HOTSPOT COLOR COL_KEY, sy-vline,
           (11) ls_flight_sch-connid HOTSPOT COLOR COL_KEY, sy-vline,
           (16) ls_flight_sch-countryfr, sy-vline,
           (15) ls_flight_sch-cityfrom, sy-vline,
           (12) ls_flight_sch-airpfrom, sy-vline,
           (16) ls_flight_sch-countryto, sy-vline,
           (15) ls_flight_sch-cityto, sy-vline,
           (14) ls_flight_sch-airpto, sy-vline,
           (12) ls_flight_sch-fltime, sy-vline,
           (15) ls_flight_sch-deptime, sy-vline,
           (15) ls_flight_sch-arrtime, sy-vline,
            (7) ls_flight_sch-period, sy-vline,
           (18) ls_flight_sch-scheduled_line HOTSPOT COLOR COL_KEY,  sy-vline.
*      LD_LINENO += 1.
*
*      IF LD_LINENO MOD 20 = 0.
*        NEW-PAGE.
*      ENDIF.
    gd_carrid = ls_flight_sch-carrid.
    gd_connid = ls_flight_sch-connid.
    HIDE: gd_carrid, gd_connid .
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
  WRITE: /(25) 'Usernane: '    ,  sy-uname.
  WRITE: /(25) 'Reported Date:',  sy-datum.
  WRITE: /(25) 'Reported Time ',  sy-uzeit.

  SKIP 1.

  FORMAT COLOR COL_HEADING.
  WRITE:/(5) TEXT-h13, sy-vline,
         (8) TEXT-h01, sy-vline,
        (11) TEXT-h02, sy-vline,
        (16) TEXT-h03, sy-vline,
        (15) TEXT-h04, sy-vline,
        (12) TEXT-h05, sy-vline,
        (16) TEXT-h06, sy-vline,
        (15) TEXT-h07, sy-vline,
        (14) TEXT-h08, sy-vline,
        (12) TEXT-h09, sy-vline,
        (15) TEXT-h10, sy-vline,
        (15) TEXT-h11, sy-vline,
         (7) TEXT-h12, sy-vline.
  FORMAT COLOR OFF.
  FORMAT COLOR COL_TOTAL.
  WRITE: (18) TEXT-h14.
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
FORM get_sflight .
  SELECT  carrid,
          connid,
          fldate,
          price,
          currency,
          planetype,
          seatsmax,
          seatsocc,
          paymentsum,
          seatsmax_b,
          seatsocc_b,
          seatsmax_f,
          seatsocc_f
      FROM sflight
      INTO CORRESPONDING FIELDS OF TABLE @gt_sflight
      WHERE carrid = @gd_carrid
      AND   connid = @gd_connid
    ORDER BY fldate.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_SFLIGHT_REPORT
*&---------------------------------------------------------------------*
*& WRITE SFLIGHT report
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM write_sflight_report .

  SET TITLEBAR 'REPORT_TITLE_2'.

  LOOP AT gt_sflight INTO DATA(ls_sflight).
    WRITE: /(5)  sy-tabix, sy-vline,
            (12) ls_sflight-fldate, sy-vline,
            (11) ls_sflight-planetype,sy-vline,
            (17) | { ls_sflight-seatsocc } / { ls_sflight-seatsmax   } (seats) |, sy-vline,
            (17) | { ls_sflight-seatsocc_b }/{ ls_sflight-seatsmax_b } (seats) |, sy-vline,
            (17) | { ls_sflight-seatsocc_f }/{ ls_sflight-seatsmax_f } (seats) |, sy-vline,
            (10) ls_sflight-price CURRENCY ls_sflight-currency, (3) ls_sflight-currency, sy-vline,
            (13) ls_sflight-paymentsum CURRENCY ls_sflight-currency, (3) ls_sflight-currency .

  ENDLOOP.


  CLEAR: gd_carrid, gd_connid.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form WRITE_TOP_PAGE_SFLIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM write_top_page_sflight .
* write Usernane, DATE, TIME
  WRITE: /(25) 'Usernane: '    ,  sy-uname.
  WRITE: /(25) 'Reported Date:',  sy-datum.
  WRITE: /(25) 'Reported Time ',  sy-uzeit.

  SKIP 1.
  WRITE: /(25) 'Airline: '    ,  gd_carrid.
  WRITE: /(25) 'Flight Number:', gd_connid.

  SKIP 1.

  FORMAT COLOR COL_HEADING.
  WRITE:/(5) TEXT-h13, sy-vline,
        (12) TEXT-h15, sy-vline,
        (11) TEXT-h16, sy-vline,
        (17) TEXT-h17, sy-vline,
        (17) TEXT-h18, sy-vline,
        (17) TEXT-h19, sy-vline,
        (14) TEXT-h20, sy-vline,
        (18) TEXT-h21.

  FORMAT COLOR OFF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_UCOMN
*&---------------------------------------------------------------------*
*& Handle user command
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_ucomn .
  CASE sy-ucomm.
    WHEN 'BACK'.
*      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'DELETE'.
*     handle deletion of Flight Schedule
      PERFORM handle_delete.
    WHEN 'CREATE'.
      SUBMIT zhien_crep_demo06 VIA SELECTION-SCREEN .
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DELETE
*&---------------------------------------------------------------------*
*& handle deletion of Flight Schedule
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_delete .

  DATA: ld_lineno TYPE i VALUE 0,
        ld_answer TYPE c.
  DATA: ls_spfli     TYPE spfli,
        lt_del_spfli TYPE STANDARD TABLE OF spfli.

* Check selected data for deletion
  DO.
*count current one
    ld_lineno += 1.
    READ LINE ld_lineno FIELD VALUE gd_checkbox.
*    END of list screen CHECKING
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    IF gd_checkbox = abap_true.
      READ TABLE gt_flight_sch INTO DATA(ls_flight_sch)
       WITH KEY carrid = gd_carrid
                connid = gd_connid.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_flight_sch TO ls_spfli.

        APPEND ls_spfli TO lt_del_spfli.
      ENDIF.
    ENDIF.
  ENDDO.

* Process deletion
  IF lt_del_spfli IS NOT INITIAL.
    CLEAR ld_answer.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question         = 'Do you really want to delete these data?'
        text_button_1         = 'Yes'(001)
        icon_button_1         = 'ICON_DELETE'
        text_button_2         = 'No'(002)
        icon_button_2         = 'ICON_CANCEL'
        display_cancel_button = space
      IMPORTING
        answer                = ld_answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    IF ld_answer = '1'.
      DELETE spfli FROM TABLE lt_del_spfli.

      IF sy-subrc = 0.
        MESSAGE 'Delete successfull:' TYPE 'S'.
      ENDIF.
    ENDIF.
*    Submit with dynamic program
    SUBMIT (sy-repid) WITH s_carrid IN s_carrid
                             WITH s_connid IN s_connid.
  ENDIF.

ENDFORM.
