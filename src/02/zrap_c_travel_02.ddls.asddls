@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Projection View'
@Metadata.ignorePropagatedAnnotations: true 

@Metadata.allowExtensions: true
define root view entity ZRAP_C_TRAVEL_02
  provider contract transactional_query
  as projection on ZRAP_I_TRAVEL_02
{
  key     travel_id      as TravelId,
          agency_id      as AgencyId,
          customer_id    as CustomerId,
          begin_date     as BeginDate,
          end_date       as EndDate,
          @Semantics.amount.currencyCode: 'Currencycode'
          booking_fee    as BookingFee,
          @Semantics.amount.currencyCode: 'Currencycode'
          total_price    as TotalPrice,
          currency_code  as CurrencyCode,
          overall_status as OverallStatus,
          description    as Description,

          /*additional*/

  virtual TravelTitle : abap.char(40),

          /* Associations */
          _Agency,
          _Booking,
          _Currency,
          _Customer,
          _OverallStatus

}
