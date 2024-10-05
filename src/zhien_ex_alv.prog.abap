*&---------------------------------------------------------------------*
*& Report ZHIEN_ABAP_EX_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_ex_alv NO STANDARD PAGE HEADING.

INCLUDE zhien_ex_alvtop.
*
INCLUDE zhien_ex_alvf01.

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_vbeln-low.

PERFORM SH_VBELN.
*VBELN, ERDAT, ERNAM



START-OF-SELECTION.
SET TITLEBAR 'TITLE_TEST'.

*Main process
  PERFORM main_process.


AT USER-COMMAND.
  PERFORM Handle_Ucomm.
