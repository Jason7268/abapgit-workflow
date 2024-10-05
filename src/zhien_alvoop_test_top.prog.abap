*&---------------------------------------------------------------------*
*& Include          ZHIEN_ALVOOP_TEST_TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* CLASS lcl_report DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_report DEFINITION.
*
  PUBLIC SECTION.
* *
*Final output table
    TYPES: BEGIN OF ty_vbak,
             vkorg   TYPE vkorg,
             vtweg   TYPE vtweg,
             spart   TYPE spart,
             kunnr   TYPE kunnr,
             vbeln   TYPE vbak-vbeln,
             erdat   TYPE erdat,
             auart   TYPE auart,
             netwr   TYPE netwr,
             waerk   TYPE waerk,
             t_color TYPE lvc_t_scol,
           END OF ty_vbak.
    TYPES: ty_t_vbak TYPE STANDARD TABLE OF ty_vbak.
    DATA: t_vbak TYPE STANDARD TABLE OF ty_vbak.
* ALV reference
    DATA: o_alv TYPE REF TO cl_salv_table.
    METHODS:
* data selection
      get_data,
* Generating output
      generate_output.
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
