FUNCTION zhien_bai2_daochuoi.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_STRING) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(E_STRING) TYPE  STRING
*"  EXCEPTIONS
*"      CHECK_STR_LEN_GREATER_1
*"----------------------------------------------------------------------

  DATA v_len TYPE i .
  v_len = strlen( i_string ).

  IF v_len > 1 .
    WHILE v_len >= 0.
      v_len -= 1.

      CHECK v_len >= 0.
      e_string = e_string && i_string+v_len(1).
    ENDWHILE.
  ELSE.
    RAISE check_str_len_greater_1.

  ENDIF.




ENDFUNCTION.
