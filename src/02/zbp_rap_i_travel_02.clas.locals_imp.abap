CLASS lsc_zrap_i_travel_02 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zrap_i_travel_02 IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.

    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~accepttravel RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~rejecttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel .

    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.


    METHODS earlynumbering FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering.

    DATA:
      entity        TYPE STRUCTURE FOR CREATE zrap_i_travel_02,
      travel_id_max TYPE /dmo/travel_id.

    " Ensure Travel ID is not set yet (idempotent)- must be checked when BO is draft-enabled
    LOOP AT entities INTO entity WHERE travel_id IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-travel.
    ENDLOOP.

    DATA(entities_wo_travelid) = entities.
    DELETE entities_wo_travelid WHERE travel_id IS NOT INITIAL.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '20'
            object            = 'ZRAP_00'
            quantity          = CONV #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #(  %cid = entity-%cid
                           %key = entity-%key
                           %msg = lx_number_ranges
                        ) TO reported-travel.
          APPEND VALUE #(  %cid = entity-%cid
                           %key = entity-%key
                        ) TO failed-travel.
        ENDLOOP.
        EXIT.
    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        " 1 - the returned number is in a critical range (specified under “percentage warning” in the object definition)
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>number_range_depleted
                                      severity = if_abap_behv_message=>severity-warning )
                        ) TO reported-travel.
        ENDLOOP.

      WHEN '2' OR '3'.
        " 2 - the last number of the interval was returned
        " 3 - if fewer numbers are available than requested,  the return code is 3
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                      severity = if_abap_behv_message=>severity-warning )
                        ) TO reported-travel.
          APPEND VALUE #( %cid        = entity-%cid
                          %key        = entity-%key
                          %fail-cause = if_abap_behv=>cause-conflict
                        ) TO failed-travel.
        ENDLOOP.
        EXIT.
    ENDCASE.

    " At this point ALL entities get a number!
    ASSERT number_range_returned_quantity = lines( entities_wo_travelid ).

    travel_id_max = number_range_key - number_range_returned_quantity.

    " Set Travel ID
    LOOP AT entities_wo_travelid INTO entity.
      travel_id_max += 1.
      entity-travel_id = travel_id_max .

      APPEND VALUE #( %cid  = entity-%cid
                      %key  = entity-%key
                    ) TO mapped-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.
    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF zrap_i_travel_02 IN LOCAL MODE
           ENTITY travel
              UPDATE FIELDS ( overall_status )
                 WITH VALUE #( FOR key IN keys ( %tky      = key-%tky
                                                 overall_status = 'A' ) ). " Accepted

    " Read changed data for action result
    READ ENTITIES OF zrap_i_travel_02 IN LOCAL MODE
      ENTITY travel
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky      = travel-%tky
                                              %param    = travel ) ).
  ENDMETHOD.

  METHOD copyTravel.

    DATA:
      travels       TYPE TABLE FOR CREATE zrap_i_travel_02\\Travel,
      bookings_cba  TYPE TABLE FOR CREATE zrap_i_travel_02\\Travel\_Booking,
      booksuppl_cba TYPE TABLE FOR CREATE zrap_i_travel_02\\Booking\_BookSupplement.

    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_inital_cid).
    ASSERT key_with_inital_cid IS INITIAL.

    READ ENTITIES OF zrap_i_travel_02 IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(travel_read_result).

    READ ENTITIES OF zrap_i_travel_02 IN LOCAL MODE
    ENTITY Travel BY \_Booking
    ALL FIELDS WITH CORRESPONDING #( travel_read_result )
    RESULT DATA(book_read_result).

    READ ENTITIES OF zrap_i_travel_02 IN LOCAL MODE
    ENTITY Booking BY \_BookSupplement
    ALL FIELDS WITH CORRESPONDING #( book_read_result )
    RESULT DATA(booksuppl_read_result).

    LOOP AT keys INTO DATA(key).
      READ TABLE travel_read_result ASSIGNING FIELD-SYMBOL(<travel>) WITH KEY id COMPONENTS %tky = key-%tky.
      IF sy-subrc EQ 0.
        "Fill travel container for creating new travel instance
        APPEND VALUE #( %cid = key-%cid
        %data = CORRESPONDING #( <travel> EXCEPT travel_id ) )
        TO travels ASSIGNING FIELD-SYMBOL(<new_travel>).

        "Fill %cid_ref of travel as instance identifier for cba booking
        APPEND VALUE #( %cid_ref = key-%cid )
        TO bookings_cba ASSIGNING FIELD-SYMBOL(<bookings_cba>).

        <new_travel>-begin_date = cl_abap_context_info=>get_system_date( ).
        <new_travel>-end_date = cl_abap_context_info=>get_system_date( ) + 30.
        <new_travel>-overall_status = 'O'. "Set to open to allow an editable instance

        LOOP AT book_read_result ASSIGNING FIELD-SYMBOL(<booking>) USING KEY entity WHERE travel_id EQ <travel>-travel_id.
          "Fill booking container for creating booking with cba
          APPEND VALUE #( %cid = key-%cid && <booking>-booking_id
          %data = CORRESPONDING #( book_read_result[ KEY entity %tky = <booking>-%tky ] EXCEPT travel_id ) )
          TO <bookings_cba>-%target ASSIGNING FIELD-SYMBOL(<new_booking>).

          "Fill %cid_ref of booking as instance identifier for cba booksuppl
          APPEND VALUE #( %cid_ref = key-%cid && <booking>-booking_id )
          TO booksuppl_cba ASSIGNING FIELD-SYMBOL(<booksuppl_cba>).

          <new_booking>-booking_status = 'N'.

          LOOP AT booksuppl_read_result ASSIGNING FIELD-SYMBOL(<booksuppl>) USING KEY entity WHERE travel_id EQ <travel>-travel_id
          AND booking_id EQ <booking>-booking_id.
            "Fill booksuppl container for creating supplement with cba
            APPEND VALUE #( %cid = key-%cid && <booking>-booking_id && <booksuppl>-booking_supplement_id
            %data = CORRESPONDING #( <booksuppl> EXCEPT travel_id booking_id ) )
            TO <booksuppl_cba>-%target.
          ENDLOOP.
        ENDLOOP.

      ELSE.
        APPEND CORRESPONDING #( key MAPPING %fail = DEFAULT VALUE #( cause = if_abap_behv=>cause-not_found ) ) TO failed-travel.
      ENDIF.
    ENDLOOP.

    "create new BO instance
    MODIFY ENTITIES OF zrap_i_travel_02 IN LOCAL MODE
      ENTITY travel
        CREATE FIELDS ( agency_id customer_id begin_date end_date booking_fee total_price currency_code overall_status description )
          WITH travels
        CREATE BY \_Booking FIELDS ( booking_id booking_date customer_id carrier_id connection_id flight_date flight_price currency_code booking_status )
          WITH bookings_cba
      ENTITY booking
        CREATE BY \_BookSupplement FIELDS ( booking_supplement_id supplement_id price currency_code )
          WITH booksuppl_cba
      MAPPED DATA(mapped_create).

    mapped-travel   =  mapped_create-travel .

  ENDMETHOD.

  METHOD ReCalcTotalPrice.
  ENDMETHOD.

  METHOD rejectTravel.
    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF zrap_i_travel_02 IN LOCAL MODE
           ENTITY travel
              UPDATE FIELDS ( overall_status )
                 WITH VALUE #( FOR key IN keys ( %tky      = key-%tky
                                                 overall_status = 'X' ) ). " Accepted

    " Read changed data for action result
    READ ENTITIES OF zrap_i_travel_02 IN LOCAL MODE
      ENTITY travel
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky      = travel-%tky
                                              %param    = travel ) ).
  ENDMETHOD.

ENDCLASS.
