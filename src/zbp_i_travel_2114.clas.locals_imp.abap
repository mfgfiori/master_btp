CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF z_i_travel_2114
    ENTITY Travel
    FIELDS ( travel_id overall_status )
    WITH VALUE #( FOR key_row IN keys ( %key  = key_row-%key ) )
    RESULT DATA(lt_travel_result).


    result = VALUE #( FOR travel_row IN lt_travel_result (
                          %key = travel_row-%key
                          %field-travel_id = if_abap_behv=>fc-f-read_only
                          %field-overall_status = if_abap_behv=>fc-f-read_only
                          %assoc-_Booking = if_abap_behv=>fc-o-enabled
                          %action-acceptTravel = COND #( WHEN travel_row-overall_status = 'A'
                                                              THEN if_abap_behv=>fc-o-disabled
                                                              ELSE if_abap_behv=>fc-o-enabled )
                          %action-rejectTravel = COND #( WHEN travel_row-overall_status = 'X'
                                                              THEN if_abap_behv=>fc-o-disabled
                                                              ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

*    CB9980002114
    DATA(lv_auth) =  COND #( WHEN cl_abap_context_info=>get_user_technical_name(  ) EQ 'CB9980002114'
                             THEN if_abap_behv=>auth-allowed
                             ELSE if_abap_behv=>auth-unauthorized ).

    LOOP  AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<fs_result>).
      <fs_result> = VALUE #( %key = <fs_keys>-%key
                            %op-%update                    = lv_auth
                            %delete                        = lv_auth
                            %action-acceptTravel           = lv_auth
                            %action-rejectTravel           = lv_auth
                            %action-createTravelByTemplate = lv_auth
                            %assoc-_Booking = lv_auth ).
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF z_i_travel_2114 IN LOCAL MODE
             ENTITY Travel
             UPDATE FIELDS ( overall_status )
             WITH VALUE #( FOR key_row IN keys ( travel_id = key_row-travel_id
                                                 overall_status = 'A') ) "Accepted
             FAILED failed
             REPORTED reported.

    READ ENTITIES OF z_i_travel_2114 IN LOCAL MODE
         ENTITY Travel
         FIELDS ( agency_id
                  customer_id
                  begin_date
                  end_date
                  booking_fee
                  total_price
                  currency_code
                  overall_status
                  description
                  created_by
                  created_at
                  last_changed_by
                  last_changed_at )
                  WITH VALUE #( FOR key_row1 IN keys ( travel_id = key_row1-travel_id ) )
                  RESULT DATA(lt_travel).
    result = VALUE #( FOR travel_row IN lt_travel ( travel_id = travel_row-travel_id
                                                    %param =  travel_row ) ).

*  Informando REPORTED es la forma de hacerle llegar al usuario el error que se ha producido
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      APPEND VALUE #( %key      = <fs_travel>-%key
                      travel_id = <fs_travel>-travel_id
                      %msg      = new_message( id = 'Z_MCL_TRAVEL_2114'
                                                number = '005'
                                                v1 =  |{ <fs_travel>-travel_id ALPHA = OUT }|
                                                severity = if_abap_behv_message=>severity-success )
                      %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD createTravelByTemplate.

*  keys y result tabla interna con la información necesaria para saber el registro seleccionado
*    keys[ 1 ]-travel_id
*    result[  1 ]-
* Estructura con acceso a cada una de las entidades que componen el travel
*    mapped
* estructura que podemos rellenar en caso de excepción o error y así propagar el error.
*    failed
* Para reportar los mensajes de error
*    reported

    READ ENTITIES OF z_i_travel_2114
    ENTITY Travel
    FIELDS ( travel_id agency_id customer_id booking_fee total_price currency_code )
    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
    RESULT DATA(lt_read_entity_travel)
    FAILED failed
    REPORTED reported.

    CHECK failed IS INITIAL.

    DATA lt_create_travel TYPE TABLE FOR CREATE z_i_travel_2114\\Travel.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    SELECT MAX( travel_id ) FROM ztb_travel_2114 INTO @DATA(lv_travel_id).

    lt_create_travel = VALUE #( FOR create_row IN lt_read_entity_travel INDEX INTO idx
                                ( travel_id     = lv_travel_id + idx
                                  agency_id     = create_row-agency_id
                                  customer_id   = create_row-customer_id
                                  begin_date    = lv_today
                                  end_date      = lv_today + 30
                                  booking_fee   = create_row-booking_fee
                                  total_price   = create_row-total_price
                                  currency_code = create_row-currency_code
                                  description   = 'Add comments'
                                  overall_status = 'O' ) ).

    MODIFY ENTITIES OF z_i_travel_2114 IN LOCAL MODE ENTITY Travel
        CREATE FIELDS ( travel_id
                        agency_id
                        customer_id
                        begin_date
                        end_date
                        booking_fee
                        total_price
                        currency_code
                        description
                        overall_status )
        WITH lt_create_travel
        MAPPED mapped
        FAILED failed
        REPORTED reported.

    result = VALUE #( FOR result_row IN lt_create_travel INDEX INTO idx
                       (  %cid_ref = keys[ idx ]-%cid_ref
                          %key     = keys[ idx ]-%key
                          %param   = CORRESPONDING #( result_row ) ) ).




  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF z_i_travel_2114 IN LOCAL MODE
          ENTITY Travel
          UPDATE FIELDS ( overall_status )
          WITH VALUE #( FOR key_row IN keys ( travel_id = key_row-travel_id
                                              overall_status = 'X') ) "Rejected
          FAILED failed
          REPORTED reported.

    READ ENTITIES OF z_i_travel_2114 IN LOCAL MODE
         ENTITY Travel
         FIELDS ( agency_id
                  customer_id
                  begin_date
                  end_date
                  booking_fee
                  total_price
                  currency_code
                  overall_status
                  description
                  created_by
                  created_at
                  last_changed_by
                  last_changed_at )
                  WITH VALUE #( FOR key_row1 IN keys ( travel_id = key_row1-travel_id ) )
                  RESULT DATA(lt_travel).
    result = VALUE #( FOR travel_row IN lt_travel ( travel_id = travel_row-travel_id
                                                    %param =  travel_row ) ).

*  Informando REPORTED es la forma de hacerle llegar al usuario el error que se ha producido
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      APPEND VALUE #( %key      = <fs_travel>-%key
                      travel_id = <fs_travel>-travel_id
                      %msg      = new_message( id = 'Z_MCL_TRAVEL_2114'
                                                number = '006'
                                                v1 =  |{ <fs_travel>-travel_id ALPHA = OUT }|
                                                severity = if_abap_behv_message=>severity-success )
                      %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF z_i_travel_2114 IN LOCAL MODE
         ENTITY Travel
         FIELDS ( customer_id )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel).

    DATA: lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = customer_id EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id FOR ALL ENTRIES IN @lt_customer
                                                              WHERE customer_id EQ @lt_customer-customer_id
                                                         INTO TABLE @DATA(lt_customer_db).
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      IF <fs_travel>-customer_id IS INITIAL
          OR NOT line_exists( lt_customer_db[ customer_id = <fs_travel>-customer_id ] ).
* Informando FAILED no se permite guardar la entidad
        APPEND VALUE #( %key    = <fs_travel>-%key
                        travel_id = <fs_travel>-travel_id ) TO failed-travel.
* E informando REPORTED es la forma de hacerle llegar al usuario el error que se ha producido
        APPEND VALUE #( %key      = <fs_travel>-%key
                        travel_id = <fs_travel>-travel_id
                        %msg      = new_message( id = 'Z_MCL_TRAVEL_2114'
                                                  number = '001'
                                                  v1 =  <fs_travel>-customer_id
                                                  severity = if_abap_behv_message=>severity-error )
                        %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITY z_i_travel_2114\\Travel
              FIELDS ( begin_date end_date )
                WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
         RESULT DATA(lt_travel).


    LOOP AT lt_travel INTO DATA(ls_travel).
      IF ls_travel-end_date LT ls_travel-begin_date.
        APPEND VALUE #( %key    = ls_travel-%key
                        travel_id = ls_travel-travel_id ) TO failed-travel.
        APPEND VALUE #( %key    = ls_travel-%key
                        travel_id = ls_travel-travel_id
                        %msg      = new_message( id = 'Z_MCL_TRAVEL_2114'
                                              number = '002'
                                              v1 =  |{ ls_travel-begin_date DATE = USER }| "ls_travel-begin_date
                                              v2 =  |{ ls_travel-end_date DATE = USER }|   "ls_travel-end_date
                                              v3 =  |{ ls_travel-travel_id ALPHA = OUT }|
                                              severity = if_abap_behv_message=>severity-error )
                        %element-begin_date = if_abap_behv=>mk-on
                        %element-end_date = if_abap_behv=>mk-on ) TO reported-travel.
      ELSEIF ls_travel-begin_date LT cl_abap_context_info=>get_system_date( ).

        DATA: gd_date(10).  "field to store output date
*       Converts SAP date from 20020901 to 01.09.2002
*       gd_date = |{ ls_travel-begin_date DATE = USER }|


        cl_abap_datfm=>conv_date_int_to_ext(
                      EXPORTING
                        im_datint = ls_travel-begin_date
                      IMPORTING
                        ex_datext = gd_date ).

        APPEND VALUE #( %key    = ls_travel-%key
                        travel_id = ls_travel-travel_id ) TO failed-travel.

        APPEND VALUE #( %key    = ls_travel-%key
                        travel_id = ls_travel-travel_id
                        %msg      = new_message( id = 'Z_MCL_TRAVEL_2114'
                                              number = '003'
                                              v1 = gd_date
                                              severity = if_abap_behv_message=>severity-error )
                        %element-begin_date = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITY z_i_travel_2114\\Travel
         FIELDS ( overall_status )
           WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
         RESULT DATA(lt_travel).
    LOOP AT lt_travel INTO DATA(ls_travel).
      CASE ls_travel-overall_status.
        WHEN 'O'. "Open

        WHEN 'X'. "Canceled

        WHEN 'A'. "Accepted

        WHEN OTHERS.
          APPEND VALUE #( %key      = ls_travel-%key
                          travel_id = ls_travel-travel_id ) TO failed-travel.
          APPEND VALUE #( %key    = ls_travel-%key
                                  travel_id = ls_travel-travel_id
                                  %msg      = new_message( id = 'Z_MCL_TRAVEL_2114'
                                                        number = '004'
                                                        v1 =  ls_travel-overall_status
                                                        v2 =  |{ ls_travel-travel_id ALPHA = OUT }|
                                                        severity = if_abap_behv_message=>severity-error )
                                  %element-overall_status = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_2114 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
    CONSTANTS: c_create TYPE string VALUE 'CREATE',
               c_update TYPE string VALUE 'UPDATE',
               c_delete TYPE string VALUE 'DELETE'.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_2114 IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_travel_log   TYPE STANDARD TABLE OF ztb_log_2114,
          lt_travel_log_u TYPE STANDARD TABLE OF ztb_log_2114.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).


    IF NOT create-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( create-travel ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log>).
        GET TIME STAMP FIELD <fs_travel_log>-created_at.
        <fs_travel_log>-changing_operation = c_create.

        READ TABLE create-travel WITH TABLE KEY entity COMPONENTS travel_id = <fs_travel_log>-travel_id
                                                        INTO DATA(ls_travel).
        IF sy-subrc EQ 0.
          IF ls_travel-%control-booking_fee EQ cl_abap_behv=>flag_changed.
            <fs_travel_log>-changed_field_name = 'booking_fee'.
            <fs_travel_log>-changed_value = ls_travel-booking_fee.
            <fs_travel_log>-user_mod = lv_user.
            TRY.
                <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
            ENDTRY.
            APPEND <fs_travel_log> TO lt_travel_log_u.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDIF.

    IF NOT update-travel IS INITIAL.

      lt_travel_log = CORRESPONDING #( update-travel ).
      LOOP AT update-travel INTO DATA(ls_update_travel).
        ASSIGN lt_travel_log[ travel_id = ls_update_travel-travel_id ] TO FIELD-SYMBOL(<fs_travel_log_bd>).
        GET TIME STAMP FIELD <fs_travel_log_bd>-created_at.
        <fs_travel_log_bd>-changing_operation = c_update.

        IF ls_update_travel-%control-customer_id EQ cl_abap_behv=>flag_changed.
          <fs_travel_log_bd>-changed_field_name = 'customer_id'.
          <fs_travel_log_bd>-changed_value = ls_update_travel-customer_id.
          <fs_travel_log_bd>-user_mod = lv_user.
          TRY.
              <fs_travel_log_bd>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
          ENDTRY.
          APPEND <fs_travel_log_bd> TO lt_travel_log_u.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF NOT delete-travel IS INITIAL.

      lt_travel_log = CORRESPONDING #( delete-travel ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log_del>).
        GET TIME STAMP FIELD <fs_travel_log_del>-created_at.
        <fs_travel_log_del>-changing_operation = c_delete.
        <fs_travel_log_del>-user_mod = lv_user.
        TRY.
            <fs_travel_log_del>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
        ENDTRY.
        APPEND <fs_travel_log_del> TO lt_travel_log_u.
      ENDLOOP.
    ENDIF.

    if lt_travel_log_u is not initial.
        insert ztb_log_2114 from table @lt_travel_log_u.
    endif.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
