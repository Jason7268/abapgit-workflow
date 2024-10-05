*&---------------------------------------------------------------------*
*& Include          ZHIEN_GETORDERTOP
*&---------------------------------------------------------------------*
**  Table definitions
TABLES : afpo, m_mbmps.

DATA: gd_dummy_aufnr TYPE afpo-aufnr.

TYPES: ty_r_aufnr TYPE RANGE OF afpo-aufnr.

*SELECTION-SCREEN BEGIN OF LINE.
* Declare select option for Produc order
SELECT-OPTIONS so_aufnr FOR gd_dummy_aufnr.
* SELECTION-SCREEN END OF LINE.

* Declare ORDER HEAD structure
TYPES: BEGIN OF ty_orderhead,
         aufnr TYPE afpo-aufnr,
         matnr TYPE afpo-matnr,
         psmng TYPE afpo-psmng,
         wemng TYPE afpo-wemng,
       END OF ty_orderhead,
       ty_t_orderhead TYPE STANDARD TABLE OF ty_orderhead.
*               WITH NON-UNIQUE KEY AUFNR.

* Declare ORDER ITEM structure
TYPES: BEGIN OF ty_orderitem,
         aufnr TYPE afpo-aufnr,
         vornr TYPE afvc-vornr,
         aufpl TYPE afko-aufpl,
         aplzl TYPE afvc-aplzl,
         arbid TYPE afvc-arbid,
         arbpl TYPE crhd-arbpl,
         ltxa1 TYPE afvc-ltxa1,
         bmsch TYPE afvv-bmsch,
         vgw01 TYPE afvv-vgw01,
         vgw02 TYPE afvv-vgw02,
         vgw03 TYPE afvv-vgw03,

       END OF ty_orderitem,
       ty_t_orderitem TYPE STANDARD TABLE OF ty_orderitem.
*                WITH NON-UNIQUE KEY AUFNR VORNR.

* Declare ORDER quantity structure
TYPES: BEGIN OF ty_orderquan,
         aufpl TYPE afko-aufpl,
         aplzl TYPE afvc-aplzl,
         bmsch TYPE afvv-bmsch,
         vgw01 TYPE afvv-vgw01,
         vgw02 TYPE afvv-vgw02,
         vgw03 TYPE afvv-vgw03,
       END OF ty_orderquan,
       ty_t_orderquan TYPE SORTED TABLE OF ty_orderquan
                      WITH NON-UNIQUE KEY aufpl aplzl.

* Declare work center structure
TYPES: BEGIN OF ty_workcenter,
         objid TYPE crhd-objid,
         arbpl TYPE crhd-arbpl,
       END OF ty_workcenter,
       ty_t_workcenter TYPE SORTED TABLE OF ty_workcenter
                      WITH NON-UNIQUE KEY objid.


*** Job: OLE Excel from SAP
***      with two sheets
**  Include objects

** File def.
data : filename like rlgrap-filename.
** Ole data
types: data1(1500) type c,
       ty_data     type table of data1.
data: gt_1 type ty_data with header line,
      gt_2 type ty_data with header line.
data: rec       type sy-tfill,
      deli(1)   type c,
      l_amt(18) type c,
      gv_sheet_name(20) type c.
data: l_rc type i.
data lo_column   type ole2_object.
data o_selection type ole2_object.
data h_rows      type ole2_object.
data w_cell1     type ole2_object.
data w_cell2     type ole2_object.
data h_excel     type ole2_object.
data h_mapl      type ole2_object.
data h_map       type ole2_object.
data h_zl        type ole2_object.
data h_f         type ole2_object.
data gs_interior type ole2_object.
data worksheet   type ole2_object.
data h_cell      type ole2_object.
data h_cell1     type ole2_object.
data range       type ole2_object.
data range2      type ole2_object.
data h_sheet2    type ole2_object.
data font        type ole2_object.
data flg_stop(1) type c.

constants: c_theme_col_yellow type i
                              value 3.

data: begin of hex,
        tab type x,
      end of hex.
** Field Symbols
field-symbols: <fs>.
