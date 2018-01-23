USE mwroblew_a

if EXISTS (select * from sys.procedures where name = 'AddAdress')
    drop procedure AddAdress
GO

CREATE PROCEDURE AddAdress(
	@AdressID int OUT,
	@Country nvarchar (15),
	@PostalCode nvarchar (6),
	@City nvarchar (20),
	@FstLine nvarchar (40),
	@ScdLine nvarchar (40)
)
AS BEGIN
	SET NOCOUNT ON
		BEGIN TRY
			BEGIN TRANSACTION

				IF @Country is null or LTRIM(@Country) = ''
				THROW 2500, 'Country cant be null or blank!!!', 1
				
				IF @PostalCode is null or LTRIM(@PostalCode) = ''
				THROW 2500, 'PostalCode cant be null or blank!!!', 1

				IF @City is null or LTRIM(@City) =''
				THROW 2500, 'City cant be null or blank!!', 1

				IF @FstLine is null or LTRIM(@FstLine) = ''
				THROW 2500, 'First Line cant be null!', 1

				IF @ScdLine is null
				SET @ScdLine = ''

				SELECT @AdressID = AdressID
				From Adresses
				WHERE FstLine = @FstLine AND ScdLine = @ScdLine AND City = @City AND PostalCode = @PostalCode

				IF @AdressID is null 
					or (select count(pr.AdressID)
						from (select AdressID
								from dbo.Companies
								union all
								select AdressID
								from Participants) as pr
						where AdressID = @AdressID ) > 1
					BEGIN
						INSERT INTO Adresses (FstLine, ScdLine, City, PostalCode)
						VALUES (@FstLine, @ScdLine, @City, @PostalCode)
						SET @AdressID = SCOPE_IDENTITY()
					END

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			THROW
		END CATCH

END 

GO


IF OBJECT_ID ('AddCompany') is not null
DROP PROC AddCompany;
GO


CREATE PROCEDURE AddCompany (
	@CompanyID int,
	@CompanyName int,
	@AdressID int,
	@NIP nvarchar(12)
)
AS BEGIN
	SET NOCOUNT ON


		IF @CompanyID is null
			THROW 2503, 'CompanyID cant be null!', 1
		
		IF @CompanyName is null
			THROW 2503, 'CompanyName cant be null!', 1
		
		IF @AdressID is null
			THROW 2503, 'AdressID cant be null!', 1
		
		IF @NIP is null
			THROW 2503, 'NIP cant be null!', 1


	 	-- sprawdzanie czy adres istnieje

	 	IF (Select AdressID from Adresses where AdressID = @AdressID) is null
	 		THROW 2500, 'Adress with provided ID doesnt exist!', 1



		INSERT INTO Companies (CompanyID, CompanyName, AdressID, NIP)
		VALUES (@CompanyID, @CompanyName, @AdressID, @NIP)

END
GO
IF OBJECT_ID ('AddCompanyClient') is not null
DROP PROC AddCompanyClient;
GO

CREATE PROCEDURE AddCompanyClient (
	@ClientID int = NULL OUT,
	@CompanyID int = NULL OUT,
	@Login nchar(10),
	@Password nvarchar(255),
	@Mail varchar(60),

	@CompanyName int,
	@AdressID int,
	@NIP nvarchar(12)
)

AS BEGIN
SET NOCOUNT ON
	BEGIN TRY 
		BEGIN TRANSACTION

				IF @Login is null 
					THROW 2502, 'Login cant be null!', 1

				IF @Password is null
					THROW 2502, 'Password cant be null!', 1
				
				IF @Mail is null
					THROW 2502, 'Password cant be null!', 1

				INSERT Clients (Login, Password, Mail)
				VALUES (@Login, @Password, @Mail)
				SET @ClientID = SCOPE_IDENTITY();
				SET @CompanyID = SCOPE_IDENTITY();

				EXEC AddCompany @CompanyID, @CompanyName, @AdressID, @NIP

		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH
END 

GO
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

		DECLARE @PriceToPay float = dbo.f_PriceToPayPerDay (@ClientID, @ConfDayReservationID)

		IF dbo.ConfDayReservationFreeSeats (@ConfDayReservationID) < 1
			THROW 14, 'ConfDayReservationFreeSeats (@ConfDayReservationID) < 1', 1 

		IF @PriceToPay >= (select PaidPrice from ConfDayReservations where ConfDayReservationID=@ConfDayReservationID)
			THROW 14,'Nie zostala dokonana wplata, uczestnik nie moze byc zarejestrowany na dany dzien konferencji.',1

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
GO
if EXISTS (select * from sys.procedures where name = 'AddConference')
    drop procedure AddConference
GO
CREATE PROCEDURE AddConference
	@Name varchar,
	@AdressID int,
	@ConferenceID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION

		
		IF @AdressID IS NULL
			THROW 14,'Musisz podac adres', 1
		
		IF @Name IS NULL
			THROW 14, 'Musisz podac nazwe konferencji', 1


		INSERT Conference (Name, AdressID) 
		VALUES (@Name, @AdressID)
		SET @ConferenceID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END
GO
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
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END
GO
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
GO
if EXISTS (select * from sys.procedures where name = 'AddDiscount')
    drop procedure AddDiscount
GO
CREATE PROCEDURE AddDiscount
	@ConfDayID int,
	@DiscountStartDate date,
	@DiscountEndDate date,
	@Discount float,

	@DiscountID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
		
		IF @ConfDayID IS NULL
			THROW 14,'@ConfDayID is null in AddDiscount', 1
		
		IF @DiscountStartDate IS NULL
			THROW 14,'@DiscountStartDate is null in AddDiscount', 1
		
		IF @DiscountEndDate IS NULL
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
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END

--procedures
GO
IF OBJECT_ID ('AddIndividualClient') is not null
DROP PROC AddIndividualClient;
GO

CREATE PROCEDURE AddIndividualClient ( --klient może być zarówno firmą, jak i osobą indywidualną - rozbijamy.
-- dodatkowo od razu dodajemy participanta
	@ClientID int = NULL OUT,
	@Login nchar(10),
	@Password nvarchar(255),
	@Mail varchar(60),
	
--uzywane do dodania participanta
	@ParticipantID int = NULL OUT,
    @FirstName nvarchar(20),
    @LastName nvarchar(20),
    @AdressID int,
    @StudentCardID int

)
	AS
	BEGIN
	SET NOCOUNT ON
		BEGIN TRY
			BEGIN TRANSACTION
				
				IF @ClientID is null 
					THROW 2500, 'ClientID cant be null!', 1

				IF @Login is null
					THROW 2500, 'Login cant be null!', 1
				
				IF @Password is null 
					THROW 2500, 'Password cant be null!', 1
				
				IF @Mail is null
					THROW 2500, 'Mail cant be null!', 1

				INSERT INTO Clients(Login, Password, Mail, CompanyID)
				VALUES (@Login, @Password, @Mail, NULL)
				SET @ClientID = SCOPE_IDENTITY();
				
				
				EXEC AddParticipant @FirstName, @LastName, @AdressID, @StudentCardID, @ClientID;
			
			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			THROW
		END CATCH
	END
GO

IF OBJECT_ID ('AddParticipant') is not null
DROP PROC AddParticipant;
GO	

CREATE PROCEDURE AddParticipant (
    @FirstName nvarchar(20),
    @LastName nvarchar(20),
    @AdressID int,
    @StudentCardID int,
    @ClientID int,
    @ParticipantID int = NULL OUT
) AS BEGIN
	SET NOCOUNT ON


	IF @FirstName is null
		THROW 2501, 'First name cant be null!', 1
	
	IF @LastName is null
		THROW 2501, 'LastName cant be null!', 1

	IF @AdressID is null
		THROW 2501, 'AdressID cant be null!', 1

	IF @ClientID is null
		THROW 2501, 'ClientID cant be null', 1


	INSERT INTO Participants (ClientID, FirstName, LastName, AdressID, StudentCardID)
	VALUES (@ClientID, @FirstName, @LastName, @AdressID, @StudentCardID)
	SET @ParticipantID = SCOPE_IDENTITY();
END
GO
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
GO
if EXISTS (select * from sys.procedures where name = 'AddWorkshop')
    drop procedure AddWorkshop
GO
CREATE PROCEDURE AddWorkshop
	@ConfDayID int,
	@Name nvarchar,
	@Seats int,
	@StartTime DateTime,
	@EndTime DateTime,
	@Price float,

	@WorkshopID int = NULL OUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
		
		IF @StartTime IS NULL
			THROW 14,'@StartTime is null', 1
		
		IF @EndTime IS NULL
			THROW 14,'@EndTime is null', 1
		
		IF @EndTime < @StartTime
			THROW 14,'Workshop @EndTime < @StartTime', 1
		
		IF @Seats < 0
			THROW 14,'Workshop @Seats < 0', 1
		
		IF @Price < 0
			THROW 14,'Workshop @Price < 0', 1

		IF @ConfDayID IS NULL
			THROW 14,'@ConfDayID is null', 1
		
		IF @Name IS NULL
			THROW 14, 'Musisz podac nazwe warsztatu', 1

		IF @Price IS NULL
			THROW 14, 'Musisz podac cene konferencji', 1
			
		IF @Seats IS NULL
			THROW 14, 'Musisz podac liczbe miejsc na warsztacie (@Seats is null)', 1

		INSERT Workshops(ConfDayID, Name, Seats, StartTime, EndTime, Price) 
		VALUES (@ConfDayID, @Name, @Seats, @StartTime, @EndTime, @Price)
		SET @WorkshopID =  SCOPE_IDENTITY(); 

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		THROW
		ROLLBACK TRANSACTION
	END CATCH

END
GO
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
		

	--	Declare @ClientID int = (Select TOP 1 ClientID from Participants where Participants.ParticipantID=@ParticipantID)

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
GO
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

		Declare @NumConfSeatsReserv int = (select NumSeats from ConfDayReservations where ConfDayReservationID = @ConfDayReservationID)

		If @NumConfSeatsReserv < @NumReservs
			THROW 14,'@NumConfSeatsReserv < @NumReservs in AddWorkshopReservation', 1

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
GO
IF OBJECT_ID ('CancelClientWorkshopReservation') is not null
DROP PROC CancelClientWorkshopReservation;
GO


CREATE PROCEDURE CancelClientWorkshopReservation (
	@ConfDayReservationID INT,
	@WorkshopID int
)

AS BEGIN
	SET NOCOUNT ON
		
		BEGIN TRY
			BEGIN TRANSACTION
				
				UPDATE WorkshopReservations
					SET Cancelled = 1
				WHERE ConfDayReservationID = @ConfDayReservationID and WorkshopID = @WorkshopID
				

				DELETE WRS from WorkshopRegistrations WRS
					left join WorkshopReservations w on w.WorkshopReservID = WRS.WorkshopReservID
				WHERE w.ConfDayReservationID = @ConfDayReservationID and w.WorkshopID = @WorkshopID

			COMMIT TRANSACTION

		END TRY

		BEGIN CATCH
			
			ROLLBACK TRANSACTION
			THROW

		END CATCH
END

GO

IF OBJECT_ID ('CancelClientWorkshopReservations') is not null
DROP PROC CancelClientWorkshopReservations;
GO


CREATE PROCEDURE CancelClientWorkshopReservations (
	@ConfDayReservationID int
)

AS BEGIN
	SET NOCOUNT ON
		
		BEGIN TRY
			BEGIN TRANSACTION

				IF @ConfDayReservationID is null
				THROW 2500, 'ConfDayReservationID cant be null!', 1

		
				UPDATE WorkshopReservations
					SET Cancelled = 1
				WHERE ConfDayReservationID = @ConfDayReservationID


				DELETE WRS from WorkshopRegistrations WRS
				WHERE WRS.WorkshopReservID = (select wr.WorkshopReservID from WorkshopReservations wr 
					inner join ConfDayReservations on ConfDayReservations.ConfDayReservationID = @ConfDayReservationID
				)

			COMMIT TRANSACTION

		END TRY

		BEGIN CATCH
			
			ROLLBACK TRANSACTION
			THROW

		END CATCH
END

GO

IF OBJECT_ID ('CancelClientConfDayReservation') is not null
DROP PROC CancelClientConfDayReservation;
GO


CREATE PROCEDURE CancelClientConfDayReservation (
	@ConfDayReservationID int
)

AS BEGIN

	SET NOCOUNT ON

	BEGIN TRY

		BEGIN TRANSACTION

				IF @ConfDayReservationID is null
				THROW 2500, 'ConfDayReservationID cant be null!', 1

				UPDATE ConfDayReservations
					SET Cancelled = 1
				WHERE ConfDayReservationID = @ConfDayReservationID

				--tutaj wszystkie rezerwacje na warszaty w danym dniu zostana anulowane
				--a na dodatek usuniete wszystkie rejestracje na warsztaty w danym dniu

				EXEC CancelClientWorkshopReservations @ConfDayReservationID;

				DELETE FROM ConfDayRegistrations
				WHERE ConfDayReservationID = @ConfDayReservationID

		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH

		ROLLBACK TRANSACTION
		THROW

	END CATCH

END
GO

IF OBJECT_ID ('CancelParticipantWorkshopRegistration') is not null
DROP PROC CancelParticipantWorkshopRegistration;
GO


CREATE PROCEDURE CancelParticipantWorkshopRegistration (
	@ParticipantID int,
	@WorkshopRegID int
)

AS BEGIN

	SET NOCOUNT ON
	BEGIN TRY 
		BEGIN TRANSACTION 

					IF @ParticipantID is null
						THROW 2500, 'ParticipantID cant be null!', 1

					DELETE b From WorkshopRegistrations b
					WHERE @ParticipantID = b.ParticipantID and b.WorkshopRegID = @WorkshopRegID

					 
		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH
END 

GO

IF OBJECT_ID ('CancelParticipantWorkshopRegistrations') is not null
DROP PROC CancelParticipantWorkshopRegistrations;
GO


CREATE PROCEDURE CancelParticipantWorkshopRegistrations (
	@ParticipantID int
)

AS BEGIN

	SET NOCOUNT ON
	BEGIN TRY 
		BEGIN TRANSACTION 

					IF @ParticipantID is null
						THROW 2500, 'ParticipantID cant be null!', 1


					DELETE b From WorkshopRegistrations b
					where b.ParticipantID = @ParticipantID
		
		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH
END 

GO


IF OBJECT_ID ('ModifyClient') is not null
DROP PROC ModifyClient;
GO


CREATE PROCEDURE ModifyClient (
	@ClientID int,
	@CompanyID int,
	@Login nvarchar (20) ,
	@Password nvarchar (255),
	@Mail nvarchar (60)	
)

AS BEGIN
	SET NOCOUNT ON

		BEGIN TRY
			BEGIN TRANSACTION

				IF @ClientID is null 
				THROW 2500,'ClientID cant be null!', 1

				IF @Login is null 
				THROW 2500, 'Login cant be null!', 1

				IF @Password is null
				THROW 2500, 'Password cant be null!', 1

				IF @Mail is null
				THROW 2500, 'Mail cant be null!', 1

				UPDATE Clients
				SET
					CompanyID = @CompanyID,
					Login = @Login,
					Password = @Password,
					Mail = @Mail
				WHERE ClientID = @ClientID 

				IF @@ROWCOUNT = 0
					THROW 2500, 'You provided incorrect ClientID, Client with such ID doesnt exist!', 1

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			THROW
		END CATCH
END

GO


IF OBJECT_ID ('ModifyCompany') is not null
DROP PROC ModifyCompany;
GO

CREATE PROCEDURE ModifyCompany (
	@CompanyID int,
	@CompanyName nvarchar (20),
	@AdressID int
)

AS BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY
		BEGIN TRANSACTION

			IF @CompanyID is null
			THROW 2500, 'CompanyID cant be null!',1 

			IF @CompanyName is null 
			THROW 2500, 'CompanyName cant be null!',1

			IF @AdressID is null 
			THROW 2500, 'AdressID cant be null!',1

			UPDATE Companies
			SET
				CompanyName = @CompanyName,
				AdressID = @AdressID

			WHERE CompanyID = @CompanyID

			IF @@ROWCOUNT = 0 
				THROW 2500, 'You provided incorrect CompanyID, Company with such ID doesnt exist!', 1

		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END

GO


IF OBJECT_ID ('ModifyConferances') is not null
DROP PROC ModifyConferances;
GO

CREATE PROCEDURE ModifyConferances (
	@ConferenceID int,
	@Name varchar (50),
	@AdressID int,
	@StudentDiscount int
)

AS BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		BEGIN TRANSACTION

			IF @ConferenceID is null
			THROW 2500, 'ConferenceID cant be null!', 1

			IF @Name is null
			THROW 2500, 'Name cant be null!', 1

			IF @AdressID is null
			THROW 2500, 'AdressID cant be null!', 1

			UPDATE Conference
			SET 
				Name = @Name,
				AdressID = @AdressID,
				StudentDiscount = @StudentDiscount
			WHERE ConferenceID = @ConferenceID

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		THROW
	END CATCH

END

GO


IF OBJECT_ID ('ModifyParticipant') is not null
DROP PROC ModifyParticipant;
GO

CREATE PROCEDURE ModifyParticipant (
	@ParticipantID int,
	@FirstName nvarchar (20),
	@LastName nvarchar (20),
	@AdressID int,
	@StudentCardID int
)

AS BEGIN
	SET NOCOUNT ON

		BEGIN TRY
			BEGIN TRANSACTION

				IF @ParticipantID is null
					THROW 2500, 'ParticipantID cant be null', 1

				IF @FirstName is null
					THROW 2500, 'FirstName cant be null', 1

				IF @LastName is null
					THROW 2500, 'LastName cant be null', 1

				IF @AdressID is null
					THROW 2500, 'AdressID cant be null', 1

				IF @StudentCardID is null
					THROW 2500, 'StudentCardID cant be null', 1

				UPDATE Participants
				SET

					FirstName = @FirstName,
					LastName = @LastName,
					AdressID = @AdressID,
					StudentCardID = @StudentCardID
				WHERE ParticipantID = @ParticipantID

				IF @@ROWCOUNT = 0
					THROW 2500, 'You provided incorrect ParticipantID, Participant with such ID doesnt exist!', 1

				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION
			THROW
		END CATCH

END

GO

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

