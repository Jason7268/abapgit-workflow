interface ZIF_HIEN_SHAPE
  public .


  methods ZHIEN_CL_SQUARE
    exporting
      !EV_ACREAGE type P
      !EV_PERIMETER type P
    raising
      ZCX_CHECKINPUT_GT_0 .
  methods ZHIEN_RECTANGLE
    exporting
      !EV_ACREAGE type P
      !EV_PERIMETER type P .
  methods ZHIEN_CIRCLE
    exporting
      !EV_ACREAGE type P
      !EV_PERIMETER type P .
endinterface.
