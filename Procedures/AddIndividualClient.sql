--procedures

IF OBJECT_ID ('AddIndividualClient') is not null
DROP PROC AddIndividualClient;
GO

CREATE PROCEDURE AddIndividualClient ( --klient może być zarówno firmą, jak i osobą indywidualną - rozbijamy.
-- dodatkowo od razu dodajemy participanta
	@ClientID int = NULL OUT,
	@CompanyID int,
	@Login nchar(10),
	@Password nvarchar(255),
	@Mail varchar(60),
	
--uzywane do dodania participanta
	@ParticipantID int,
    @FirstName nvarchar(20),
    @LastName nvarchar(20),
    @AdressID int,
    @StudentCardID int,

 --uzywane do dodania adresu
  	@AdressID int,
    @Country nvarchar(15),
    @PostalCode nvarchar(6),
    @City nvarchar(20),
    @FstLine nvarchar(40),
    @ScdLine nvarchar(40)
)
	AS
	BEGIN
	SET NOCOUNT ON
		BEGIN TRY
			BEGIN TRANSACTION
				
				IF @ClientID is null 
					THROW 2500, 'ClientID cant be null!', 1

				IF @Login is null
					THROW 2500, 'Login cant be null!', 1
				
				IF @Password is null 
					THROW (2500, 'Password cant be null!', 1)
				
				IF @Mail is null
					THROW (2500, 'Mail cant be null!', 1)

				SET(@ClientID) = SCOPE_IDENTITY()
				
				EXEC AddAddress
				EXEC AddParticipant(@ParticipantID, @FirstName, @LastName, @AdressID, @StudentCardID)
			
			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			THROW
		END CATCH
	END
GO

