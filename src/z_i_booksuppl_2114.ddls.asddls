@AbapCatalog.sqlViewName: 'ZVBOOKSUPPL_2114'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface - Booking Supplement'
define view Z_I_BOOKSUPPL_2114
  as select from ztb_booksuppl_21 as BookingSupplement
  association        to parent z_i_booking_2114 as _Booking        on  $projection.travel_id  = _Booking.travel_id
                                                                   and $projection.booking_id = _Booking.booking_id
  association [1..1] to z_i_travel_2114         as _Travel         on  $projection.travel_id = _Travel.travel_id
  association [1..1] to /DMO/I_Supplement       as _Product        on  $projection.supplement_id = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText   as _SupplementText on  $projection.supplement_id = _SupplementText.SupplementID
{
  key travel_id,
  key booking_id,
  key booking_supplement_id,
      supplement_id,
      @Semantics.amount.currencyCode: 'currency_code'
      price,
      @Semantics.currencyCode: true
      currency_code,
      _Travel.last_changed_at,
      _Booking,
      _Travel,
      _Product,
      _SupplementText
}
