
IF OBJECT_ID('ConfDayReservationFreeSeats') is not null
DROP FUNCTION ConfDayReservationFreeSeats;
GO

CREATE FUNCTION ConfDayReservationFreeSeats(@ReservationID int)
		RETURNS int
		AS 
		BEGIN
			DECLARE @Seats AS int
			SET @Seats = (
				SELECT NumSeats
				FROM ConfDayReservations
				WHERE ConfDayReservationID = @ReservationID 
			)

			DECLARE @Taken AS int 
			SET @Taken = (
				SELECT COUNT(*)
				FROM ConfDayRegistrations
				WHERE ConfDayReservationID = @ReservationID
			)
			IF @Taken is null
			BEGIN 
				SET @Taken = 0 
			END 
			RETURN (@Seats - @Taken)
		END
GO 