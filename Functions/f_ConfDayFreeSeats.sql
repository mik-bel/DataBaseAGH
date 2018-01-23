IF OBJECT_ID('ConfDayFreeSeats') is not null
DROP FUNCTION ConfDayFreeSeats;
GO 

CREATE FUNCTION ConfDayFreeSeats(@CDayID int)
		RETURNS int
		AS
		BEGIN
			DECLARE @Seats AS int 
			SET @Seats = ( 
				SELECT SeatsNum
				FROM ConferenceDays
				WHERE ConfDayID = @CDayID
			)
			
			DECLARE @Taken AS int 
			SET @Taken = (
				SELECT SUM( NumSeats)
				FROM ConfDayReservations
				WHERE ConfDayID = @CDayID and Cancelled = 0
			)
			IF @Taken is null 
			BEGIN
				SET @Taken = 0
			END 
			RETURN (@Seats - @Taken)
		END
GO
