CLASS ycl_sflight_report_b_ao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

PUBLIC SECTION.
  METHODS: constructor
             IMPORTING
               iv_fldate   TYPE s_date
               iv_bookid   TYPE s_book_id
               iv_custname TYPE s_custname
               iv_custtype TYPE s_custtype,

           run_report.
PROTECTED SECTION.

PRIVATE SECTION.
  TYPES: BEGIN OF st_data,
           fldate   TYPE s_date,
           carrid   TYPE s_carr_id,
           connid   TYPE s_conn_id,
           bookid   TYPE s_book_id,
           custtype TYPE s_custtype,
           passname TYPE s_passname,
           street   TYPE s_street,
           city     TYPE city,
           region   TYPE s_region,
           postcode TYPE postcode,
           country  TYPE s_country,
           email    TYPE email,
         END OF st_data,

         BEGIN OF st_display,
           fldate      TYPE s_date,
           carrid      TYPE s_carr_id,
           custttype   TYPE s_custtype,
           passname    TYPE s_passname,
           passaddress TYPE string,
           email       TYPE s_email,
           booked      TYPE abap_bool,
           connid      TYPE s_conn_id,
           bookid      TYPE s_book_id,
         END OF st_display,

         BEGIN OF st_insert,
           carrid      TYPE s_carr_id,
           connid      TYPE s_conn_id,
           fldate      TYPE s_date,
           bookid      TYPE s_book_id,
           custttype   TYPE s_custtype,
           passname    TYPE s_passname,
           passaddress TYPE string,
           email       TYPE s_email,
         END OF st_insert,

         tt_data    TYPE STANDARD TABLE OF st_data,
         tt_display TYPE STANDARD TABLE OF st_display.

  DATA: gv_fldate   TYPE s_date,
        gv_bookid   TYPE s_book_id,
        gv_custname TYPE s_custname,
        gv_custtype TYPE s_custtype,
        go_alv      TYPE REF TO cl_salv_table,
        gt_display  TYPE tt_display.

  METHODS: add_three-years
             CHANGING
               cv_date TYPE s_date,

           book_selected,

           configure_columns
             IMPORTING
               io_columns TYPE REF TO cl_salv_columns_table,

           configure_display,

           convert_data_to_display
             IMPORTING
               it_data TYPE tt_data
             CHANGING
               ct_display TYPE tt_display,

           convert_row
             IMPORTING
               is_data TYPE st_data
             RETURNING VALUE(rs_display) TYPE st_display,

           get_data
             EXPORTING
               et_data TYPE tt_data,

           get_display_names,

           get_name
             IMPORTING
               is_display TYPE st_display
             RETURNING VALUE(rv_passname) TYPE s_passname,

           handle_toolbar_click FOR EVENT added_function OF cl_salv_events_table
             IMPORTING
               e_salv_function,

           insert_to_db_table
             IMPORTING
               is_display TYPE st_display.
ENDCLASS.



CLASS ycl_sflight_report_b_ao IMPLEMENTATION.
  METHOD constructor.
    gv_fldate   = iv_fldate.
    gv_bookid   = iv_bookid.
    gv_custname = iv_custname.
    gv_custtype = iv_custtype.

    TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = go_alv
                              CHANGING  t_table      = gt_display ).
    CATCH cx_salv_msg.
      MESSAGE e004(yclsflight_msg_ao).
    ENDTRY.
  ENDMETHOD.

  METHOD run_report.
    DATA: lt_data TYPE tt_data.

    get_data( IMPORTING et_data = lt_data ).
    convert_data_to_display( EXPORTING it_data    = lt_data
                             CHANGING  ct_display = gt_display ).
    configure_display( ).
    go_alv->set_screen_status( report = 'Y_SFLIGHT_AO'
                               status = 'YGUISTATUS' ).
    SET HANDLER handle_toolbar_click FOR go_alv->get_event( ).
    go_alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).
    go_alv->display( ).
  ENDMETHOD.

  METHOD add_three_years.
    DATA(lv_year) = cv_date+0(4).
    lv_year = lv_year + 3.
    cv_date+0(4) = lv_year.
  ENDMETHOD.

  METHOD book_selected.
    DATA(lt_selected) = go_alv->get_selections( )->get_selected_rows( ).

    LOOP AT lt_selected INTO DATA(lv_row).
      READ TABLE gt_display INDEX lv_row ASSIGNING FIELD-SYMBOL( <fs_display> ).
      IF sy-subrc = 0.
        <fs_display>-booked = true.
        insert_to_db_table( <fs_display> ).
      ELSE.
        MESSAGE e003(yclsflight_msg_ao).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD configure_columns.
    TRY.
      DATA(lo_column) = io_columns->get_column( 'PASSADDRESS' ).
      lo_column->set_short_text( 'Pass Addr' ).
      lo_column->set_medium_text( 'Pass Address' ).
      lo_column->set_long_text( 'Passenger Address' ).
      lo_column = io_columns->get_column( 'BOOKED' ).
      lo_column->set_short_text( 'Booked' ).
      lo_column->set_medium_text( 'Booked' ).
      lo_column->set_long_text( 'Booked' ).
      lo_column = io_columns->get_column( 'BOOKID' ).
      lo_column->set_visible( abap_false ).
      lo_column = io_columns->get_column( 'CONNID' ).
      lo_column->set_visible( abap_false ).
    CATCH cx_salv_not_found.
      MESSAGE e005(yclsflight_msg_ao).
    ENDTRY.
  ENDMETHOD.

  METHOD configure_display.
    DATA(lo_columns) = go_alv->get_columns( ).
    lo_columns->set_optimize( abap_true ).
    configure_columns( lo_columns ).
  ENDMETHOD.

  METHOD convert_data_to_display.
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      DATA(ls_display) = convert_row( <fs_data> ).
      APPEND ls_display TO gt_display.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_row.
    MOVE-CORRESPONDING is_data TO rs_display.
    add_three_years( CHANGING cv_date = rd_display-date ).
    rs_display-passaddress = |{ is_data-street }, { is_data-city }, { is_data-region }, | &&
                             |{ is_data-postcode }, { is_data-counrty }|.
  ENDMETHOD.

  METHOD get_data.
    SELECT
      FROM sbook INNER JOIN scustom
        ON sbook~customid = scustom~id
      FIELDS fldate, carrid, connid, bookid, sbook~custtype, passname,
             street, city, region, postcode, country, email
      WHERE ( @gv_fldate   = '00000000' OR         fldate = @gv_fldate   )
        AND ( @gv_bookid   = ''         OR         bookid = @gv_bookid   )
        AND ( @gv_custname = ''         OR       passname = @gv_custname )
        AND ( @gv_custyype = ''         OR sbook~custtype = @gv_custtype )
      INTO TABLE @et_data.
    IF sy-subrc <> 0.
      MESSAGE e001(yclsflight_msg_ao).
    ENDIF.
  ENDMETHOD.

  METHOD get_display_names.
    LOOP AT gt_display ASSIGNING FIELD-SYMBOL(<fs_display>).
      IF <fs_display>-booked = abap_true.
        <fs_display>-passname = get_name( <fs_display> ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_name.
    SELECT SINGLE
      FROM yzbookings_ao
      FIELDS passname
      WHERE @is_display-bookid = yzbookings_ao~bookid
        AND @is_display-fldate = yzbookings_ao~fldate
        AND @is_display-email  = yzbookings_ao~email
      INTO @rv_passname.
    IF sy-subrc <> 0.
      MESSAGE e006(yclsflight_msg_ao).
    ENDIF.
  ENDMETHOD.

  METHOD handle_toolbar_click.
    CASE e_salv_function.
      WHEN 'BOOK'.
        book_selected( ).
      WHEN 'CANCEL'.
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDMETHOD.

  METHOD insert_into_db_table.
    DATA: ls_insert TYPE st_insert.

    MOVE-CORRESPONDING is_display TO ls_insert.
    ls_insert-passname = 'Your Name'.

    MODIFY yzbookings_ao FROM ls_insert.
    IF sy-subrc <> 0.
      MESSAGE e002(yclsflight_msg_ao).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
