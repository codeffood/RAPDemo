@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true

@Search.searchable: true
define view entity ZRAP_C_Connection_R_01 as select from ZRAP_I_Connection_R_01

 association [1..*] to ZRAP_C_Flight_R_01 as _Flight on  $projection.AirlineID    = _Flight.AirlineID
                                                     and $projection.ConnectionID   = _Flight.ConnectionID
                                                   
 association [0..1] to /DMO/I_Airport as _AirportFrom  on $projection.DepartureAirport     = _AirportFrom.AirportID
 association [0..1] to /DMO/I_Airport as _AirportTo    on $projection.DestinationAirport   = _AirportTo.AirportID

{
  key AirlineID,
  key ConnectionID,
  @Consumption.valueHelpDefinition: [{ entity: {name: '/DMO/I_Airport_StdVH', element: 'AirportID' }, useForValidation: true }]
  DepartureAirport,
  
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  _AirportFrom.Name                                              as DepartureAirportName,
  
  @Consumption.valueHelpDefinition: [{ entity: {name: '/DMO/I_Airport_StdVH', element: 'AirportID' }, useForValidation: true }]
  DestinationAirport,
  
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  _AirportTo.Name                                                as DestinationAirportName,
  
  DepartureTime,
  ArrivalTime,
  Distance,
  DistanceUnit,
  
  'Conenction Information' as ConnectionTitle,
  
  _Flight
}
