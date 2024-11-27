REPORT Y_SFLIGHT_AO.

PARAMETERS: rb1 RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND rb,
            rb2 RADIOBUTTON GROUP grp1.

SELECTION-SCREEN BEGIN OF BLOCK b1.
  PARAMETERS: p_carrid TYPE s_carr_id  MODIF ID bl1,
              p_connid TYPE s_conn_id  MODIF ID bl1,
              p_fldat1 TYPE s_date     MODIF ID bl1,
              p_plntyp TYPE s_planetye MODIF ID bl1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2.
  PARAMETERS: p_fldat2 TYPE s_date     MODIF ID bl2,
              p_bookid TYPE s_book_id  MODIF ID bl2,
              p_custnm TYPE s_custname MODIF ID bl2,
              p_custyp TYPE s_custtype MODIF ID bl2.
SELECTION-SCREEN END OF BLOCK b2.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'BL1'.
      screen-active = COND #( WHEN rb1 = abap_true THEN 1 ELSE 0 ).
    ELSEIF screen-group1 = 'BL2'.
      screen-active = COND #( WHEN rb2 = abap_true THEN 1 ELSE 0 ).
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.
  DATA: lo_report_a TYPE REF TO ycl_sflight_report_a_ao,
        lo_report_b TYPE REF TO ycl_sflight_report_b_ao.

  IF rb1 = abap_true.
    lo_report_a = NEW #( iv_carrid = p_carrid
                         iv_connid = p_connid
                         iv_fldate = p_fldat1
                         iv_plntyp = p_plntyp ).
    lo_report_a->run_report( ).
  ELSIF rb2 = abap_true.
    lo_report_b = NEW #( iv_fldate   = p_fldat2
                         iv_bookid   = p_bookid
                         iv_custname = p_custnm
                         iv_custtype = p_custtyp ).
    lo_report_b->run_report( ).
  ENDIF.
