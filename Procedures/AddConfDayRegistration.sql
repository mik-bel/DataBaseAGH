if EXISTS (select * from sys.procedures where name = 'AddConfDayRegistration')
    drop procedure AddConfDayRegistration
GO
CREATE PROCEDURE AddConfDayRegistration
	@ParticipantID int,
	@ConfDayReservationID int,
	
	@ConfDayRegistrationID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
		
		IF @ParticipantID IS NULL
			THROW 14,'@ParticipantID is null in AddConfDayRegistration', 1
		
		IF @ConfDayReservationID IS NULL
			THROW 14,'@ConfDayReservationID is null in AddConfDayRegistration', 1
		
		Declare @ClientID int = (Select TOP 1 ClientID from Participants where Participants.ParticipantID=@ParticipantID)

		IF (SELECT Count (*) from Clients 
			Inner Join Participants on Participants.ClientID = Clients.ClientID 
			inner join ConfDayReservations on ConfDayReservations.ClientID = Participants.ClientID 
			where Participants.ParticipantID = @ParticipantID
			and ConfDayReservations.ConfDayReservationID = @ConfDayReservationID) = 0
			THROW 14, 'Nie istnieje takiego polaczenia @ParticipantID - @ConfDayReservationID w AddConfDayRegistration',1

		DECLARE @PriceToPay float = dbo.f_PriceToPay (@ClientID)

		IF @PriceToPay >= (select PaidPrice from ConfDayReservations where ConfDayReservationID=@ConfDayReservationID)
			THROW 14,'Nie zostala dokonana wplata, uczestnik nie moze byc zarejestrowany na konferencje.',1

		INSERT ConfDayRegistrations(ParticipantID, ConfDayReservationID) 
		VALUES (@ParticipantID, @ConfDayReservationID)
		SET @ConfDayRegistrationID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		THROW
		ROLLBACK TRANSACTION
	END CATCH

END
