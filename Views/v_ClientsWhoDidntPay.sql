IF OBJECT_ID('v_ClientsWhoDidntPay') is not null
DROP VIEW v_ClientsWhoDidntPay;
GO

CREATE VIEW v_ClientsWhoDidntPay
		AS
		SELECT Login AS 'Login', ISNULL(CompanyName, 'Personal client') AS 'Company',  dbo.f_PriceToPayPerDay(Clients.ClientID, ConfDayReservationID) - PaidPrice AS 'Price to pay'
		FROM dbo.Clients
		INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ClientID = Clients.ClientID
		LEFT OUTER JOIN dbo.Companies ON Companies.CompanyID = Clients.CompanyID
		WHERE dbo.f_PriceToPayPerDay(Clients.ClientID, ConfDayReservationID) >PaidPrice AND 
		DATEDIFF(DAY, ReservationDate,  GETDATE()) > 7
		AND Cancelled = 1
GO