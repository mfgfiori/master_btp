CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSupplimnPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotalSupplimnPrice.

ENDCLASS.

CLASS lhc_Supplement IMPLEMENTATION.

  METHOD calculateTotalSupplimnPrice.

    IF NOT keys IS INITIAL.
      zcl_aux_travel_det_2114=>calculate_price( it_travel_id = VALUE #(  FOR GROUPS <booking_suppl> OF booking_key IN keys
                                                                         GROUP BY booking_key-travel_id WITHOUT MEMBERS ( <booking_suppl> ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_supplement DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
    CONSTANTS: c_create TYPE string VALUE 'C',
               C_updATE TYPE string VALUE 'U',
               C_delETE TYPE string VALUE 'D'.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_supplement IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_supplements TYPE STANDARD TABLE OF ztb_booksuppl_21,
          lv_op_type     TYPE zde_flag_2114,
          lv_updated     TYPE zde_flag_2114.
    " Provide table of instance data of all instances that have been created during current transaction
    " Use %CONTROL to get information on what entity fields have been set when creating the instance
    IF NOT create-supplement IS INITIAL.
      lt_supplements = CORRESPONDING #( create-supplement ).
      lv_op_type = c_create.
    ENDIF.

    " Provide table of instance data of all instances that have been updated during current transaction
    " Use %CONTROL to get information on what entity fields have been updated
    IF NOT update-supplement IS INITIAL.
      lt_supplements = CORRESPONDING #( update-supplement ).

      IF lt_supplements IS NOT INITIAL.

        " Read all field values from database
        SELECT * FROM ztb_booksuppl_21 FOR ALL ENTRIES IN @lt_supplements
                 WHERE travel_id  = @lt_supplements-travel_id
                   and booking_id = @lt_supplements-booking_id
                   and booking_supplement_id = @lt_supplements-booking_supplement_id
                 INTO TABLE @lt_supplements .

        " Take over field values that have been changed during the transaction
        LOOP AT update-supplement ASSIGNING FIELD-SYMBOL(<fs_booksuppl>).

          ASSIGN lt_supplements[ travel_id  = <fs_booksuppl>-travel_id
                                booking_id = <fs_booksuppl>-booking_id
                     booking_supplement_id = <fs_booksuppl>-booking_supplement_id
                              ] TO FIELD-SYMBOL(<fs_booksuppl_db>).

          IF <fs_booksuppl>-%control-supplement_id = if_abap_behv=>mk-on.
            <fs_booksuppl_db>-supplement_id = <fs_booksuppl>-supplement_id.
          ENDIF.

          IF <fs_booksuppl>-%control-price = if_abap_behv=>mk-on.
            <fs_booksuppl_db>-price = <fs_booksuppl>-price.
          ENDIF.

          IF <fs_booksuppl>-%control-currency_code = if_abap_behv=>mk-on.
            <fs_booksuppl_db>-currency_code = <fs_booksuppl>-currency_code.
          ENDIF.

        ENDLOOP.

      ENDIF.

      lv_op_type = c_update.
    ENDIF.

    " Provide table with keys of all instances that have been deleted during current transaction
    " NOTE: There is no information on fields when deleting instances
    IF NOT delete-supplement IS INITIAL.
      lt_supplements = CORRESPONDING #( delete-supplement ).
      lv_op_type = c_delete.
    ENDIF.

    IF NOT lt_supplements IS INITIAL.

      CALL FUNCTION 'Z_FM_SUPPL_2114'
        EXPORTING
          it_supplements = lt_supplements
          iv_op_type     = lv_op_type
        IMPORTING
          ev_updated     = lv_updated.

      IF lv_updated = abap_true.
*            reported-supplement
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
