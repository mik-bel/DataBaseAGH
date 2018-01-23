IF OBJECT_ID('f_WorkshopParticipants') is not null
DROP FUNCTION f_WorkshopParticipants;
GO


CREATE FUNCTION f_WorkshopParticipants (@WorkshopID int)
		RETURNS TABLE
		AS
		
			RETURN (SELECT dbo.Participants.FirstName, dbo.Participants.LastName, dbo.Participants.StudentCardID as 'StudentCard ID'
					FROM dbo.Workshops
					INNER JOIN dbo.WorkshopReservations ON WorkshopReservations.WorkshopID = Workshops.WorkshopID
					inner JOIN dbo.WorkshopRegistrations ON WorkshopRegistrations.WorkshopReservID = WorkshopReservations.WorkshopReservID
					INNER JOIN dbo.Participants ON Participants.ParticipantID = WorkshopRegistrations.ParticipantID
					WHERE Workshops.WorkshopID = @WorkshopID)
GO