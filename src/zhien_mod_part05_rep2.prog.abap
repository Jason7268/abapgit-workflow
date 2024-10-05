*&---------------------------------------------------------------------*
*& Report ZHIEN_MOD_PART05_REP2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_MOD_PART05_REP2.

DATA: GD_TEST_OUT TYPE CHAR40.

*PERFORM WRITE_DATA
*        IN PROGRAM ZHIEN_MOD_PART05_REP1
*        USING 'Input Text 1' 'Input Text 2'
*        CHANGING GD_TEST_OUT.

PERFORM WRITE_DATA(ZHIEN_MOD_PART05_REP1)
        USING 'Input Text 1' 'Input Text 2'
        CHANGING GD_TEST_OUT.

WRITE: / 'Test Ext Charging: ', GD_TEST_OUT.
