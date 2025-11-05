@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAP_I_Flight_R_01 as select from /dmo/flight as Flight
{
  key Flight.carrier_id     as AirlineID,
  key Flight.connection_id  as ConnectionID,
  key Flight.flight_date    as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Flight.price          as Price,
      Flight.currency_code  as CurrencyCode,
      Flight.plane_type_id  as PlaneType,
      Flight.seats_max      as MaximumSeats,
      Flight.seats_occupied as OccupiedSeats
}
