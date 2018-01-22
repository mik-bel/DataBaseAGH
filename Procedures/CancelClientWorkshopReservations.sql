IF OBJECT_ID ('CancelClientWorkshopReservations') is not null
DROP PROC CancelClientWorkshopReservations;
GO


CREATE PROCEDURE CancelClientWorkshopReservations (
	@ConfDayReservationID int
)

AS BEGIN
	SET NOCOUNT ON
		
		BEGIN TRY
			BEGIN TRANSACTION

				IF @ConfDayReservationID is null
				THROW 2500, 'ConfDayReservationID cant be null!', 1

		
				UPDATE WorkshopReservations
					SET Cancelled = 1
				WHERE ConfDayReservationID = @ConfDayReservationID


				DELETE WRS from WorkshopRegistrations WRS
				WHERE WRS.WorkshopReservID = (select wr.WorkshopReservID from WorkshopReservations wr 
					inner join ConfDayReservations on ConfDayReservations.ConfDayReservationID = @ConfDayReservationID
				)

			COMMIT TRANSACTION

		END TRY

		BEGIN CATCH
			
			ROLLBACK TRANSACTION
			THROW

		END CATCH
END

GO