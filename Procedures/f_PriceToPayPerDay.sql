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