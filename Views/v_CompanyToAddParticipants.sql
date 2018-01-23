IF OBJECT_ID('v_CompanyToAddParticipants') is not null
DROP VIEW v_CompanyToAddParticipants;
GO

CREATE VIEW v_CompanyToAddParticipants
		AS
		SELECT CompanyName AS 'Company', Mail AS 'mail', DATEDIFF(DAY,  GETDATE(), dbo.ConferenceDays.Date) AS 'Days before conferention' FROM dbo.Companies
		INNER JOIN dbo.Clients ON Clients.CompanyID = Companies.CompanyID
		INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ClientID = Clients.ClientID
		INNER JOIN dbo.ConferenceDays ON ConferenceDays.ConfDayID = ConfDayReservations.ConfDayID
		INNER JOIN dbo.Conference ON Conference.ConferenceID = ConferenceDays.ConfID
		WHERE dbo.ConfDayReservationFreeSeats(ConfDayReservationID)>0 
		AND DATEDIFF(DAY,  GETDATE(), dbo.ConferenceDays.Date) BETWEEN 0 AND 14
GO