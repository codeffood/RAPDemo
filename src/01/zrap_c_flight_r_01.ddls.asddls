@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
 
define view entity ZRAP_C_Flight_R_01 as select from ZRAP_I_Flight_R_01
{
  key AirlineID,
  key ConnectionID,
  key FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      PlaneType,
      MaximumSeats,
      OccupiedSeats,
      OccupiedSeats as OccupiedSeatsForChart
      
   

}
