IF OBJECT_ID('v_ClientsWhoDidntPay') is not null
DROP VIEW v_ClientsWhoDidntPay;
GO

CREATE VIEW v_ClientsWhoDidntPay
		AS
		SELECT * 
		FROM dbo.Clients
		INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ClientID = Clients.ClientID
		WHERE dbo.f_PriceToPayPerDay(Clients.ClientID, ConfDayReservationID) >PaidPrice AND 
		DATEDIFF(DAY, ReservationDate,  GETDATE()) > 7
GO