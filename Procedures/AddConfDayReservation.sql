if EXISTS (select * from sys.procedures where name = 'AddConfDayReservation')
    drop procedure AddConfDayReservation
GO
CREATE PROCEDURE AddConfDayReservation
	@ClientID int,
	@ConfDayID int,
	@NumSeats int,
	@ReservationDate datetime,
	@PaidPrice float,
	@NumStudents int,

	@ConfDayReservationID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
		
		IF @ConfDayID IS NULL
			THROW 14,'@ConfDayID is null in AddDiscount', 1
		
		IF @DiscountStartDate IS NULL
			THROW 14,'@DiscountStartDate is null in AddDiscount', 1
		
		IF @DiscountEndTime IS NULL
			THROW 14,'@DiscountEndTime is null in AddDiscount', 1

		IF @ConfDayID IS NULL
			THROW 14,'@Discount is null in AddDiscount', 1
						
		IF @Discount < 0
			THROW 14,'@Discount must be > 0  in AddDiscount', 1
						
		IF @DiscountStartDate > @DiscountEndDate
			THROW 14,'@DiscountStartDate > @DiscountEndDate in AddDiscount', 1
			
		DECLARE @ConferenceDate date = (select Date from ConferenceDays where ConferenceDays.ConfDayID = @ConfDayID) 
		
		IF @DiscountStartDate > @ConferenceDate or @DiscountEndDate > @ConferenceDate
			THROW 14,'@DiscountStartDate > @ConferenceDate or @DiscountEndDate > @ConferenceDate in AddDiscount', 1
		
		INSERT Discounts(ConfDayID, DiscountStartDate, DiscountEndDate, Discount) 
		VALUES (@ConfDayID, @DiscountStartDate, @DiscountEndDate, @Discount)
		SET @DiscountID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		THROW
		ROLLBACK TRANSACTION
	END CATCH

END
