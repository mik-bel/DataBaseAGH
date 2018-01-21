if EXISTS (select * from sys.procedures where name = 'AddWorkshop')
    drop procedure AddWorkshop
GO
CREATE PROCEDURE AddWorkshop
	@ConfDayID int,
	@Name nvarchar,
	@Seats int,
	@StartTime DateTime,
	@EndTime DateTime,
	@Price float,

	@WorkshopID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
		
		IF @StartTime IS NULL
			THROW 14,'@StartTime is null', 1
		
		IF @EndTime IS NULL
			THROW 14,'@EndTime is null', 1
		
		IF @EndTime < @StartTime
			THROW 14,'Workshop @EndTime < @StartTime', 1
		
		IF @Seats < 0
			THROW 14,'Workshop @Seats < 0', 1
		
		IF @Price < 0
			THROW 14,'Workshop @Price < 0', 1

		IF @ConfDayID IS NULL
			THROW 14,'@ConfDayID is null', 1
		
		IF @Name IS NULL
			THROW 14, 'Musisz podac nazwe warsztatu', 1

		IF @Price IS NULL
			THROW 14, 'Musisz podac cene konferencji', 1
			
		IF @Seats IS NULL
			THROW 14, 'Musisz podac liczbe miejsc na warsztacie (@Seats is null)', 1

		INSERT Workshops(ConfDayID, Name, Seats, StartTime, EndTime, Price) 
		VALUES (@ConfDayID, @Name, @Seats, @StartTime, @EndTime, @Price)
		SET @WorkshopID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		THROW
		ROLLBACK TRANSACTION
	END CATCH

END
