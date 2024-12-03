INTERFACE yif_sflight_report_b_ao
  PUBLIC.

  INTERFACES: yif_sflight_ao.

  ALIASES: run_report FOR yif_sflight_ao~run_report.

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
ENDINTERFACE.
