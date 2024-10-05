*&---------------------------------------------------------------------*
*& Report zhien_eclipse_ex4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhien_eclipse_ex4.

*----------------------------------------------------------------------*
*Declaration internal tables
*----------------------------------------------------------------------*
DATA: gt_receivers   LIKE somlreci1 OCCURS 1 WITH HEADER LINE,
            gt_obj_content LIKE solisti1 OCCURS 1 WITH HEADER LINE.

*----------------------------------------------------------------------*
*Declaration structures
*----------------------------------------------------------------------*
DATA: gs_doc_data    LIKE sodocchgi1.


PARAMETERS p_mail TYPE somlreci1-receiver.
PARAMETERS p_sub TYPE sodocchgi1-obj_descr.
PARAMETERS p_cont TYPE solisti1-line.

*----------------------------------------------------------------------*
*ASUNTO
*----------------------------------------------------------------------*
gs_doc_data-obj_langu = sy-langu.
gs_doc_data-obj_name  = 'SAPRPT'.
gs_doc_data-obj_descr = p_sub.
gs_doc_data-sensitivty = 'F'.

*----------------------------------------------------------------------*
*CUERPO DEL MENSAJE
*----------------------------------------------------------------------*
gt_obj_content-line = p_cont.
APPEND gt_obj_content.

*gt_obj_content-line = ''.
*APPEND gt_obj_content.
*
*gt_obj_content-line = 'Test : Mail from VIN1'.
*APPEND gt_obj_content.

*----------------------------------------------------------------------*
*DESTINATARIOS
*----------------------------------------------------------------------*
*A
gt_receivers-receiver = p_mail.   "Message recipient name.
gt_receivers-rec_type = 'U'.                          "Type of recipient, if U is sent to a conventional email.
gt_receivers-express = 'X'.                           "Send: In the form of an urgent document.
gt_receivers-notif_ndel = 'X'.                        "Acknowledgment of receipt.
APPEND gt_receivers.



*gt_receivers-receiver = 'nguyenhien2@gmail.com'. "Message recipient name.
*gt_receivers-rec_type = 'U'.                          "Type of recipient, if U is sent to a conventional email.
*gt_receivers-express = 'X'.                           "Send: In the form of an urgent document.
*gt_receivers-notif_ndel = 'X'.                        "Acknowledgment of receipt.
*gt_receivers-copy = 'X'.                              "With copy to next recipient
*APPEND gt_receivers.


*&----------------------------------------------------------------------------*
* EJECUTANDO: SO_NEW_DOCUMENT_SEND_API1
*&----------------------------------------------------------------------------*

CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
  EXPORTING
    document_data              = gs_doc_data    "Message Subject
    document_type              = 'RAW'
    put_in_outbox              = 'X'            "Leave a copy at the exit
    commit_work                = 'X'
  TABLES
    object_content             = gt_obj_content "Message body
    receivers                  = gt_receivers   "Recipients
  EXCEPTIONS
    too_many_receivers         = 1
    document_not_sent          = 2
    document_type_not_exist    = 3
    operation_no_authorization = 4
    parameter_error            = 5
    x_error                    = 6
    enqueue_error              = 7
    OTHERS                     = 8.

WAIT UP TO 2 SECONDS.
IF sy-subrc EQ 0.
  SUBMIT rsconn01 WITH mode = 'INT'
                  WITH output = 'X'
                  AND RETURN.
ENDIF.
