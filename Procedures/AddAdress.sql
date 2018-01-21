if EXISTS (select * from sys.procedures where name = 'AddAdress')
    drop procedure AddAdress
GO
CREATE PROCEDURE AddAdress
	@Country nvarchar,
	@PostalCode nvarchar,
	@City nvarchar,
	@FstLine nvarchar,
	@ScdLine nvarchar
AS
BEGIN
	BEGIN TRANSACTION
	if @Country IS NULL or @PostalCode IS NULL OR @City IS NULL OR @FstLine IS NULL or @ScdLine IS NULL
	BEGIN
		RAISERROR ('Musisz podac pelny adres', 14, 1)
		ROLLBACK TRANSACTION
		RETURN
	END
	INSERT Adresses (Country,PostalCode, City, FstLine, ScdLine)
	VALUES
		(@Country, @PostalCode, @City, @FstLine, @ScdLine)
	IF @@ERROR <>0
	BEGIN
		RAISERROR ('Nie mozesz dodac taki adres', 14, 1)
		ROLLBACK TRANSACTION
		RETURN
	END
	COMMIT TRANSACTION
END