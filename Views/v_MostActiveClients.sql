IF OBJECT_ID('v_MostActiveClients') is not null
DROP VIEW v_MostActiveClients;
GO

CREATE VIEW v_MostActiveClients
		AS
		SELECT Clients.ClientID AS 'ClientID', Login AS 'Login', COUNT(*)  AS 'Number of Reservations' FROM dbo.Clients
		INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ClientID = Clients.ClientID
		GROUP BY Clients.ClientID, Login

GO