if EXISTS (select * from sys.procedures where name = 'AddConference')
    drop procedure AddConference
GO
CREATE PROCEDURE AddConference
	@Name varchar,
	@AdressID int,
	@ConferenceID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION

		
		IF @AdressID IS NULL
			THROW 14,'Musisz podac adres', 1
		
		IF @Name IS NULL
			THROW 14, 'Musisz podac nazwe konferencji', 1


		INSERT Conference (Name, AdressID) 
		VALUES (@Name, @AdressID)
		SET @ConferenceID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END
