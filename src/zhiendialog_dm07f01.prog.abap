*&---------------------------------------------------------------------*
*& Include          ZHIENDIALOG_DM07F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_SPFLI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_spfli .
  SELECT CARRID
         CONNID
         COUNTRYFR
         COUNTRYTO
         DISTANCE
         DISTID
    FROM SPFLI
    INTO CORRESPONDING FIELDS OF TABLE GT_DETAIL
    WHERE CARRID = GS_HEADER-CARRID.

    IF SY-SUBRC <> 0.
      MESSAGE 'Data not fount ' TYPE 'E'.
    ELSE.
      LOOP AT GT_DETAIL INTO GS_DETAIL.
        PERFORM get_country_name USING GS_DETAIL-countryfr
                                 CHANGING GS_DETAIL-countryfr_nm.
        PERFORM get_country_name USING GS_DETAIL-countryTO
                                 CHANGING GS_DETAIL-countryTO_nm.
        MODIFY GT_DETAIL FROM GS_DETAIL.
      ENDLOOP.
    ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CARRNAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_carrname .
  CLEAR: GS_HEADER-CARRNAME.

  SELECT SINGLE CARRNAME
    FROM SCARR
    INTO GS_HEADER-CARRNAME
    WHERE CARRID = GS_HEADER-CARRID.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_country_name
*&---------------------------------------------------------------------*
*& Get country name
*&---------------------------------------------------------------------*
*&      --> U_COUNTRY_CODE
*&      <-- C_COUNTRY_NAME
*&---------------------------------------------------------------------*
FORM get_country_name  USING    u_country_code TYPE t005t-land1
                       CHANGING c_country_name TYPE t005t-landx.
  SELECT SINGLE landx
    FROM  t005t
    INTO c_country_name
    WHERE land1 = u_country_code
      AND spras = sy-langu.
ENDFORM.
