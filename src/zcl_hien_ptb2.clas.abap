class ZCL_HIEN_PTB2 definition
  public
  create public .

public section.

  interfaces ZIF_HIEN_DEMO .

  data LV_A type P .
  data LV_B type P .
  data LV_C type P .

  methods CONSTRUCTOR
    importing
      !IV_A type P
      !IV_B type P
      !IV_C type P .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HIEN_PTB2 IMPLEMENTATION.


  method CONSTRUCTOR.
  LV_A =  IV_A .
  LV_B =  IV_B .
  LV_C =  IV_C .

  endmethod.


  method ZIF_HIEN_DEMO~GIAIPTB2.
    DATA: LDELTA TYPE P DECIMALS 2.

*    PERFORM CAL_DELTA USING LV_A  LV_B LV_C
*                  CHANGING LDELTA EV_X1 EV_X2 .

       LDELTA = ( LV_B * LV_B  ) - 4 * ( LV_A * LV_C ).

      IF LDELTA < 0.
        ev_result =  'Vô nghiem' .
      ELSEIF LDELTA = 0.
        EV_X1 = EV_X2 = - LV_A / ( 2 * LV_B ).
        ev_result = 'Nghiem kep'.
      ELSE.
        EV_X1 = ( - LV_B + SQRT( LDELTA ) ) / ( 2 * LV_A ).
        EV_X2 = ( - LV_B - SQRT( LDELTA ) ) / ( 2 * LV_A ).
        ev_result = 'Co 2 nghiem'.
      ENDIF.
  endmethod.
ENDCLASS.
