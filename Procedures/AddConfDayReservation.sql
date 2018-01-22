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
		
		
		IF @ClientID IS NULL
			THROW 14,'@ClientID is null in AddConfDayReservation', 1

		IF @ConfDayID IS NULL
			THROW 14,'@ConfDayID is null in AddConfDayReservation', 1

		IF @NumSeats IS NULL
			THROW 14,'@NumSeats is null in AddConfDayReservation', 1
		IF @ReservationDate IS NULL
			THROW 14,'@ReservationDate is null in AddConfDayReservation', 1
		
		IF @PaidPrice IS NULL
			THROW 14,'@PaidPrice is null in AddConfDayReservation', 1
		
		IF @NumStudents IS NULL
			THROW 14,'@NumStudents is null in AddConfDayReservation', 1

		IF @NumStudents > @NumSeats
			THROW 14,'@NumStudents > @NumSeats in AddConfDayReservation', 1

		IF @PaidPrice < 0 
			THROW 14,'@PaidPrice < 0  in AddConfDayReservation', 1

		IF dbo.ConfDayFreeSeats(@ConfDayID) < @NumSeats
			THROW 14,'ConfDayFreeSeats(@ConfDayID) < @NumSeats in AddConfDayReservation', 1
	
		INSERT ConfDayReservations (ClientID, ConfDayID, NumSeats, ReservationDate, PaidPrice, NumStudents) 
		VALUES (@ClientID, @ConfDayID, @NumSeats, @ReservationDate, @PaidPrice, @NumStudents)
		SET @ConfDayReservationID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		THROW
		ROLLBACK TRANSACTION
	END CATCH

END
