
IF OBJECT_ID ('ModifyClient') is not null
DROP PROC ModifyClient;
GO


CREATE PROCEDURE ModifyClient (
	@ClientID int,
	@CompanyID int,
	@Login nvarchar (20) ,
	@Password nvarchar (255),
	@Mail nvarchar (60)	
)

AS BEGIN
	SET NOCOUNT ON

		BEGIN TRY
			BEGIN TRANSACTION

				IF @ClientID is null 
				THROW 2500,'ClientID cant be null!', 1

				IF @Login is null 
				THROW 2500, 'Login cant be null!', 1

				IF @Password is null
				THROW 2500, 'Password cant be null!', 1

				IF @Mail is null
				THROW 2500, 'Mail cant be null!', 1

				UPDATE Clients
				SET
					CompanyID = @CompanyID
					Login = @Login
					Password = @Password
					Mail = @Mail
				WHERE ClientID = @ClientID 

				IF @@ROWCOUNT = 0
					THROW 2500, 'You provided incorrect ClientID, Client with such ID doesnt exist!', 1

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			THROW
		END CATCH
END

GO