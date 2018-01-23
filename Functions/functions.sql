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

IF OBJECT_ID('f_PriceToPay') is not null
DROP FUNCTION f_PriceToPay;
GO

CREATE FUNCTION f_PriceToPay(@ClientID int)
		RETURNS float
		AS
		BEGIN
			
			DECLARE @ToPay float = (select Sum(dbo.f_PriceToPayPerDay(@ClientID, ConfDayReservations.ConfDayReservationID))
			from ConfDayReservations where ConfDayReservations.ClientID=@ClientID AND ConfDayReservations.Cancelled=0)

			RETURN (@toPay)
		END
GO

IF OBJECT_ID('f_PriceToPayPerDay') is not null
DROP FUNCTION f_PriceToPayPerDay;
GO

CREATE FUNCTION f_PriceToPayPerDay(@ClientID int, @ConfDayReservationID int)
		RETURNS float
		AS
		BEGIN
			
			Declare @toPayWorkshop float = 
			(Select SUM (Ws.Price*((NumSeats-CDRv.NumStudents) +(CDRv.NumStudents)*(1-(StudentDiscount)))*(1-WR.Cancelled))  
			 from ConfDayReservations as CDRv 
			inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
			inner join Workshops as Ws on Ws.ConfDayID = CD.ConfDayID
			inner join WorkshopReservations as WR on WR.ConfDayReservationID = CDRv.ConfDayReservationID
			where CDRv.ClientID = @ClientID and CDRv.Cancelled = 0 and WR.Cancelled = 0)


			Declare @Discount float = (select Ds.Discount from  ConfDayReservations as CDRv 
			inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
			inner join Discounts as Ds on CD.Date between Ds.DiscountStartDate and Ds.DiscountEndDate
			where CDRv.ConfDayReservationID = @ConfDayReservationID) 

			IF @Discount IS NULL
			BEGIN 

				RETURN ( @toPayWorkshop +
				(Select SUM (CD.Price*((NumSeats-CDRv.NumStudents) +(CDRv.NumStudents)*(1-(StudentDiscount)))*(1-CDRv.Cancelled))  
				 from ConfDayReservations as CDRv 
				inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
				where CDRv.ClientID = @ClientID and ConfDayReservationID = @ConfDayReservationID and CDRv.Cancelled = 0)
				)
			END
			ELSE
				RETURN ( @toPayWorkshop + 
				(Select SUM ((1-@Discount)*CD.Price*((NumSeats-CDRv.NumStudents) +(CDRv.NumStudents)*(1-(StudentDiscount)))*(1-CDRv.Cancelled))  
				 from ConfDayReservations as CDRv 
				inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
				where CDRv.ClientID = @ClientID and ConfDayReservationID = @ConfDayReservationID and CDRv.Cancelled = 0)
				)
			RETURN 0.0
		END
GO

IF OBJECT_ID('f_ConfDayParticipants') is not null
DROP FUNCTION f_ConfDayParticipants;
GO


CREATE FUNCTION f_ConfDayParticipants (@ConfDayID int)
		RETURNS TABLE
		AS
		
			RETURN (SELECT dbo.Participants.FirstName, dbo.Participants.LastName, dbo.Participants.StudentCardID as 'StudentCard ID'
					FROM dbo.ConferenceDays
					INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ConfDayID = ConferenceDays.ConfDayID
					INNER JOIN dbo.ConfDayRegistrations ON ConfDayRegistrations.ConfDayReservationID = ConfDayReservations.ConfDayReservationID
					INNER JOIN dbo.Participants ON Participants.ParticipantID = ConfDayRegistrations.ParticipantID
					WHERE ConferenceDays.ConfDayID = @ConfDayID)
GO


IF OBJECT_ID('f_WorkshopParticipants') is not null
DROP FUNCTION f_WorkshopParticipants;
GO


CREATE FUNCTION f_WorkshopParticipants (@WorkshopID int)
		RETURNS TABLE
		AS
		
			RETURN (SELECT dbo.Participants.FirstName, dbo.Participants.LastName, dbo.Participants.StudentCardID as 'StudentCard ID'
					FROM dbo.Workshops
					INNER JOIN dbo.WorkshopReservations ON WorkshopReservations.WorkshopID = Workshops.WorkshopID
					inner JOIN dbo.WorkshopRegistrations ON WorkshopRegistrations.WorkshopReservID = WorkshopReservations.WorkshopReservID
					INNER JOIN dbo.Participants ON Participants.ParticipantID = WorkshopRegistrations.ParticipantID
					WHERE Workshops.WorkshopID = @WorkshopID)
GO