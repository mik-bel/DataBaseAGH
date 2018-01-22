IF OBJECT_ID ('CancelClientConfDayReservation') is not null
DROP PROC CancelClientConfDayReservation;
GO


CREATE PROCEDURE CancelClientConfDayReservation (
	@ConfDayReservationID int,
)

AS BEGIN

	SET NOCOUNT ON

	BEGIN TRY

		BEGIN TRANSACTION

				IF @ConfDayReservationID is null
				THROW 2500, 'ConfDayReservationID cant be null!', 1

				UPDATE ConfDayReservations
					SET Cancelled = 1
				WHERE ConfDayReservationID = @ConfDayReservationID

				--tutaj wszystkie rezerwacje na warszaty w danym dniu zostana anulowane
				--a na dodatek usuniete wszystkie rejestracje na warsztaty w danym dniu

				EXEC CancelClientWorkshopReservations @ConfDayReservationID;

				DELETE FROM ConfDayRegistrations
				WHERE ConfDayReservationID = @ConfDayReservationID

		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH

		ROLLBACK TRANSACTION
		THROW

	END CATCH

END

