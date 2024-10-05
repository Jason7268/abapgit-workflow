*&---------------------------------------------------------------------*
*& Report ZHIEN_GETORDER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_OOP_GETORDER.

include: ole2incl.
INCLUDE ZHIEN_OOP_GETORDERTOP.

INCLUDE ZHIEN_OOP_GETORDERF01.


INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_aufnr-low.

*SHOW search help aufnr for select option product order at event  INITIAL
PERFORM sh_aufnr.

AT SELECTION-SCREEN.
*  Input validation I
  PERFORM VALIDATE_INPUTS.


START-OF-SELECTION.

PERFORM MAIN_PROCESS USING so_aufnr[].
