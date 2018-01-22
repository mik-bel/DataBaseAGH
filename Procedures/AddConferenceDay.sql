if EXISTS (select * from sys.procedures where name = 'AddConferenceDay')
    drop procedure AddConferenceDay
GO
CREATE PROCEDURE AddConferenceDay
	@ConfID int,
	@Date date,
	@Price float,
	@SeatNums int,
	@StudentDiscount float,
	@ConfDayID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION

		
		IF @ConfID IS NULL
			THROW 14,'conf_id is null', 1
		
		IF @Date IS NULL
			THROW 14, 'Musisz podac dzien konferencji', 1

		IF @Price IS NULL
			THROW 14, 'Musisz podac cene dnia konferencji', 1
			
		IF @SeatNums IS NULL
			THROW 14, 'Musisz podac liczbe miejsc w dniu konferencji konferencji', 1
			
		IF @StudentDiscount IS NULL OR @StudentDiscount <0
			THROW 14, '@StudentDiscount IS NULL OR @StudentDiscount < 0 in AddConferenceDay', 1

		INSERT ConferenceDays (ConfID, Date, Price, SeatsNum, StudentDiscount) 
		VALUES (@ConfDayID, @Date, @Price, @SeatNums,@StudentDiscount)
		SET @ConfDayID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END
