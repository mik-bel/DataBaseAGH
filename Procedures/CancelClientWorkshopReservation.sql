IF OBJECT_ID ('CancelClientWorkshopReservation') is not null
DROP PROC CancelClientWorkshopReservation;
GO


CREATE PROCEDURE CancelClientWorkshopReservation (
	@ConfDayReservationID
	@WorkshopID int
)

AS BEGIN
	SET NOCOUNT ON
		
		BEGIN TRY
			BEGIN TRANSACTION

				IF @ClientID is null
				THROW 2500, 'ClientID cant be null!', 1


				
				UPDATE WorkshopReservations
					SET Cancelled = 1
				WHERE ConfDayReservationID = @ConfDayReservationID and WorkshopID = @WorkshopID
				

				DELETE WRS from WorkshopRegistrations WRS
					left join WorkshopReservations w on w.WorkshopReservID = WRS.WorkshopReservID
				WHERE w.ConfDayReservationID = @ConfDayReservationID and w.WorkshopID = @WorkshopID

			COMMIT TRANSACTION

		END TRY

		BEGIN CATCH
			
			ROLLBACK TRANSACTION
			THROW

		END CATCH
END

GO