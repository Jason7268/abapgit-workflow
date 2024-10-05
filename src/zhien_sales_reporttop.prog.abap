*&---------------------------------------------------------------------*
*& Include          ZHIEN_SALES_REPORTTOP
*&---------------------------------------------------------------------*
TABLES: zhien_vbak,zhien_vbaP.
*Block 1: Create SO Options
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS : s_vbeln FOR zhien_vbak-zzvbeln,
                   s_cust FOR zhien_vbak-zzCUSTOMER,
                   s_werks FOR zhien_vbap-zzwerks.
  SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
    PARAMETERS: r_loccu RADIOBUTTON GROUP rb1 USER-COMMAND rbcm DEFAULT 'X',
                r_doccu RADIOBUTTON GROUP rb1.
  SELECTION-SCREEN END OF BLOCK b02.
SELECTION-SCREEN END OF BLOCK b01.


*Final output table
TYPES: BEGIN OF ty_VBAK,
         zzcustomer TYPE  zhien_kna1-zzcustomer,
         ZZNAME1    TYPE  zhien_kna1-ZZNAME1,
         zzvbeln    TYPE  zhien_vbap-zzvbeln,
         zzvbelp    TYPE  zhien_vbap-zzvbelp,
         zzmatnr    TYPE  zhien_vbap-zzmatnr,
         zzmenge    TYPE  zhien_vbap-zzmenge,
         zzmeins    TYPE  zhien_vbap-zzmeins,
         zznetpr    TYPE  zhien_vbap-zznetpr,
         zznetprwt  TYPE  zhien_vbap-zznetpr,
         zzwaers    TYPE  zhien_vbak-zzwaers,
         t_color TYPE lvc_t_scol,
       END OF ty_VBAK,

*structure for customer
       BEGIN OF ty_customer,
         zzcustomer TYPE zhien_kna1-zzcustomer,
         ZZNAME1    TYPE zhien_kna1-ZZNAME1,
       END OF ty_customer.


CLASS lcl_report DEFINITION.
*
  PUBLIC SECTION.
* *
*Final output table
    TYPES: ty_t_vbak TYPE STANDARD TABLE OF ty_VBAK.
    DATA: t_vbak TYPE STANDARD TABLE OF ty_VBAK.

    TYPES: ty_t_customer TYPE STANDARD TABLE OF ty_customer.
    DATA: t_customer TYPE STANDARD TABLE OF ty_customer.
* ALV reference
    DATA: o_alv TYPE REF TO cl_salv_table.

    METHODS:
* data selection
      get_data,
      get_customer,
* Generating output
      generate_output,
*      Show smartform
      show_form.
*$*$*.....CODE_ADD_1 - Begin..................................1..*$*$*
* *
*    In this section we will define the private methods which can
* be implemented to set the properties of the ALV and can be
* called in the
  PRIVATE SECTION.
* Set pf status
    METHODS: set_pf_status CHANGING
                             co_alv TYPE REF TO cl_salv_table.
* Set layout
    METHODS:
      set_layout
        CHANGING
          co_alv TYPE REF TO cl_salv_table.
* Set Top of page
    METHODS:
      set_top_of_page
        CHANGING
          co_alv TYPE REF TO cl_salv_table.
* *
*    SET END of page
    METHODS:
      set_end_of_page
        CHANGING
          co_alv TYPE REF TO cl_salv_table.
* Set display setting
    METHODS:
      set_display_setting
        CHANGING
          co_alv TYPE REF TO cl_salv_table.
* Set the various column properties
    METHODS:
      set_columns
        CHANGING
          co_alv TYPE REF TO cl_salv_table.
    METHODS:
      set_hotspot_vbeln
        CHANGING
          co_alv    TYPE REF TO cl_salv_table
          co_report TYPE REF TO lcl_report.
* Event Handler for HOTSPOT event
    METHODS:
      on_link_click
        FOR EVENT link_click OF cl_salv_events_table
        IMPORTING
          row
          column .
* Set colors : Rows, column, cells...
    METHODS:
      set_colors
        CHANGING
          co_alv  TYPE REF TO cl_salv_table
          ct_vbak TYPE ty_t_vbak.
*    * Sort & subtotal.
    METHODS:
      set_sorts
        CHANGING
          co_alv TYPE REF TO cl_salv_table.
* Set total
    METHODS:
      set_aggregations
        CHANGING
          co_alv TYPE REF TO cl_salv_table.
* Set filter
    METHODS:
      set_filters
        CHANGING
          co_alv TYPE REF TO cl_salv_table.
*$*$*.....CODE_ADD_1 - End....................................1..*$*$*
*
ENDCLASS. "lcl_report DEFINITION
