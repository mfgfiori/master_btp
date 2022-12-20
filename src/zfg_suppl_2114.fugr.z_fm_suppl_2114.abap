FUNCTION z_fm_suppl_2114.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPLEMENTS) TYPE  ZTT_BOOKSUPPL_21
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG_2114
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ZDE_FLAG_2114
*"----------------------------------------------------------------------
  CHECK NOT it_supplements IS INITIAL.

  CASE iv_op_type.
    WHEN 'C'.
      INSERT ztb_booksuppl_21 FROM TABLE @it_supplements.
    WHEN 'U'.
      UPDATE ztb_booksuppl_21 FROM TABLE @it_supplements.
    WHEN 'D'.
      DELETE ztb_booksuppl_21 FROM TABLE @it_supplements.

  ENDCASE.
  IF sy-subrc EQ 0.
    ev_updated = abap_true.
  ENDIF.

ENDFUNCTION.
