IF OBJECT_ID('v_ClientConfDayReservationCount') is not null
DROP VIEW v_ClientConfDayReservationCount;
GO

CREATE VIEW v_ClientConfDayReservationCount
		AS
		SELECT CD.ConfDayID AS 'ConfDayID' , C.ClientID AS 'ClientID', COUNT(*) AS 'Number of reservations'
		 from ConfDayReservations as CDRv
		INNER JOIN ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
		INNER JOIN dbo.Clients AS C ON CDRv.ClientID = C.ClientID
		GROUP BY C.ClientID, CD.ConfDayID 
GO