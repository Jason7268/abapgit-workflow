FUNCTION ZHIEN_FM_GETPRODUCT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_PRODUCTID) TYPE  ZHIEN_DE_PRODUCTID OPTIONAL
*"     REFERENCE(I_PRODUCTNAME) TYPE  ZHIEN_DE_PRODUCTNAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(IT_PRODUCT) TYPE  ZHIEN_TT_PRODUCT
*"  TABLES
*"      T_PRODUCT
*"----------------------------------------------------------------------


SELECT PRODUCTID PRODUCTNAME YEARP FROM ZHIEN_PRODUCT_DB INTO TABLE IT_PRODUCT
          WHERE productid LIKE I_PRODUCTID
              OR productname LIKE I_PRODUCTNAME.


ENDFUNCTION.
