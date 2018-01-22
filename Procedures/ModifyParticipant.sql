
IF OBJECT_ID ('ModifyParticipant') is not null
DROP PROC ModifyParticipant;
GO

CREATE PROCEDURE ModifyParticipant (
	@ParticipantID int,
	@FirstName nvarchar (20),
	@LastName nvarchar (20),
	@AdressID int,
	@StudentCardID int
)

AS BEGIN
	SET NOCOUNT ON

		BEGIN TRY
			BEGIN TRANSACTION

				IF @ParticipantID is null
					THROW 2500, 'ParticipantID cant be null', 1

				IF @FirstName is null
					THROW 2500, 'FirstName cant be null', 1

				IF @LastName is null
					THROW 2500, 'LastName cant be null', 1

				IF @AdressID is null
					THROW 2500, 'AdressID cant be null', 1

				IF @StudentCardID is null
					THROW 2500, 'StudentCardID cant be null', 1

				UPDATE Participants
				SET

					FirstName = @FirstName
					LastName = @LastName
					AdressID = @AdressID
					StudentCardID = @StudentCardID
				WHERE ParticipantID = @ParticipantID

				IF @@ROWCOUNT = 0
					THROW 2500, 'You provided incorrect ParticipantID, Participant with such ID doesnt exist!', 1

				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			THROW
		END CATCH

END

GO

