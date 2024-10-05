*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM07PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PREPARE_DATA_TABLE OUTPUT
*&---------------------------------------------------------------------*
*& Get data from spli
*&---------------------------------------------------------------------*
MODULE prepare_data_table OUTPUT.

  IF gs_header-carrid IS NOT INITIAL.
    PERFORM get_spfli.
    PERFORM get_carrname.
  ENDIF.

  DESCRIBE TABLE GT_DETAIL LINES tc_detail_list-lines.

ENDMODULE.
