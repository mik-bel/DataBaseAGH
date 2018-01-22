if EXISTS (select * from sys.procedures where name = 'AddPayment')
    drop procedure AddPayment
GO
CREATE PROCEDURE AddPayment
	@ConfDayReservationID int,
	@Payed float
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		if @ConfDayReservationID IS NULL
		Throw 14, '@ConfDayReservationID IS NULL in AddPayment', 1
		
		if @Payed IS NULL
		Throw 14, '@Payed IS NULL in AddPayment', 1
		
		if @Payed <0
		Throw 14, '@Payed <0 in AddPayment', 1
		
		Declare @paidprice float = (select PaidPrice from ConfDayReservations where ConfDayReservationID = @ConfDayReservationID)
		
		UPDATE ConfDayReservations set PaidPrice = @paidprice+@Payed where ConfDayReservationID = @ConfDayReservationID

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END
