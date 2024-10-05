interface ZIF_HIEN_DEMO
  public .


  methods GET_DATA .
  methods SUM_TOTAL
    importing
      !IV_A type CHAR1
      !IV_B type CHAR1 .
  methods GIAIPTB2
    exporting
      !EV_X1 type P
      !EV_X2 type P
    returning
      value(EV_RESULT) type STRING .
endinterface.
