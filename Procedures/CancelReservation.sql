IF OBJECT_ID ('CancelConfReservation') is not null
DROP PROC CancelConfReservation;
GO


CREATE PROCEDURE CancelConfReservation (
	@ConfDayReservationID int,
	@ClientID int
)

AS BEGIN

	BEGIN TRY 
		BEGIN TRANSACTION 

					IF @ConfDayReservationID is null
					THROW 2500, 'ConfDayReservationID cant be null!', 1

