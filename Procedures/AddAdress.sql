if EXISTS (select * from sys.procedures where name = 'AddAdress')
    drop procedure AddAdress
GO


CREATE PROCEDURE AddAdress
	@AdressID int OUT,
	@Country nvarchar (15),
	@PostalCode nvarchar (6),
	@City nvarchar (20),
	@FstLine nvarchar (40),
	@ScdLine nvarchar (40)
AS BEGIN
	SET NOCOUNT ON
		BEGIN TRY
			BEGIN TRANSACTION

				IF @Country is null or LTRIM(@Country) = ''
				THROW 2500, 'Country cant be null or blank!!!', 1
				
				IF @PostalCode is null or LTRIM(@PostalCode) = ''
				THROW 2500, 'PostalCode cant be null or blank!!!', 1

				IF @City is null or LTRIM(@City) =''
				THROW 2500, 'City cant be null or blank!!', 1

				IF @FstLine is null or LTRIM(@FstLine) = ''
				THROW 2500, 'First Line cant be null!', 1

				IF @ScdLine is null
				SET @ScdLine = ''

				SELECT @AdressID = AdressID
				From Adresses
				WHERE FstLine = @FstLine AND ScdLine = @ScdLine AND City = @City AND PostalCode = @PostalCode

				IF @AdressID is null 
					or (select count(pr.AdressID)
						from (select AdressID
								from company
								union all
								select AdressID
								from Participants) as pr
						where AdressID = @AdressID ) > 1
					BEGIN
						INSERT INTO Adresses (FstLine, ScdLine, City, PostalCode)
						VALUES (@FstLine, @ScdLine, @City, @PostalCode)
						SET @AdressID = SCOPE_IDENTITY()
					END

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			THROW
		END CATCH

END 

GO