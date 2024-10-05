*&---------------------------------------------------------------------*
*& Report ZHIEN_ABAP_EX1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_ABAP_EX1.

PARAMETERS: LVA TYPE I OBLIGATORY,
            LVB TYPE I OBLIGATORY,
            LVC TYPE I OBLIGATORY.

DATA: LX1 TYPE P DECIMALS 2,
      LX2 TYPE P DECIMALS 2,
      LDELTA TYPE P DECIMALS 2.

PERFORM CAL_DELTA USING LVA  LVB LVC
                  CHANGING LDELTA LX1 LX2 .


WRITE:/ 'Delta = ', LDELTA,
        'LX1 = ', LX1,
        'LX2 = ', LX2.
*&---------------------------------------------------------------------*
*& Form CAL_DELTA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LVA
*&      --> LVB
*&      --> LVC
*&      --> LDELTA
*&      <-- LX1
*&      <-- LX2
*&---------------------------------------------------------------------*
FORM CAL_DELTA USING  U_VA TYPE I
                      U_VB TYPE I
                      U_VC TYPE I
             CHANGING P_DELTA TYPE P
                      P_X1 TYPE P
                      P_X2 TYPE P.

      P_DELTA = ( U_VB * U_VB ) - 4 * ( U_VA * U_VC ).

      IF P_DELTA < 0.
        MESSAGE 'the equation has no solution' TYPE 'S'.
      ELSEIF P_DELTA = 0.
        LX1 = LX2 = - U_VB / ( 2 * U_VA ).
      ELSE.
        LX1 = ( - U_VB + SQRT( P_DELTA ) ) / ( 2 * U_VA ).
        LX2 = ( - U_VB - SQRT( P_DELTA ) ) / ( 2 * U_VA ).
      ENDIF.
ENDFORM.
