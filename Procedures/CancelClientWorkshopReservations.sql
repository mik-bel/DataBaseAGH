IF OBJECT_ID ('CancelClientWorkshopReservations') is not null
DROP PROC CancelClientWorkshopReservations;
GO


CREATE PROCEDURE CancelClientWorkshopReservations (
	@ClientID int
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
				 ) = WorkshopReservations.ConfDayReservationID
				
				DELETE WRS from WorkshopRegistrations WRS
				
				left join WorkshopReservations w on w.WorkshopReservID = WRS.WorkshopReservID

				WHERE WorkshopReservID = (select WorkshopReservID from WorkshopReservations wr 
					inner join ConfDayReservations on ConfDayReservations.ClientID = @ClientID
					where ConfDayReservationID = wr.ConfDayReservationID
					)

			COMMIT TRANSACTION

		END TRY

		BEGIN CATCH
			
			ROLLBACK TRANSACTION
			THROW

		END CATCH
END

GO