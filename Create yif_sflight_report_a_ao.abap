INTERFACE yif_sflight_report_a_ao
  PUBLIC.

  INTERFACES: yif_sflight_ao.

  ALIASES: run_report FOR yif_sflight_ao~run_report.

  TYPES: BEGIN OF st_record,
           carrid    TYPE s_carr_id,
           connid    TYPE s_conn_id,
           fldate    TYPE s_date,
           planetype TYPE s_planetye,
           price     TYPE s_price,
           seatsocc  TYPE s_seatsocc,
           seatsmax  TYPE s_seatsmax,
         END OF st_record,

         tt_records TYPE STANDARD TABLE OF st_record.
ENDINTERFACE.
