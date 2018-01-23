IF OBJECT_ID('WorkshopReservationFreeSeats') is not null
DROP FUNCTION WorkshopReservationFreeSeats;
GO 

CREATE FUNCTION WorkshopReservationFreeSeats(@ReservationID int)
		RETURNS int
		AS 
		BEGIN
			DECLARE @Seats AS int 
			SET @Seats = (
				SELECT NumReservs
				FROM WorkshopReservations
				WHERE WorkshopReservID = @ReservationID 
			)

			DECLARE @Taken AS int
			SET @Taken = (
				SELECT COUNT(*)
				FROM WorkshopRegistrations
				WHERE WorkshopReservID = @ReservationID
			)
			IF @Taken is null
			BEGIN
				SET @Taken = 0 
			END 
			RETURN (@Seats - @Taken)
		END
GO