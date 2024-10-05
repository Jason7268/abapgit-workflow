*&---------------------------------------------------------------------*
*& Report ZHIEN_MESS_DEMO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_mess_demo.

DATA: gdf_msg_typ TYPE syst_msgty.
PARAMETERS:
  rb_smsg  RADIOBUTTON GROUP grp1 DEFAULT 'X',
  rb_wMsg  RADIOBUTTON GROUP grp1,
  rb_emsg  RADIOBUTTON GROUP grp1,
  rb_imsg  RADIOBUTTON GROUP grp1,
  rb_amsg  RADIOBUTTON GROUP grp1,
  rb_xmsg  RADIOBUTTON GROUP grp1.

SELECTION-SCREEN SKIP 2.
PARAMETERS: rb_sel  RADIOBUTTON GROUP grp2 DEFAULT 'X'.
PARAMETERS: rb_rep  RADIOBUTTON GROUP grp2.
PARAMETERS: rb_idms RADIOBUTTON GROUP grp2.

AT SELECTION-SCREEN.
  CASE abap_on.
    WHEN rb_smsg.
      gdf_msg_typ = 'S'.
    WHEN rb_wmsg.
      gdf_msg_typ = 'W'.
    WHEN rb_emsg.
      gdf_msg_typ = 'E'.
    WHEN rb_imsg.
      gdf_msg_typ = 'I'.
    WHEN rb_amsg.
      gdf_msg_typ = 'A'.
    WHEN rb_xmsg.
      gdf_msg_typ = 'X'.
    WHEN OTHERS.

  ENDCASE.

  IF rb_sel = abap_on.
    MESSAGE 'This is the message content!' TYPE gdf_msg_typ DISPLAY LIKE 'E' .
  ENDIF.
  WRITE 'This is the REPORT PAGE'.
  IF rb_rep = abap_on.
    MESSAGE 'This is the message content!' TYPE gdf_msg_typ.
  ELSE.
  ENDIF.

  IF rb_idms = ABAP_ON.
    MESSAGE ID 'ZHIEN_MSG' TYPE gdf_msg_typ NUMBER 002 WITH SY-UNAME.
  ENDIF.
