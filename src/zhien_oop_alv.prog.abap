*&---------------------------------------------------------------------*
*& Report ZHIEN_ABAP_EX_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_oop_alv NO STANDARD PAGE HEADING.

INCLUDE zhien_oop_alvtop.

INCLUDE zhien_oop_alvf01.

DATA: go_alv TYPE REF TO lcl_alv_report.
INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_vbeln-low.

PERFORM SH_VBELN.
*VBELN, ERDAT, ERNAM
*

SET TITLEBAR 'TITLE_TEST'.

START-OF-SELECTION.

  CREATE OBJECT go_alv.

  go_alv->main_process( ).

END-OF-SELECTION.

  go_alv->display_data( ).

AT USER-COMMAND.
  go_alv->handle_ucomm( ).
