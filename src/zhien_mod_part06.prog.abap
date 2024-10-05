*&---------------------------------------------------------------------*
*& Report ZHIEN_MOD_PART06
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHIEN_MOD_PART06.

*CREATE DATA FOR STORE OUPUT STRING
DATA: GD_AMTIWORD TYPE SPELL.

*-- Create 2 screen field:
* 1.Amount
* 2. Language
PARAMETERS: P_AMT   TYPE P LENGTH 10 DECIMALS 2.
PARAMETERS: P_LANGU TYPE SY-LANGU DEFAULT 'EN'.

*EXCUTE > Call FM: SPELL_AMOUNT to get Amount in Words
* Write out Amount in Words

START-OF-SELECTION.

  CALL FUNCTION 'SPELL_AMOUNT'
   EXPORTING
     AMOUNT          = P_AMT
     CURRENCY        = 'USD'
*     FILLER          = ' '
     LANGUAGE        = P_LANGU
   IMPORTING
     IN_WORDS        = GD_AMTIWORD
   EXCEPTIONS
     NOT_FOUND       = 1
     TOO_LARGE       = 2
     OTHERS          = 3
            .
  IF SY-SUBRC <> 0.
    WRITE: / 'ERROR: ', SY-SUBRC.
  ENDIF.
   WRITE: / 'Number in words: ', GD_AMTIWORD-WORD, 'POINT', GD_AMTIWORD-DECWORD.
