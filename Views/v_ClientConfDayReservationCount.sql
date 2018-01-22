IF OBJECT_ID('v_ClientConfDayReservationCount') is not null
DROP FUNCTION v_ClientConfDayReservationCount;
GO

CREATE VIEW v_ClientConfDayReservationCount
		AS
		SELECT CD.ConfDayID
			   
		 from ConfDayReservations as CDRv
		INNER JOIN ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
		INNER JOIN  ()
GO