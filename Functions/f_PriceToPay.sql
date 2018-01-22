IF OBJECT_ID('PriceToPay') is not null
DROP FUNCTION PriceToPay;
GO

CREATE FUNCTION PriceToPay(@ClientID int)
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
			
			Declare @toPayCDRv float = 
			(Select SUM (Ds.Discount*(CD.Price*((NumSeats-CDRv.NumStudents) +(CDRv.NumStudents)*(1-(StudentDiscount)))*(1-CDRv.Cancelled)))  
			 from ConfDayReservations as CDRv 
			inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
			inner join Workshops as Ws on Ws.ConfDayID = CD.ConfDayID
			inner join WorkshopReservations as WR on WR.ConfDayReservationID = CDRv.ConfDayReservationID
			inner join Discounts as Ds on CD.Date between Ds.DiscountStartDate and Ds.DiscountEndDate
			where CDRv.ClientID = @ClientID and CDRv.Cancelled = 0 and WR.Cancelled = 0)

			RETURN (@toPayCDRv + @toPayWorkshop)
		END
GO