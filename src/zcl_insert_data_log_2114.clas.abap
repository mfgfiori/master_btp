CLASS zcl_insert_data_log_2114 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INSERT_DATA_LOG_2114 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_travel   TYPE TABLE OF ztb_travel_2114,
          lt_booking  TYPE TABLE OF ztb_booking_2114,
          lt_book_sup TYPE TABLE OF ztb_booksuppl_21.

*   Se seleccionan los datos de la tabla standard /dmo/travel
    SELECT travel_id,
           agency_id,
           customer_id,
           begin_date,
           end_date,
           booking_fee,
           total_price,
           currency_code,
           description,
           status        AS overall_status,
           createdby     AS created_by,
           createdat     AS created_at,
           lastchangedby AS last_changed_by,
           lastchangedat AS last_changed_at
      FROM /dmo/travel INTO CORRESPONDING FIELDS OF TABLE @lt_travel UP TO 50 ROWS.

*   Se seleccionan los datos de la tabla standard /dmo/booking
    SELECT * FROM /dmo/booking FOR ALL ENTRIES IN @lt_travel
                                            WHERE travel_id = @lt_travel-travel_id
                                             INTO CORRESPONDING FIELDS OF TABLE @lt_booking.
*   Se seleccionan los datos de la tabla standard /dmo/book_suppl
    SELECT * FROM /dmo/book_suppl FOR ALL ENTRIES IN @lt_booking
                                               WHERE travel_id = @lt_booking-travel_id
                                                 AND booking_id = @lt_booking-booking_id
                                                INTO CORRESPONDING FIELDS OF TABLE @lt_book_sup.
*   Se borra la tabla previamente
    DELETE FROM : ztb_travel_2114,
                  ztb_booking_2114,
                  ztb_booksuppl_21.

    INSERT : ztb_travel_2114 FROM TABLE @lt_travel,
             ztb_booking_2114 FROM TABLE @lt_booking,
             ztb_booksuppl_21 FROM TABLE @lt_book_sup.

    out->write( 'Done!').


  ENDMETHOD.
ENDCLASS.
