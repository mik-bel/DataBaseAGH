IF OBJECT_ID('Workshop_Free_Seats') is not null
DROP FUNCTION Worshop_Free_Seats;
GO

IF OBJECT_ID('ConfDay_Free_Seats') is not null
DROP FUNCTION ConfDay_Free_Seats;
GO 

IF OBJECT_ID('ConfDay_Reservation_Free_Seats') is not null
DROP FUNCTION ConfDay_Reservation_Free_Seats;
GO

IF OBJECT_ID('Workshop_Reservation_Free_Seats') is not null
DROP FUNCTION Workshop_Reservation_Free_Seats;
GO 


CREATE FUNCTION ConfDay_Free_Seats(@CDayID int)
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
				WHERE ConfDayID = @CDayID
			)
			IF @Taken is null 
			BEGIN
				SET @Taken = 0
			END 
			RETURN (@Seats - @Taken)
		END
GO

CREATE FUNCTION Workshop_Free_Seats(@WorkshopID int)
		RETURNS int
		AS 
		BEGIN
			DECLARE @Seats AS int 
			SET @Seats = (
				SELECT SeatsNum
				FROM Workshops
				WHERE WorkshopID = @WorkshopID
			)

			DECLARE @Taken AS int 
			SET @Taken = (
				SELECT SUM(NumReservs)
				FROM WorkshopReservations
				WHERE WorkshopID = @WorkshopID	
			)
			IF @Taken is null
			BEGIN 
				SET @Taken = 0
			END 
			RETURN (@Seats - @Taken)
		END
GO

CREATE FUNCTION ConfDay_Reservation_Free_Seats(@ReservationID int)
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

CREATE FUNCTION Workshop_Reservation_Free_Seats(@ReservationID int)
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