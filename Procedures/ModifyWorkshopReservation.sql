if EXISTS (select * from sys.procedures where name = 'ModifyWorkshopReservation')
    drop procedure ModifyWorkshopReservation
GO
CREATE PROCEDURE ModifyWorkshopReservation
	@WorkshopReservID int,
	@WorkshopID int,
	@NumReservs int,
	@NumStudents float
	
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
		
		IF @WorkshopID IS NULL
			THROW 14,'@WorkshopID is null in AddWorkshopReservation', 1
		

		IF @NumReservs IS NULL or @NumReservs < 1
			THROW 14,'@NumReservs IS NULL or @NumReservs < 1 in AddWorkshopReservation', 1
		
		IF @NumStudents > @NumReservs
			THROW 14,'@NumStudents > @NumReservs in AddWorkshopReservation', 1
		
		IF @NumStudents < 0
			THROW 14,'@NumStudents < 0 in AddWorkshopReservation', 1
	
		IF @NumReservs > dbo.WorkshopFreeSeats(@WorkshopID)
			THROW 14,'@NumReservs > dbo.WorkshopFreeSeats(@WorkshopID) in AddWorkshopReservation', 1

		Declare @ConfDayReservationID int = (select ConfDayReservationID from WorkshopReservations where WorkshopReservations.WorkshopReservID = @WorkshopReservID)

		Declare @NumConfSeatsReserv int = (select NumSeats from ConfDayReservations where ConfDayReservationID = @ConfDayReservationID)

		If @NumConfSeatsReserv < @NumReservs
			THROW 14,'@NumConfSeatsReserv < @NumReservs in AddWorkshopReservation', 1
			
		IF dbo.WorkshopFreeSeats(@WorkshopID)<@NumReservs - (select NumReservs from WorkshopReservations where WorkshopReservID=@WorkshopReservID) 
			THROW 14, 'Za malo wolnych miejsc na warsztacie w AddWorkshopReservation',1

		UPDATE WorkshopReservations SET 
			NumReservs=@NumReservs,
			ReservationDate=GETDATE(),
			NumStudents=@NumStudents
		WHERE WorkshopReservID=WorkshopReservID
			 
		
		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END
