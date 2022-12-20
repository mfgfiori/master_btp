CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.

    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE zhc_master_2114 AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_master.
    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY e_number.

    CLASS-DATA mt_buffer_master TYPE tt_master.

ENDCLASS.

CLASS lhc_HCMaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR HCMaster RESULT result.

    METHODS: create FOR MODIFY IMPORTING entities FOR CREATE HCMaster,
      update FOR MODIFY IMPORTING entities FOR UPDATE HCMaster,
      delete FOR MODIFY IMPORTING keys     FOR DELETE HCMaster.

    METHODS read FOR READ
      IMPORTING keys FOR READ HCMaster RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK HCMaster.

ENDCLASS.

CLASS lhc_HCMaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    GET TIME STAMP FIELD DATA(lv_time_stamp).
    DATA(lv_username) = cl_abap_context_info=>get_user_technical_name( ).

    SELECT MAX( e_number ) FROM zhc_master_2114 INTO @DATA(lv_max_employee_number).


    LOOP AT entities INTO DATA(ls_entities).
      lv_max_employee_number = lv_max_employee_number + 1.
      ls_entities-%data-ENumber = lv_max_employee_number.

      ls_entities-%data-CreaDateTime = lv_time_stamp.
      ls_entities-%data-CreaUname = lv_username.

      INSERT VALUE #( flag = lcl_buffer=>created
                      e_number       = ls_entities-%data-ENumber
                      e_name         = ls_entities-%data-EName
                      e_department   = ls_entities-%data-EDepartment
                      status         = ls_entities-%data-Status
                      job_title      = ls_entities-%data-JobTitle
                      start_date     = ls_entities-%data-StartDate
                      end_date       = ls_entities-%data-EndDate
                      email          = ls_entities-%data-Email
                      m_number       = ls_entities-%data-MNumber
                      m_name         = ls_entities-%data-MName
                      m_department   = ls_entities-%data-MDepartment
                      crea_date_time = ls_entities-%data-CreaDateTime
                      crea_uname     = ls_entities-%data-CreaUname
                             ) INTO TABLE lcl_buffer=>mt_buffer_master.

* CORRESPONDING #( ls_entities-%data )
      IF ls_entities-%cid IS INITIAL.
        INSERT VALUE #( %cid = ls_entities-%cid
                        enumber = ls_entities-enumber ) INTO TABLE mapped-hcmaster.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD update.

    GET TIME STAMP FIELD DATA(lv_time_stamp).
    DATA(lv_username) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT entities INTO DATA(ls_entities).
      SELECT SINGLE * FROM zhc_master_2114  WHERE e_number = @ls_entities-%data-ENumber INTO @DATA(ls_data_db).

      ls_entities-%data-LchgDateTime = lv_time_stamp.
      ls_entities-%data-LchgUname = lv_username.

      INSERT VALUE #( flag = lcl_buffer=>updated
                      data = VALUE #( e_number       = ls_data_db-e_number
                                      e_name         = COND #( WHEN ls_entities-%control-EName = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-EName ELSE ls_data_db-e_name )
                                      e_department   = COND #( WHEN ls_entities-%control-EDepartment = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-EDepartment ELSE ls_data_db-e_department )
                                      status         = COND #( WHEN ls_entities-%control-Status = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-Status ELSE ls_data_db-status )
                                      job_title      = COND #( WHEN ls_entities-%control-JobTitle = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-JobTitle ELSE ls_data_db-job_title )
                                      start_date     = COND #( WHEN ls_entities-%control-StartDate = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-StartDate ELSE ls_data_db-start_date )
                                      end_date       = COND #( WHEN ls_entities-%control-EndDate = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-EndDate ELSE ls_data_db-end_date )
                                      email          = COND #( WHEN ls_entities-%control-Email = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-Email ELSE ls_data_db-email )
                                      m_number       = COND #( WHEN ls_entities-%control-MNumber = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-MNumber ELSE ls_data_db-m_number )
                                      m_name         = COND #( WHEN ls_entities-%control-MName = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-MName ELSE ls_data_db-m_name  )
                                      m_department   = COND #( WHEN ls_entities-%control-MDepartment = if_abap_behv=>mk-on
                                                               THEN ls_entities-%data-MDepartment ELSE ls_data_db-m_department )
                                      crea_date_time = ls_data_db-crea_date_time
                                      crea_uname     = ls_data_db-crea_uname
                                      Lchg_Date_Time = ls_entities-%data-LchgDateTime
                                      Lchg_Uname     = ls_entities-%data-LchgUname )

                             ) INTO TABLE lcl_buffer=>mt_buffer_master.


      IF NOT ls_entities-ENumber IS INITIAL.
        INSERT VALUE #( %cid = ls_entities-%data-ENumber
                        enumber = ls_entities-%data-enumber ) INTO TABLE mapped-hcmaster.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_keys).
      INSERT VALUE #( flag = lcl_buffer=>deleted
                      data = VALUE #(  e_number = ls_keys-ENumber ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

    ENDLOOP.

    IF NOT ls_keys-ENumber IS INITIAL.
      INSERT VALUE #( %cid = ls_keys-%key-ENumber
                      enumber = ls_keys-%key-ENumber ) INTO TABLE mapped-hcmaster.
    ENDIF.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_HC_MASTER_2114 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS: finalize REDEFINITION,
      check_before_save REDEFINITION,
      save REDEFINITION,
      cleanup REDEFINITION,
      cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_HC_MASTER_2114 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    DATA: lt_data_created TYPE STANDARD TABLE OF zhc_master_2114,
          lt_data_updated TYPE STANDARD TABLE OF zhc_master_2114,
          lt_data_deleted TYPE STANDARD TABLE OF zhc_master_2114.


    lt_data_created = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master WHERE ( flag = lcl_buffer=>created ) ( <row>-data ) ).

    IF NOT lt_data_created IS INITIAL.
      INSERT zhc_master_2114 FROM TABLE @lt_data_created.
    ENDIF.

    lt_data_updated = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master WHERE ( flag = lcl_buffer=>updated ) ( <row>-data ) ).

    IF NOT lt_data_updated IS INITIAL.
      UPDATE zhc_master_2114 FROM TABLE @lt_data_updated.
    ENDIF.

    lt_data_deleted = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master WHERE ( flag = lcl_buffer=>deleted ) ( <row>-data ) ).

    IF NOT lt_data_deleted IS INITIAL.
      DELETE zhc_master_2114 FROM TABLE @lt_data_deleted.
    ENDIF.

    CLEAR lcl_buffer=>mt_buffer_master.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
