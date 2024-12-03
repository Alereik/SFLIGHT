CLASS ycl_sflight_report_a_ao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

PUBLIC SECTION.

  INTERFACES: yif_sflight_report_a_ao.

  ALIASES: st_record  FOR yif_sflight_report_a_ao~st_record,
           tt_records FOR yif_sflight_report_a_ao~tt_records,
           run_report FOR yif_sflight_report_a_ao~run_report.

  METHODS: constructor
             IMPORTING
               iv_carrid TYPE s_carr_id
               iv_connid TYPE s_conn_id
               iv_fldate TYPE s_date
               iv_plntyp TYPE s_planetye,

           run_report.
PROTECTED SECTION.

PRIVATE SECTION.
  DATA: gv_carrid TYPE s_carr_id,
        gv_connid TYPE s_conn_id,
        gv_fldate TYPE s_date,
        gv_plntyp TYPE s_planetye.

  METHODS: get_color
             IMPORTING
               iv_percentage TYPE i,

           get_percentage
             IMPORTING
               iv_seatsocc TYPE s_seatsocc
               iv_seatsmax TYPE s_seatsmax
             RETURNING VALUE(rv_percentage) TYPE i,

           get_records
             EXPORTING
               et_records TYPE tt_records,

           write_header,

           write_record
             IMPORTING
               is_record TYPE st_record.
ENDCLASS.



CLASS ycl_sflight_report_a_ao IMPLEMENTATION.
  METHOD constructor.
    gv_carrid = iv_carrid.
    gv_connid = iv_connid.
    gv_fldate = iv_fldate.
    gv_plntyp = iv_plntyp.
  ENDMETHOD.

  METHOD run_report.
    DATA: lt_records TYPE tt_records.

    get_records( IMPORTING et_records = lt_records ).
    write_header( ).

    LOOP AT lt_records INTO DATA(ls_record).
      write_record( ls_record ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_color.
    IF iv_percentage < 75.
      FORMAT COLOR COL_NORMAL.
    ELSEIF iv_percentage >= 75 AND iv_percentage < 90.
      FORMAT COLOR COL_TOTAL.
    ELSEIF iv_percentage >= 90 AND iv_percentage < 100.
      FORMAT COLOR COL_GROUP.
    ELSE.
      FORMAT COLOR COL_NEGATIVE.
    ENDIF.
  ENDMETHOD.

  METHOD get_percentage.
    DATA: lv_seatsocc TYPE p DECIMALS 2,
          lv_seatsmax TYPE p DECIMALS 2.

    lv_seatsocc = iv_seatsocc.
    lv_seatsmax = iv_seatsmax.

    IF iv_seatsmax > 0.
      rv_percentage = ( lv_seatsocc / lv_seatsmax ) * 100.
    ELSE.
      rv_percentage = 100.
    ENDIF.
  ENDMETHOD.

  METHOD get_records.
    SELECT
      FROM sflight
      FIELDS carrid, connid, fldate, planetype, price, seatsocc, seatsmax
      WHERE ( @gv_carrid = ''         OR    carrid = @gv_carrid )
        AND ( @gv_connid = ''         OR    connid = @gv_carrid )
        AND ( @gv_fldate = '00000000' OR    fldate = @gv_fldate )
        AND ( @gv_plntyp = ''         OR planetype = @gv_plntyp )
      INTO TABLE @et_records.
    IF sy-subrc <> 0.
      MESSAGE e001(yclsflight_msg_ao).
    ENDIF.
  ENDMETHOD.

  METHOD write_header.
    WRITE:/ '|',
           'Airline', '|',
           'Connection Number', '|',
           'Flight Date', '|',
           'Plane Type', '|',
           'Airfare', '|',
           'Occupied Seats', '|',
           'Maximum Capacity', '|'.
           ULINE.
  ENDMETHOD.

  METHOD write_record.
    DATA(lv_percentage) = get_percentage( iv_seatsocc = is_record-seatsocc
                                          iv_seatsmax = is_record-seatsmax ).

    get_color( lv_percentage ).

    WRITE: /
           '|', is_record-carrid,                   11 '|',
             12 is_record-connid,                   31 '|',
             32 is_record-fldate,                   45 '|',
             46 is_record-planetype,                58 '|',
             59 is_record-price    LEFT-JUSTIFIED,  68 '|',
             69 is_record-seatsocc LEFT-JUSTIFIED,  85 '|',
             86 is_record-seatsmax LEFT-JUSTIFIED, 104 '|'.
  ENDMETHOD.
