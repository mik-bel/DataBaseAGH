if EXISTS (select * from sys.procedures where name = 'AddWorkshopReservation')
    drop procedure AddWorkshopReservation
GO
CREATE PROCEDURE AddWorkshopReservation
	@WorkshopID int,
	@ConfDayReservationID int,
	@NumReservs int,
	@ReservationDate datetime,
	@NumStudents float,
	
	@WorkshopReservationID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
		
		IF @WorkshopID IS NULL
			THROW 14,'@WorkshopID is null in AddWorkshopReservation', 1
		
		IF @ConfDayReservationID IS NULL
			THROW 14,'@ConfDayReservationID is null in AddWorkshopReservation', 1
		
		IF @NumReservs IS NULL or @NumReservs < 1
			THROW 14,'@NumReservs IS NULL or @NumReservs < 1 in AddWorkshopReservation', 1
		
		IF @ReservationDate IS NULL 
			THROW 14,'@ReservationDate is null in AddWorkshopReservation', 1
		
		DECLARE @ConfDate date = (select ConferenceDays.Date from Workshops 
								inner join ConferenceDays on ConferenceDays.ConfDayID = Workshops.ConfDayID
								where Workshops.WorkshopID=@WorkshopID )
				
		IF @ReservationDate  > @ConfDate
			THROW 14, '@ReservationDate  > @ConfDate in AddWorkshopReservation', 1
		
		
		IF @NumStudents > @NumReservs
			THROW 14,'@NumStudents > @NumReservs in AddWorkshopReservation', 1
		
		IF @NumStudents < 0
			THROW 14,'@NumStudents < 0 in AddWorkshopReservation', 1
	
		IF @NumReservs > dbo.WorkshopFreeSeats(@WorkshopID)
			THROW 14,'@NumReservs > dbo.WorkshopFreeSeats(@WorkshopID) in AddWorkshopReservation', 1


		INSERT WorkshopReservations(WorkshopID, ConfDayReservationID, NumReservs, ReservationDate, NumStudents) 
		VALUES (@WorkshopID, @ConfDayReservationID, @NumReservs, @ReservationDate, @NumStudents)
		SET @WorkshopReservationID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		THROW
		ROLLBACK TRANSACTION
	END CATCH

END
