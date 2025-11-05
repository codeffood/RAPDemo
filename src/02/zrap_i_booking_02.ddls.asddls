@AccessControl.authorizationCheck: #NOT_REQUIRED
//@Metadata.ignorePropagatedAnnotations:true
@EndUserText.label: 'Booking view - CDS data model'

define view entity ZRAP_I_BOOKING_02
  as select from zrap_booking_02 as Booking

  association        to parent ZRAP_I_TRAVEL_02   as _Travel        on  $projection.travel_id = _Travel.travel_id
  composition [0..*] of ZRAP_I_BOOKSUPPL_02       as _BookSupplement

  association [1..1] to /DMO/I_Customer          as _Customer      on  $projection.customer_id = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier           as _Carrier       on  $projection.carrier_id = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection        as _Connection    on  $projection.carrier_id    = _Connection.AirlineID
                                                                   and $projection.connection_id = _Connection.ConnectionID
  association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on  $projection.booking_status = _BookingStatus.BookingStatus

{
  key travel_id,
  key booking_id,

      booking_date,
      customer_id,
      carrier_id,
      connection_id,
      flight_date,
      @Semantics.amount.currencyCode: 'currency_code'
      flight_price,
      currency_code,
      booking_status,

      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at,

      /* Associations */
      _Travel,
      _BookSupplement,
      _Customer,
      _Carrier,
      _Connection,
      _BookingStatus

}
