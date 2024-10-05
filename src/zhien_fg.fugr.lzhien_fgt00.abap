*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHIEN_LOGIN.....................................*
DATA:  BEGIN OF STATUS_ZHIEN_LOGIN                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHIEN_LOGIN                   .
CONTROLS: TCTRL_ZHIEN_LOGIN
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: ZHIEN_PRODUCT_DB................................*
DATA:  BEGIN OF STATUS_ZHIEN_PRODUCT_DB              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHIEN_PRODUCT_DB              .
CONTROLS: TCTRL_ZHIEN_PRODUCT_DB
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZHIEN_TB_STUDENT................................*
DATA:  BEGIN OF STATUS_ZHIEN_TB_STUDENT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHIEN_TB_STUDENT              .
CONTROLS: TCTRL_ZHIEN_TB_STUDENT
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZTHIEN_PO_HEAD..................................*
DATA:  BEGIN OF STATUS_ZTHIEN_PO_HEAD                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTHIEN_PO_HEAD                .
CONTROLS: TCTRL_ZTHIEN_PO_HEAD
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: ZTHIEN_PO_ITEM..................................*
DATA:  BEGIN OF STATUS_ZTHIEN_PO_ITEM                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTHIEN_PO_ITEM                .
CONTROLS: TCTRL_ZTHIEN_PO_ITEM
            TYPE TABLEVIEW USING SCREEN '0007'.
*.........table declarations:.................................*
TABLES: *ZHIEN_LOGIN                   .
TABLES: *ZHIEN_PRODUCT_DB              .
TABLES: *ZHIEN_TB_STUDENT              .
TABLES: *ZTHIEN_PO_HEAD                .
TABLES: *ZTHIEN_PO_ITEM                .
TABLES: ZHIEN_LOGIN                    .
TABLES: ZHIEN_PRODUCT_DB               .
TABLES: ZHIEN_TB_STUDENT               .
TABLES: ZTHIEN_PO_HEAD                 .
TABLES: ZTHIEN_PO_ITEM                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
