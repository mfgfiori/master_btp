CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR booking RESULT result.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.
    IF NOT keys IS INITIAL.
      zcl_aux_travel_det_2114=>calculate_price( it_travel_id = VALUE #(  FOR GROUPS <booking> OF booking_key IN keys
                                                                         GROUP BY booking_key-travel_id WITHOUT MEMBERS ( <booking> ) ) ).
    ENDIF.
*    reported-travel
  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel_2114\\Booking
           FIELDS ( booking_status )
             WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
           RESULT DATA(lt_booking).
    LOOP AT lt_booking INTO DATA(ls_booking).
      CASE ls_booking-booking_status.
        WHEN 'N'. "New

        WHEN 'X'. "Canceled

        WHEN 'B'. "Booked

        WHEN OTHERS.
          APPEND VALUE #( %key      = ls_booking-%key ) TO failed-booking.

          APPEND VALUE #( %key    = ls_booking-%key
                          %msg    = new_message( id = 'Z_MCL_TRAVEL_2114'
                                                number = '007'
                                                v1 =  ls_booking-booking_status
                                                v2 =  |{ ls_booking-booking_id ALPHA = OUT }|
                                                severity = if_abap_behv_message=>severity-error )
                          %element-booking_status = if_abap_behv=>mk-on ) TO reported-booking.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
  METHOD get_instance_features.

    READ ENTITIES OF z_i_travel_2114
              ENTITY Booking
              FIELDS ( booking_id booking_date customer_id booking_status )
                WITH VALUE #( FOR key_row IN keys ( %key  = key_row-%key ) )
              RESULT DATA(lt_booking_result).

    result = VALUE #( FOR booking_row IN lt_booking_result (
                          %key = booking_row-%key
                          %assoc-_BookingSupplement = if_abap_behv=>fc-o-enabled ) ).

  ENDMETHOD.
ENDCLASS.
