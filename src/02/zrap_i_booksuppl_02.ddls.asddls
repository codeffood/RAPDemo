@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement View - CDS data model'

define view entity ZRAP_I_BOOKSUPPL_02 
  as select from ZRAP_bookspl_02 as BookingSupplement

  association        to parent ZRAP_I_Booking_02  as _Booking     on  $projection.travel_id    = _Booking.travel_id
                                                                 and $projection.booking_id   = _Booking.booking_id

  association [1..1] to ZRAP_I_Travel_02      as _Travel         on  $projection.travel_id    = _Travel.travel_id
  association [1..1] to /DMO/I_Supplement     as _Product        on $projection.supplement_id = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on $projection.supplement_id = _SupplementText.SupplementID
{
  key travel_id,
  key booking_id,
  key booking_supplement_id,
      supplement_id,
      @Semantics.amount.currencyCode: 'currency_code'
      price,
      currency_code,
      
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at,

      /* Associations */
      _Travel, 
      _Booking,
      _Product, 
      _SupplementText    
} 
