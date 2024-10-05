*&---------------------------------------------------------------------*
*& Report ZHIEN_SO_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_so_upload.

INCLUDE zhien_so_uploadtop.
INCLUDE zhien_so_uploadf01.

AT SELECTION-SCREEN.
*Input validation I
  PERFORM validate_inputs.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_psohd.
* File Open Dialog for so hd
  " call file dialog to get path file to upload
  CLEAR : p_psohd, p_psoit.
  PERFORM open_file_dialog CHANGING p_psohd.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_psoit.
* File Open Dialog for so it
  PERFORM open_file_dialog CHANGING p_psoit.


START-OF-SELECTION.

*Main processing
  PERFORM main_processing.


  AT USER-COMMAND.
  PERFORM Handle_Ucomm.
