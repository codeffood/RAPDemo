@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@ObjectModel.createEnabled: true 
define view entity ZRAP_C_BOOKING_02
  provider contract transactional_query
  as projection on ZRAP_I_BOOKING_02
{
  key travel_id       as TravelID,
  key booking_id      as BookingID,
      booking_date    as BookingDate,
      customer_id     as CustomerID,
      carrier_id      as CarrierID,
      connection_id   as ConnectionID,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      last_changed_at as LastChangedAt,

      /* Associations */
      _BookingStatus,
      _BookSupplement,
      _Carrier,
      _Connection,
      _Customer,
      _Travel
}
