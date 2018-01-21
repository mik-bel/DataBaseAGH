if EXISTS (select * from sys.procedures where name = 'AddAdress')
    drop procedure AddAdress
GO
CREATE PROCEDURE AddAdress
	@AdressID int = NULL OUT,
	@Country nvarchar,
	@PostalCode nvarchar,
	@City nvarchar,
	@FstLine nvarchar,
	@ScdLine nvarchar
AS
BEGIN
	SET NOCOUNT ON
	
	if @Country IS NULL or @PostalCode IS NULL OR @City IS NULL OR @FstLine IS NULL or @ScdLine IS NULL
		THROW 14, 'Musisz podac pelny adres', 1

	INSERT Adresses (Country,PostalCode, City, FstLine, ScdLine)
	VALUES
		(@Country, @PostalCode, @City, @FstLine, @ScdLine)
	SET @AdressID = SCOPE_IDENTITY(); 
END