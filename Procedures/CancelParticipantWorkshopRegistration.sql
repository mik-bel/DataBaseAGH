IF OBJECT_ID ('CancelParticipantWorkshopRegistration') is not null
DROP PROC CancelParticipantWorkshopRegistration;
GO


CREATE PROCEDURE CancelParticipantWorkshopRegistration (
	@ParticipantID int,
	@WorkshopRegID int
)

AS BEGIN

	SET NOCOUNT ON
	BEGIN TRY 
		BEGIN TRANSACTION 

					IF @ParticipantID is null
						THROW 2500, 'ParticipantID cant be null!', 1

					DELETE b From WorkshopRegistrations b
					LEFT JOIN Participants where ParticipantID = b.ParticipantID and b.WorkshopRegID = @WorkshopRegID

					 
		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH
END 

GO
