*&---------------------------------------------------------------------*
*& Report ZHIEN_ITAB_PART07
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_ITAB_PART07.

DATA: GT_SBOOK TYPE STANDARD TABLE OF SBOOK.
DATA: GS_SBOOK TYPE SBOOK.
DATA: GD_TOTAL TYPE SBOOK-FORCURAM.

SELECT * FROM SBOOK INTO CORRESPONDING FIELDS OF TABLE @GT_SBOOK
          UP TO 20 ROWS.



LOOP AT GT_SBOOK INTO GS_SBOOK.
  AT FIRST.
    WRITE: / '****FLIGHT BOOKING REPORT LIST****'.
  ENDAT.

  AT NEW FLDATE.
    WRITE: / 'Airline ', GS_SBOOK-CARRID.
    WRITE: / 'Flight Number ', GS_SBOOK-CONNID.
    WRITE: / 'Flight Date ', GS_SBOOK-FLDATE.
    ULINE.
    WRITE: / 'Booking ID', 'Custumer ID', 'Ticket Amount'.
  ENDAT.

  WRITE: / GS_SBOOK-BOOKID,
           GS_SBOOK-CUSTOMID,
           GS_SBOOK-FORCURAM CURRENCY GS_SBOOK-FORCURKEY,
           GS_SBOOK-FORCURKEY.

  GD_TOTAL += GS_SBOOK-FORCURAM .

  AT END OF FLDATE.
    WRITE: / 'Total', GD_TOTAL.
    ULINE.
    SKIP 2.
  ENDAT.

  AT LAST.
    WRITE: / '****END OF FLIGHT BOOKING REPORT LIST****'.
  ENDAT.

ENDLOOP.
