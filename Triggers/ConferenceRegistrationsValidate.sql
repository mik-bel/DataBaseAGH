IF OBJECT_ID ('ConferenceRegistrationsValidate') is not null
DROP TRIGGER ConferenceRegistrationsValidate;
GO

CREATE TRIGGER ConferenceRegistrationsValidate

ON ConfDayRegistrations

AFTER INSERT, UPDATE

AS BEGIN

	DECLARE @ConfDayRegistrationID int, @ConfDayReservationID int

	IF (SELECT COUNT (*) FROM INSERTED) = 0
		RETURN
	IF (SELECT COUNT (*) FROM INSERTED) = 1

		BEGIN

			SELECT @ConfDayRegistrationID = ConfDayRegistrationID,
				   @ConfDayReservationID = ConfDayReservationID
			FROM INSERTED

			IF NOT EXISTS(
				SELECT ConfDayReservationID from ConfDayReservations
				where ConfDayReservationID = @ConfDayReservationID
			)

			BEGIN

				RAISERROR ('THERE IS NO RESERVATION ASSOCIATED WITH THIS REGISTRATION!!',2500, 1)
				ROLLBACK TRANSACTION

			END

			IF ConfDayReservationFreeSeats(@ConfDayReservationID) <= 0
			BEGIN 
				RAISERROR ('YOU DONT HAVE ENOUGH PLACES RESERVED!!',2500, 1)
				ROLLBACK TRANSACTION
			END

		END
	ELSE 
		
		BEGIN
				RAISERROR('YOU CANT INSERT OR UPDATE MORE THAN ONE RECORD AT THE SAME TIME!!!',2500,1)
				ROLLBACK TRANSACTION
		END
END


