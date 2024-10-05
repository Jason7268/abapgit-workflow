FUNCTION ZHIEN_BAI3_FINONACCI.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FIBO) TYPE  I
*"  EXPORTING
*"     REFERENCE(E_SUM) TYPE  I
*"----------------------------------------------------------------------


DATA: VF1 TYPE I VALUE 1,
      VF2 TYPE I VALUE 1,
      VF TYPE I.


      E_SUM = VF1 + VF2 .
DO.
  VF = VF1 + VF2.

  VF1 = VF2.
  VF2 = VF.
  E_SUM += VF2.
  IF VF = I_FIBO.
    EXIT.
  ENDIF.

ENDDO.


ENDFUNCTION.

*5
*1 1
*1 2
*2 3
*3 5
