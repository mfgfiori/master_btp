@EndUserText.label: 'Consumption-Travel Approval'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity Z_C_ATRAVEL_2114
  as projection on z_i_travel_2114
{
  key travel_id      as TravelID,
      agency_id      as AgencyID,
      @ObjectModel.text.element:['AgencyName']
      _Agency.Name   as AgencyName,      
      customer_id    as CustomerID,
      @ObjectModel.text.element:['CustomerName']
      _Customer.LastName  as CustomerName,            
      begin_date     as BeginDate,
      end_date       as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee    as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price    as TotalPrice,
      @Semantics.currencyCode: true
      currency_code  as CurrencyCode,
      description    as Description,
      overall_status as TravelStatus,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child z_c_abooking_2114,
      _Customer
}
