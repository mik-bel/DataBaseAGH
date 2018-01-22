
IF OBJECT_ID ('ModifyCompany') is not null
DROP PROC ModifyCompany;
GO

CREATE PROCEDURE ModifyCompany (
	@CompanyID int,
	@CompanyName nvarchar (20),
	@AdressID int,
)

AS BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY
		BEGIN TRANSACTION

			IF @CompanyID is null
			THROW 2500, 'CompanyID cant be null!'

			IF @CompanyName is null 
			THROW 2500, 'CompanyName cant be null!'

			IF @AdressID is null 
			THROW 2500, 'AdressID cant be null!'

			UPDATE Companies
			SET
				CompanyName = @CompanyName
				AdressID = @AdressID

			WHERE CompanyID = @CompanyID

			IF @@ROWCOUNT = 0 
				THROW 2500, 'You provided incorrect CompanyID, Company with such ID doesnt exist!', 1

		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END

GO