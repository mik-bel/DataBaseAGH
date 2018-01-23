IF OBJECT_ID('f_ConfDayParticipants') is not null
DROP FUNCTION f_ConfDayParticipants;
GO


CREATE FUNCTION f_ConfDayParticipants (@ConfDayID int)
		RETURNS TABLE
		AS
		
			RETURN (SELECT dbo.Participants.FirstName, dbo.Participants.LastName, dbo.Participants.StudentCardID as 'StudentCard ID'
					FROM dbo.ConferenceDays
					INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ConfDayID = ConferenceDays.ConfDayID
					INNER JOIN dbo.ConfDayRegistrations ON ConfDayRegistrations.ConfDayReservationID = ConfDayReservations.ConfDayReservationID
					INNER JOIN dbo.Participants ON Participants.ParticipantID = ConfDayRegistrations.ParticipantID
					WHERE ConferenceDays.ConfDayID = @ConfDayID)
GO