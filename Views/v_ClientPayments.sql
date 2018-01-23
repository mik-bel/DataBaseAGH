IF OBJECT_ID('v_ClientPayments') is not null
DROP VIEW v_ClientPayments;
GO

CREATE VIEW v_ClientPayments
		AS
		SELECT Login,  ISNULL(CompanyName, 'Private person') AS 'Company name', SUM(PaidPrice) AS 'Paid price' FROM 
		dbo.Clients 
		INNER JOIN dbo.ConfDayReservations ON Clients.ClientID = ConfDayReservations.ClientID
		LEFT OUTER JOIN dbo.Companies ON Companies.CompanyID=Clients.CompanyID
		GROUP BY Login, CompanyName
GO