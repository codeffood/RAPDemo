"!@testing ZRAP_I_TRAVEL_02
CLASS ltc_ZRAP_I_TRAVEL_02
DEFINITION FINAL FOR TESTING
DURATION SHORT
RISK LEVEL HARMLESS.
  PRIVATE SECTION.

    CLASS-DATA:
      environment TYPE REF TO if_cds_test_environment.

    CLASS-METHODS:
      "! In CLASS_SETUP, corresponding doubles and clone(s) for the CDS view under test and its dependencies are created.
      class_setup RAISING cx_static_check,
      "! In CLASS_TEARDOWN, Generated database entities (doubles & clones) should be deleted at the end of test class execution.
      class_teardown.

    DATA:
      act_results       TYPE STANDARD TABLE OF zrap_i_travel_02 WITH EMPTY KEY,
      lt_zrap_travel_02 TYPE STANDARD TABLE OF zrap_travel_02 WITH EMPTY KEY.

    METHODS:
      "! SETUP method creates a common start state for each test method,
      "! clear_doubles clears the test data for all the doubles used in the test method before each test method execution.
      setup RAISING cx_static_check,
      prepare_testdata_set,
      "!  In this method test data is inserted into the generated double(s) and the test is executed and
      "!  the results should be asserted with the actuals.
      aunit_for_cds_method FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltc_ZRAP_I_TRAVEL_02 IMPLEMENTATION.

  METHOD class_setup.
    environment = cl_cds_test_environment=>create( i_for_entity = 'ZRAP_I_TRAVEL_02' ).
  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD aunit_for_cds_method.
    prepare_testdata_set( ).
    SELECT * FROM zrap_i_travel_02 INTO TABLE @act_results.
    cl_abap_unit_assert=>fail( msg = 'Place your assertions here' ).
  ENDMETHOD.

  METHOD prepare_testdata_set.

    "Prepare test data for 'zrap_travel_02'
    lt_zrap_travel_02 = VALUE #(
      (
        client = '001'
        travel_id = '1'
        agency_id = '1'
        customer_id = '1'
        booking_fee = '2'
        total_price = '6'
        currency_code = 'CNY'
        description = 'TEST'
        overall_status = 'O'
      ) ).
    environment->insert_test_data( i_data =  lt_zrap_travel_02 ).

  ENDMETHOD.

ENDCLASS.
