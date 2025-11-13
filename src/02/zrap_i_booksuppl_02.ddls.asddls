@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement View - CDS data model'

define view entity ZRAP_I_BOOKSUPPL_02 
  as select from zrap_bookspl_02 as BookingSupplement

  association        to parent ZRAP_I_BOOKING_02  as _booking     on  $projection.travel_id    = _booking.travel_id
                                                                 and $projection.booking_id   = _booking.booking_id

  association [1..1] to ZRAP_I_TRAVEL_02      as _travel         on  $projection.travel_id    = _travel.travel_id
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
      _travel, 
      _booking,
      _Product, 
      _SupplementText    
} 
