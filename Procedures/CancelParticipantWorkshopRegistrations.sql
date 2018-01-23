IF OBJECT_ID ('CancelParticipantWorkshopRegistrations') is not null
DROP PROC CancelParticipantWorkshopRegistrations;
GO


CREATE PROCEDURE CancelParticipantWorkshopRegistrations (
	@ParticipantID int
)

AS BEGIN

	SET NOCOUNT ON
	BEGIN TRY 
		BEGIN TRANSACTION 

					IF @ParticipantID is null
						THROW 2500, 'ParticipantID cant be null!', 1


					DELETE b From WorkshopRegistrations b
					LEFT JOIN Participants on b.ParticipantID = @ParticipantID
		
		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH
END 

GO
