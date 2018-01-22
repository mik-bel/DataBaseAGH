IF OBJECT_ID ('CancelClientWorkshopReservation') is not null
DROP PROC CancelClientWorkshopReservation;
GO


CREATE PROCEDURE CancelClientWorkshopReservation (
	@ClientID int,
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
				WHERE ( select ConfDayReservations.ConfDayReservationID from ConfDayReservations
						where ConfDayReservations.ClientID = @ClientID
				 ) = WorkshopReservations.ConfDayReservationID and WorkshopReservations.WorkshopID = @WorkshopID
				

				DELETE WRS from WorkshopRegistrations WRS
				
					left join WorkshopReservations w on w.WorkshopReservID = WRS.WorkshopReservID

				WHERE WorkshopReservID = (select WorkshopReservID from WorkshopReservations wr 
					inner join ConfDayReservations on ConfDayReservations.ClientID = @ClientID
					where wr.WorkshopID = @WorkshopID and ConfDayReservationID = wr.ConfDayReservationID
				)

			COMMIT TRANSACTION

		END TRY

		BEGIN CATCH
			
			ROLLBACK TRANSACTION
			THROW

		END CATCH
END

GO