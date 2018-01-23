IF OBJECT_ID('WorkshopFreeSeats') is not null
DROP FUNCTION WorshopFreeSeats;
GO



CREATE FUNCTION WorkshopFreeSeats(@WorkshopID int)
		RETURNS int
		AS 
		BEGIN
			DECLARE @Seats AS int 
			SET @Seats = (
				SELECT Seats
				FROM Workshops
				WHERE WorkshopID = @WorkshopID
			)

			DECLARE @Taken AS int 
			SET @Taken = (
				SELECT SUM(NumReservs)
				FROM WorkshopReservations
				WHERE WorkshopID = @WorkshopID and Cancelled = 0
			)
			IF @Taken is null
			BEGIN 
				SET @Taken = 0
			END 
			RETURN (@Seats - @Taken)
		END
GO