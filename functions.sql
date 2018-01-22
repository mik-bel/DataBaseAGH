IF OBJECT_ID('WorkshopFreeSeats') is not null
DROP FUNCTION WorshopFreeSeats;
GO

IF OBJECT_ID('ConfDayFreeSeats') is not null
DROP FUNCTION ConfDayFreeSeats;
GO 

IF OBJECT_ID('ConfDayReservationFreeSeats') is not null
DROP FUNCTION ConfDayReservationFreeSeats;
GO

IF OBJECT_ID('WorkshopReservationFreeSeats') is not null
DROP FUNCTION WorkshopReservationFreeSeats;
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