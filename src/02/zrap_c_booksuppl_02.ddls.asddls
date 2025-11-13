@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BooSupplement Projection'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
define view entity ZRAP_C_BOOKSUPPL_02
  provider contract transactional_query
  as projection on ZRAP_I_BOOKSUPPL_02
{
  key travel_id             as TravelId, 
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,

      /* Associations */
      _booking,
      _Product,
      _SupplementText,
      _travel
}
