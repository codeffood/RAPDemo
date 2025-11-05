@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'GENERATED Travel App'
@ObjectModel.semanticKey: [ 'TravelID' ]

@Search.searchable: true
define root view entity ZC_RAP_TRAVEL_00
  provider contract transactional_query
  as projection on ZR_RAP_TRAVEL_00
{

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key TravelID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['AgencyName']
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: 'AgencyID' }, useForValidation: true }]
      AgencyID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['CustomerName']
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer', element: 'CustomerID'  }, useForValidation: true }]
      CustomerID,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,

      @Consumption.valueHelpDefinition: [{ entity: {name: 'I_Currency', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,
      Description,

      @ObjectModel.text.element: ['OverallStatusText']
      @Consumption.valueHelpDefinition: [{ entity: {name: '/DMO/I_Overall_Status_VH', element: 'OverallStatus' }, useForValidation: true }]
      OverallStatus,
      Attachment,
      MimeType,
      FileName,
      LocalLastChangedAt,

      _Agency.Name              as AgencyName,
      _Customer.LastName        as CustomerName,
      _OverallStatus._Text.Text as OverallStatusText : localized

}
