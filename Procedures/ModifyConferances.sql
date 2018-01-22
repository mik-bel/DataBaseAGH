
IF OBJECT_ID ('ModifyConferances') is not null
DROP PROC ModifyConferances;
GO

CREATE PROCEDURE ModifyConferances (
	@ConferenceID int,
	@Name varchar (50),
	@AdressID int,
	@StudentDiscount int
)

AS BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		BEGIN TRANSACTION

			IF @ConferenceID is null
			THROW 2500, 'ConferenceID cant be null!', 1

			IF @Name is null
			THROW 2500, 'Name cant be null!', 1

			IF @AdressID is null
			THROW 2500, 'AdressID cant be null!', 1

			UPDATE Conference
			SET 
				Name = @Name
				AdressID = @AdressID
				StudentDiscount = @StudentDiscount
			WHERE ConferenceID = @ConferenceID

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END

GO