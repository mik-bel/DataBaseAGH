
IF OBJECT_ID ('AddCompany') is not null
DROP PROC AddCompany;
GO


CREATE PROCEDURE AddCompany (
	@CompanyID int,
	@CompanyName int,
	@AdressID int,
	@NIP nvarchar(12)
)
AS BEGIN
	SET NOCOUNT ON


		IF @CompanyID is null
			THROW 2503, 'CompanyID cant be null!', 1
		
		IF @CompanyName is null
			THROW 2503, 'CompanyName cant be null!', 1
		
		IF @AdressID is null
			THROW 2503, 'AdressID cant be null!', 1
		
		IF @NIP is null
			THROW 2503, 'NIP cant be null!', 1


	 	-- sprawdzanie czy adres istnieje

	 	IF (Select AdressID from Adresses where AdressID = @AdressID) is null
	 		THROW 2500, 'Adress with provided ID doesnt exist!', 1



		INSERT INTO Companies (CompanyID, CompanyName, AdressID, NIP)
		VALUES @CompanyID, @CompanyName, @AdressID, @NIP;

END

