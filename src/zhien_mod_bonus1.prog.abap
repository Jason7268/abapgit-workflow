*&---------------------------------------------------------------------*
*& Report ZHIEN_MOD_BONUS1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_MOD_BONUS1.

*- 1. Create Select-options
*- 2. User TABLES

DATA: GD_DUMMY_AIRLINE TYPE SPFLI-CARRID.
SELECT-OPTIONS S_AIRLIN FOR GD_DUMMY_AIRLINE.

*- Select-options:
*-- Internal table with HEADER LINE
*-- Include 4 fields:
*-- ++ SIGN CHAR 1 (I/E)
*--** OPTION - CHAR 2 (EQ,BT,NE, GT, ...)|
*--++ LOW - some TYPE as the field after FOR|
*--++ HIGH -some TYPE as the field after FOR
*-- Purpose: Create a screen field that support complex condition
*- Create Range Toble
*- TYPE RANGE OF ...
TYPES: TY_R_AIRLINE TYPE RANGE OF SPFLI-CARRID.

*- Range Table
*-- Internal toble with HEADER LINE
*-- Include 4 fields:
** SIGN - CHAR 1 (L/E)
*-- ++ OPTION - CHAR 2 (EQ, BT,NE, GT, • ••)
*--++ LOW - data type of TYPE RANGE OF
*--++ HIGHT - data type of TYPE RANGE OF
*-- Purpose: 1. Use feature of SELECT-OPTION without create screen field
*-           2. Use for subourtine Parometer

*- How to pass data into Subroutine
*- 1. Poss data using ANY TABLE / STANDARD TABLE
*- 2. Pass data using RANGE table type
*PERFORM TEST_SUB USING S_AIRLIN[].

PERFORM TEST_SUB_2 USING S_AIRLIN[].

*&---------------------------------------------------------------------*
*& Form TEST_SUB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_AIRLIN[]
*&---------------------------------------------------------------------*
FORM TEST_SUB  USING U_R_AIRLINI TYPE ANY TABLE.
  SELECT * FROM SPFLI
          INTO TABLE @DATA(LT_SPFLI)
          WHERE CARRID IN @U_R_AIRLINI[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form TEST_SUB_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_AIRLIN[]
*&---------------------------------------------------------------------*
FORM TEST_SUB_2  USING    U_R_AIRLIN TYPE TY_R_AIRLINE.

  LOOP AT U_R_AIRLIN[] INTO DATA(LS_DATA).

  ENDLOOP.

  SELECT * FROM SPFLI
          INTO TABLE @DATA(LT_SPFLI)
          WHERE CARRID IN @U_R_AIRLIN[].
ENDFORM.
