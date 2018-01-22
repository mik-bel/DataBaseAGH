if EXISTS (select * from sys.procedures where name = 'AddWorkshopRegistration')
    drop procedure AddWorkshopRegistration
GO
CREATE PROCEDURE AddWorkshopRegistration
	@WorkshopReservID int,
	@ParticipantID int,
	@ConfDayRegistrationID int,
	@WorkShopRegistrationID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
		
		IF @ParticipantID IS NULL
			THROW 14,'@ParticipantID is null in AddWorkshopRegistration', 1
		
		IF @WorkshopReservID IS NULL
			THROW 14,'@WorkshopReservID is null in AddWorkshopRegistration', 1
		
		IF @ConfDayRegistrationID IS NULL
			THROW 14,'@ConfDayRegistrationID is null in AddWorkshopRegistration', 1
		

		Declare @ClientID int = (Select TOP 1 ClientID from Participants where Participants.ParticipantID=@ParticipantID)

		IF (SELECT Count (*) from Clients 
			Inner Join Participants on Participants.ClientID = Clients.ClientID 
			inner join ConfDayReservations on ConfDayReservations.ClientID = Participants.ClientID
			inner join WorkshopReservations on WorkshopReservations.ConfDayReservationID=ConfDayReservations.ConfDayReservationID
			inner join ConfDayRegistrations on ConfDayReservations.ConfDayReservationID = ConfDayRegistrations.ConfDayReservationID 
			where Participants.ParticipantID = @ParticipantID
			and ConfDayRegistrations.ConfDayRegistrationID = @ConfDayRegistrationID
			and WorkshopReservations.WorkshopReservID = @WorkshopReservID
			) = 0
			THROW 14, 'Nie istnieje takiego polaczenia @ParticipantID - @WorkshopReservID w AddWorkshopRegistration',1
		
		if dbo.WorkshopReservationFreeSeats(@WorkshopReservID) < 1
			THROW 14, 'WorkshopReservationFreeSeats(@WorkshopReservID) = 0 in AddWorkshopRegistration', 1

		INSERT WorkshopRegistrations(WorkshopReservID, ParticipantID,ConfDayRegistrationID) 
		VALUES (@WorkshopReservID, @ParticipantID,@ConfDayRegistrationID)
		SET @WorkShopRegistrationID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END
