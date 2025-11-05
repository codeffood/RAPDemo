@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAP_I_Connection_R_01 as select from /dmo/connection as Connection
 association [1..*] to ZRAP_I_Flight_R_01 as _Flight       on  $projection.AirlineID     = _Flight.AirlineID
                                                           and $projection.ConnectionID  = _Flight.ConnectionID

{
  key   Connection.carrier_id      as AirlineID,
  key   Connection.connection_id   as ConnectionID,

        Connection.airport_from_id as DepartureAirport,

        Connection.airport_to_id   as DestinationAirport,

        Connection.departure_time  as DepartureTime,
        Connection.arrival_time    as ArrivalTime,

        @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
        Connection.distance        as Distance,
        Connection.distance_unit   as DistanceUnit,
              
        _Flight
        
}
