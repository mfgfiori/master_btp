@EndUserText.label: 'Consumption-Booking Supplement'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity z_c_booksuppl_2114
  as projection on Z_I_BOOKSUPPL_2114
{

  key travel_id             as TravelID,
  key booking_id            as BookingID,
  key booking_supplement_id as BookingSupplementID,
      supplement_id,         
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      @Semantics.currencyCode: true
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.lastChangedAt: true
      _Travel.last_changed_at as LastChangedAt,
      /* Associations */
       _Travel : redirected to z_c_travel_2114,
      _Booking : redirected to parent z_c_booking_2114,
      _Product,
      _SupplementText    
}
