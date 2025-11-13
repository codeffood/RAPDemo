*&---------------------------------------------------------------------*
*& Report zr_populate_demo_data
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_populate_demo_data.


DELETE FROM zrap_travel_02.
DELETE FROM zrap_booking_02.
DELETE FROM zrap_bookspl_02.

INSERT zrap_travel_02 FROM (
  SELECT *
    FROM /dmo/travel_m

).

INSERT zrap_booking_02 FROM (
  SELECT *
    FROM /dmo/booking_m

).

INSERT zrap_bookspl_02 FROM (
  SELECT *
    FROM /dmo/booksuppl_m

).

COMMIT WORK.
