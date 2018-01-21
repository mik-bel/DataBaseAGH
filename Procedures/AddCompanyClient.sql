
IF OBJECT_ID ('AddCompanyClient') is not null
DROP PROC AddCompanyClient;
GO

CREATE PROCEDURE AddCompanyClient (
	@ClientID int = NULL OUT,
	@CompanyID int = NULL OUT,
	@Login nchar(10),
	@Password nvarchar(255),
	@Mail varchar(60),

	@CompanyName int,
	@AdressID int,
	@NIP nvarchar(12)
)

AS BEGIN
SET NOCOUNT ON
	BEGIN TRY 
		BEGIN TRANSACTION

				IF @Login is null 
					THROW 2502, 'Login cant be null!', 1

				IF @Password is null
					THROW 2502, 'Password cant be null!', 1
				
				IF @Mail is null
					THROW 2502, 'Password cant be null!', 1

				INSERT Clients (Login, Password, Mail)
				VALUES (@Login, @Password, @Mail)
				SET @ClientID = SCOPE_IDENTITY();
				SET @CompanyID = SCOPE_IDENTITY();

				EXEC AddCompany @CompanyID, @CompanyName, @AdressID, @NIP 

		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH
END 

GO