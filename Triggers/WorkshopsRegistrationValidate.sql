IF OBJECT_ID ('WorkshopsRegistrationValidate') is not null
DROP TRIGGER WorkshopsRegistrationValidate;
GO


CREATE TRIGGER WorkshopsRegistrationValidate
-- przy dodawaniu rejestracji na warsztat sprawdza, czy participant nie
-- zarejestrowal sie na inny warsztat w tym czasie
ON WorkshopRegistrations

AFTER INSERT, UPDATE 

AS BEGIN
	DECLARE @WorkshopRegID int

	IF (select count(*) from INSERTED) = 0
		RETURN
	IF (select count(*) from INSERTED) = 1 

		BEGIN

			SELECT @WorkshopRegID = WorkshopRegID
			FROM INSERTED

				DECLARE 
				@EndTime datetime,
				@StartTime datetime,
				@WorkshopReservID int,
				@ParticipantID int,
				@WorkshopID int
				
				SELECT 

				@WorkshopID = W.WorkshopID, 
				@StartTime = W.StartTime,
				@EndTime = W.EndTime,
				@WorkshopReservID = WR.WorkshopReservID,
				@ParticipantID = WR.ParticipantID

				FROM WorkshopRegistrations WR
					JOIN WorkshopReservations WV on WV.WorkshopReservID = WR.WorkshopReservID
					JOIN Workshops W on W.WorkshopID = WV.WorkshopID
				WHERE WR.WorkshopRegID = @WorkshopRegID

				IF EXISTS
				 (
					SELECT W.WorkshopID
					FROM Workshops W 
					WHERE ((W.StartTime BETWEEN @StartTime AND @EndTime) OR (W.EndTime BETWEEN @StartTime AND @EndTime))
					AND W.WorkshopID IN (SELECT W.WorkshopID
										 	FROM Workshops W
										 	JOIN WorkshopReservations WR on W.WorkshopID = WR.WorkshopID
										 	JOIN WorkshopRegistrations WRs on WR.WorkshopReservID = WRs.WorkshopReservID
										 WHERE WRs.ParticipantID = @ParticipantID and WRs.WorkshopRegID <> @WorkshopRegID

						)	
				) 

				BEGIN

				RAISERROR ('THIS PARTICIPANT HAS ANOTHER WORKSHOP AT THIS TIME!',2500, 1)
				ROLLBACK TRANSACTION

				END

				IF EXISTS (
					SELECT WorkshopID from WorkshopReservations w
					JOIN WorkshopRegistrations wr on wr.ParticipantID = @ParticipantID
					where WorkshopID = @WorkshopID and w.WorkshopReservID <> @WorkshopReservID
				)
				
				BEGIN

					RAISERROR ('THIS PARTICIPANT IS ALREADY REGISTERED ON THIS WORKSHOP!',2500, 1)
					ROLLBACK TRANSACTION

				END
					
				IF NOT EXISTS (
					SELECT WR.ConfDayRegistrationID 
					FROM WorkshopRegistrations WR
						JOIN ConfDayRegistrations CDR on CDR.ConfDayRegistrationID = WR.ConfDayRegistrationID
					WHERE WR.WorkshopRegID = @WorkshopRegID and WR.ParticipantID = @ParticipantID
				)	
				BEGIN

				RAISERROR ('THIS PARTICIPANT IS NOT REGISTERED ON CONFERENCE!!',2500,1)
				ROLLBACK TRANSACTION

				END
				
		END
	ELSE 
		BEGIN
		
		RAISERROR ('You cant insert more than one record ar once!',2500, 1)
		ROLLBACK TRANSACTION
		
		END

END

GO

ALTER TABLE WorkshopRegistrations ENABLE TRIGGER WorkshopsRegistrationValidate