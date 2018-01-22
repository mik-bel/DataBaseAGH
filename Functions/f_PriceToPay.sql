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