﻿-- Rejestracje na warsztaty
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'WorkshopRegistrations')
    DROP TABLE WorkshopRegistrations
GO

-- Rejestracje dnia konferencji
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'ConfDayRegistrations')
    DROP TABLE ConfDayRegistrations
GO

-- Uczestnicy
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'Participants')
    DROP TABLE Participants
GO


-- Rezerwacje na warsztaty
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'WorkshopReservations')
    DROP TABLE WorkshopReservations
GO


-- Warsztaty
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'Workshops')
    DROP TABLE Workshops
GO


-- Rezerwacje dnia konferencji
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'ConfDayReservations')
    DROP TABLE ConfDayReservations
GO

-- Zniżki
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'Discounts')
    DROP TABLE Discounts
GO


-- Dni Konferencji
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'ConferenceDays')
    DROP TABLE ConferenceDays
GO


-- Klienci
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'Clients')
    DROP TABLE Clients
GO


-- Firmy
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'Companies')
    DROP TABLE Companies
GO


-- Konferencje
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'Conference')
    DROP TABLE Conference
GO


--  Adresy
IF EXISTS (SELECT name FROM sysobjects
            WHERE type = 'U' AND name = 'Adresses')
    DROP TABLE Adresses
GO



CREATE TABLE Adresses (
    AdressID int IDENTITY(1,1) NOT NULL UNIQUE,
    Country nvarchar(15)  NOT NULL,
    PostalCode nvarchar(6)  NOT NULL,
    City nvarchar(20)  NOT NULL,
    FstLine nvarchar(40)  NOT NULL,
    ScdLine nvarchar(40)  NOT NULL,
    CONSTRAINT Adresses_pk PRIMARY KEY  (AdressID),
    CONSTRAINT PostalCode_clength_check CHECK (len(PostalCode) BETWEEN 1 AND 8)
);

CREATE INDEX AdressID on Adresses (AdressID ASC)
;


CREATE TABLE Clients (
    ClientID int IDENTITY(1,1) NOT NULL UNIQUE,
    CompanyID int NULL UNIQUE,
    Login nvarchar(10)  NOT NULL UNIQUE,
    Password nvarchar(255)  NOT NULL,
    Mail varchar(60)  NOT NULL UNIQUE,
    CONSTRAINT Clients_pk PRIMARY KEY  (ClientID),
    CONSTRAINT Client_mail_format_check CHECK (Mail like '%_@_%_._%'),
);

CREATE INDEX ClientID on Clients (ClientID ASC,CompanyID ASC)
;

CREATE TABLE Companies (
    CompanyID int IDENTITY(1,1) NOT NULL UNIQUE,
    CompanyName nvarchar(40)  NOT NULL,
    AdressID int  NOT NULL,
    NIP nvarchar(13)  NOT NULL UNIQUE,
    CONSTRAINT Companies_pk PRIMARY KEY CLUSTERED (CompanyID ASC),
    CONSTRAINT NIP_format_check CHECK (NIP like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')
);

CREATE INDEX Companies_idx_1 on Companies (CompanyID ASC)
;


CREATE TABLE ConfDayRegistrations (
    ConfDayRegistrationID int IDENTITY(1,1) NOT NULL UNIQUE,
    ParticipantID int  NOT NULL,
    ConfDayReservationID int  NOT NULL,
    CONSTRAINT ConfDayRegistrations_pk PRIMARY KEY  (ConfDayRegistrationID),
    CONSTRAINT Participant_ConfDayReservationID_unique UNIQUE (ConfDayReservationID, ParticipantID)
);

CREATE INDEX ConfDayRegistrations_idx_1 on ConfDayRegistrations (ConfDayRegistrationID ASC)
;


CREATE TABLE ConfDayReservations (
    ConfDayReservationID int IDENTITY(1,1) NOT NULL UNIQUE,
    ClientID int  NOT NULL,
    ConfDayID int  NOT NULL,
    NumSeats int  NOT NULL,
    ReservationDate datetime  NOT NULL,
    PaidPrice float  NOT NULL DEFAULT 0,
    NumStudents int  NOT NULL DEFAULT 0,
    Cancelled bit default 0, 
    CONSTRAINT ConfDayReservations_pk PRIMARY KEY  (ConfDayReservationID),
    CONSTRAINT NumSeats_num_ckeck CHECK (NumSeats>0),
    CONSTRAINT NumStudents_not_more_then_NumSeats_check CHECK (NumStudents<=NumSeats)
);

CREATE INDEX ConfDayReservations_idx_1 on ConfDayReservations (ConfDayReservationID ASC)
;


CREATE TABLE Conference (
    ConferenceID int IDENTITY(1,1)  NOT NULL UNIQUE,
    Name varchar(50)  NOT NULL,
    AdressID int  NOT NULL,
    StudentDiscount float NOT NULL DEFAULT 0,
    CONSTRAINT Conference_pk PRIMARY KEY  (ConferenceID)
);

CREATE INDEX ConferenceID on Conference (ConferenceID ASC)
;

CREATE TABLE ConferenceDays (
    ConfDayID int  IDENTITY(1,1) NOT NULL UNIQUE,
    ConfID int  NOT NULL,
    Date date  NOT NULL,
    Price float  NOT NULL,
    SeatsNum int  NOT NULL,
    CONSTRAINT ConferenceDays_pk PRIMARY KEY  (ConfDayID),
    CONSTRAINT SeatsNum_not_zero CHECK (SeatsNum>0)
);

CREATE INDEX ConferenceDays_idx_1 on ConferenceDays (ConfDayID ASC)
;


CREATE TABLE Discounts (
    DiscountID int  IDENTITY(1,1) NOT NULL UNIQUE,
    ConfDayID int  NOT NULL,
    DiscountStartDate date  NOT NULL,
    DiscountEndDate date  NOT NULL,
    Discount float  NOT NULL DEFAULT 0,
    CONSTRAINT Discounts_pk PRIMARY KEY  (DiscountID),
    CONSTRAINT Start_End_Discount_Date_check CHECK (DiscountStartDate<DiscountEndDate),
    CONSTRAINT Discount_format_check CHECK (Discount between 0 and 1)
);

CREATE INDEX Discounts_idx_1 on Discounts (DiscountID ASC)
;


CREATE TABLE Participants (
    ParticipantID int IDENTITY(1,1) NOT NULL UNIQUE,
    ClientID int  NOT NULL,
    FirstName nvarchar(20)  NOT NULL DEFAULT 'Kamil',
    LastName nvarchar(20)  NOT NULL DEFAULT 'Sokolowski',
    AdressID int  NOT NULL,
    StudentCardID int  NULL UNIQUE DEFAULT 0,
    CONSTRAINT Participants_pk PRIMARY KEY (ParticipantID),
    CONSTRAINT FirstName_Format CHECK (FirstName NOT LIKE '%[^a-zA-Z,.\-\ ]%'),
    CONSTRAINT LastName_Format CHECK (LastName NOT LIKE '%[^a-zA-Z,.\-\ ]%')
);

CREATE INDEX Participants_idx_1 on Participants (ParticipantID ASC)
;



CREATE TABLE WorkshopRegistrations (
    WorkshopRegID int IDENTITY(1,1)  NOT NULL UNIQUE,
    WorkshopReservID int  NOT NULL,
    ParticipantID int  NOT NULL,
    ConfDayRegistrationID int  NOT NULL,
    CONSTRAINT WorkshopRegistrations_pk PRIMARY KEY  (WorkshopRegID)
);

CREATE INDEX WorkshopRegistrations_idx_1 on WorkshopRegistrations (WorkshopRegID ASC)
;


CREATE TABLE WorkshopReservations (
    WorkshopReservID int IDENTITY(1,1) NOT NULL UNIQUE,
    WorkshopID int  NOT NULL,
    ConfDayReservationID int  NOT NULL,
    NumReservs int  NOT NULL,
    ReservationDate datetime  NOT NULL,
    NumStudents int  NOT NULL DEFAULT 0,
    Cancelled bit default 0, 
    CONSTRAINT WorkshopReservations_pk PRIMARY KEY  (WorkshopReservID),
    CONSTRAINT NumReservs_check CHECK (NumReservs > 0),
    CONSTRAINT NumSrudent_not_greater_then_Reservs_ckeck CHECK (NumStudents <= NumReservs)
);

CREATE INDEX WorkshopReservations_idx_1 on WorkshopReservations (WorkshopReservID ASC)
;

CREATE TABLE Workshops (
    WorkshopID int  IDENTITY(1,1) NOT NULL UNIQUE,
    ConfDayID int  NOT NULL,
    Name nvarchar(40)  NOT NULL,
    Seats int  NOT NULL,
    StartTime datetime  NOT NULL,
    EndTime datetime  NOT NULL,
    Price float  NOT NULL,
    CONSTRAINT Workshops_pk PRIMARY KEY  (WorkshopID),
    CONSTRAINT Start_End_time_check CHECK (StartTime<EndTime)
);

CREATE INDEX Workshops_idx_1 on Workshops (WorkshopID ASC)
;

-- foreign keys
-- Reference: Clients_Companies (table: Clients)
ALTER TABLE Clients ADD CONSTRAINT Clients_Companies
    FOREIGN KEY (CompanyID)
    REFERENCES Companies (CompanyID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: Companies_Adresses (table: Companies)
ALTER TABLE Companies ADD CONSTRAINT Companies_Adresses
    FOREIGN KEY (AdressID)
    REFERENCES Adresses (AdressID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: ConfDayRegistration_Participants (table: ConfDayRegistrations)
ALTER TABLE ConfDayRegistrations ADD CONSTRAINT ConfDayRegistration_Participants
    FOREIGN KEY (ParticipantID)
    REFERENCES Participants (ParticipantID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: ConfDayReservation_Clients (table: ConfDayReservations)
ALTER TABLE ConfDayReservations ADD CONSTRAINT ConfDayReservation_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: ConfDayReservation_ConfDayRegistration (table: ConfDayRegistrations)
ALTER TABLE ConfDayRegistrations ADD CONSTRAINT ConfDayReservation_ConfDayRegistration
    FOREIGN KEY (ConfDayReservationID)
    REFERENCES ConfDayReservations (ConfDayReservationID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: ConfDayReservation_ConferenceDays (table: ConfDayReservations)
ALTER TABLE ConfDayReservations ADD CONSTRAINT ConfDayReservation_ConferenceDays
    FOREIGN KEY (ConfDayID)
    REFERENCES ConferenceDays (ConfDayID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: Conference_Adresses (table: Conference)
ALTER TABLE Conference ADD CONSTRAINT Conference_Adresses
    FOREIGN KEY (AdressID)
    REFERENCES Adresses (AdressID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: Discounts_ConferenceDays (table: Discounts)
ALTER TABLE Discounts ADD CONSTRAINT Discounts_ConferenceDays
    FOREIGN KEY (ConfDayID)
    REFERENCES ConferenceDays (ConfDayID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: Konferencje_Dni_Konferencje (table: ConferenceDays)
ALTER TABLE ConferenceDays ADD CONSTRAINT Konferencje_Dni_Konferencje
    FOREIGN KEY (ConfID)
    REFERENCES Conference (ConferenceID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: Participants_Adresses (table: Participants)
ALTER TABLE Participants ADD CONSTRAINT Participants_Adresses
    FOREIGN KEY (AdressID)
    REFERENCES Adresses (AdressID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: Participants_Clients (table: Participants)
ALTER TABLE Participants ADD CONSTRAINT Participants_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: WorkshopRegistrations_ConfDayRegistrations (table: WorkshopRegistrations)
ALTER TABLE WorkshopRegistrations ADD CONSTRAINT WorkshopRegistrations_ConfDayRegistrations
    FOREIGN KEY (ConfDayRegistrationID)
    REFERENCES ConfDayRegistrations (ConfDayRegistrationID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: WorkshopRegistrations_Participants (table: WorkshopRegistrations)
ALTER TABLE WorkshopRegistrations ADD CONSTRAINT WorkshopRegistrations_Participants
    FOREIGN KEY (ParticipantID)
    REFERENCES Participants (ParticipantID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: WorkshopRegistrations_WorkshopReservations (table: WorkshopRegistrations)
ALTER TABLE WorkshopRegistrations ADD CONSTRAINT WorkshopRegistrations_WorkshopReservations
    FOREIGN KEY (WorkshopReservID)
    REFERENCES WorkshopReservations (WorkshopReservID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: WorkshopReservations_ConfDayReservations (table: WorkshopReservations)
ALTER TABLE WorkshopReservations ADD CONSTRAINT WorkshopReservations_ConfDayReservations
    FOREIGN KEY (ConfDayReservationID)
    REFERENCES ConfDayReservations (ConfDayReservationID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: WorkshopReservations_Workshops (table: WorkshopReservations)
ALTER TABLE WorkshopReservations ADD CONSTRAINT WorkshopReservations_Workshops
    FOREIGN KEY (WorkshopID)
    REFERENCES Workshops (WorkshopID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- Reference: Workshops_ConferenceDays (table: Workshops)
ALTER TABLE Workshops ADD CONSTRAINT Workshops_ConferenceDays
    FOREIGN KEY (ConfDayID)
    REFERENCES ConferenceDays (ConfDayID)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

IF OBJECT_ID('WorkshopFreeSeats') is not null
DROP FUNCTION WorkshopFreeSeats;
GO

IF OBJECT_ID('ConfDayFreeSeats') is not null
DROP FUNCTION ConfDayFreeSeats;
GO 

IF OBJECT_ID('ConfDayReservationFreeSeats') is not null
DROP FUNCTION ConfDayReservationFreeSeats;
GO

IF OBJECT_ID('WorkshopReservationFreeSeats') is not null
DROP FUNCTION WorkshopReservationFreeSeats;
GO 

IF OBJECT_ID('f_PriceToPay') is not null
DROP FUNCTION f_PriceToPay;
GO

IF OBJECT_ID('f_PriceToPayPerDay') is not null
DROP FUNCTION f_PriceToPayPerDay;
GO

IF OBJECT_ID('f_ConfDayParticipants') is not null
DROP FUNCTION f_ConfDayParticipants;
GO


IF OBJECT_ID('f_WorkshopParticipants') is not null
DROP FUNCTION f_WorkshopParticipants;
GO






CREATE FUNCTION ConfDayFreeSeats(@CDayID int)
        RETURNS int
        AS
        BEGIN
            DECLARE @Seats AS int 
            SET @Seats = ( 
                SELECT SeatsNum
                FROM ConferenceDays
                WHERE ConfDayID = @CDayID
            )
            
            DECLARE @Taken AS int 
            SET @Taken = (
                SELECT SUM( NumSeats)
                FROM ConfDayReservations
                WHERE ConfDayID = @CDayID and Cancelled = 0
            )
            IF @Taken is null 
            BEGIN
                SET @Taken = 0
            END 
            RETURN (@Seats - @Taken)
        END
GO

CREATE FUNCTION WorkshopFreeSeats(@WorkshopID int)
        RETURNS int
        AS 
        BEGIN
            DECLARE @Seats AS int 
            SET @Seats = (
                SELECT Seats
                FROM Workshops
                WHERE WorkshopID = @WorkshopID
            )

            DECLARE @Taken AS int 
            SET @Taken = (
                SELECT SUM(NumReservs)
                FROM WorkshopReservations
                WHERE WorkshopID = @WorkshopID and Cancelled = 0
            )
            IF @Taken is null
            BEGIN 
                SET @Taken = 0
            END 
            RETURN (@Seats - @Taken)
        END
GO

CREATE FUNCTION ConfDayReservationFreeSeats(@ReservationID int)
        RETURNS int
        AS 
        BEGIN
            DECLARE @Seats AS int
            SET @Seats = (
                SELECT NumSeats
                FROM ConfDayReservations
                WHERE ConfDayReservationID = @ReservationID 
            )

            DECLARE @Taken AS int 
            SET @Taken = (
                SELECT COUNT(*)
                FROM ConfDayRegistrations
                WHERE ConfDayReservationID = @ReservationID
            )
            IF @Taken is null
            BEGIN 
                SET @Taken = 0 
            END 
            RETURN (@Seats - @Taken)
        END
GO 

CREATE FUNCTION WorkshopReservationFreeSeats(@ReservationID int)
        RETURNS int
        AS 
        BEGIN
            DECLARE @Seats AS int 
            SET @Seats = (
                SELECT NumReservs
                FROM WorkshopReservations
                WHERE WorkshopReservID = @ReservationID 
            )

            DECLARE @Taken AS int
            SET @Taken = (
                SELECT COUNT(*)
                FROM WorkshopRegistrations
                WHERE WorkshopReservID = @ReservationID
            )
            IF @Taken is null
            BEGIN
                SET @Taken = 0 
            END 
            RETURN (@Seats - @Taken)
        END
GO


CREATE FUNCTION f_PriceToPayPerDay(@ClientID int, @ConfDayReservationID int)
        RETURNS float
        AS
        BEGIN
            
            Declare @toPayWorkshop float = 
            (Select SUM (Ws.Price*((NumSeats-CDRv.NumStudents) +(CDRv.NumStudents)*(1-(StudentDiscount)))*(1-WR.Cancelled))  
             from ConfDayReservations as CDRv 
            inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
            inner join Workshops as Ws on Ws.ConfDayID = CD.ConfDayID
            inner join WorkshopReservations as WR on WR.ConfDayReservationID = CDRv.ConfDayReservationID
            inner join Conference on Conference.ConferenceID = CD.ConfID
            where CDRv.ClientID = @ClientID and CDRv.Cancelled = 0 and WR.Cancelled = 0)


            Declare @Discount float = (select Ds.Discount from  ConfDayReservations as CDRv 
            inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
            inner join Discounts as Ds on CD.Date between Ds.DiscountStartDate and Ds.DiscountEndDate
            where CDRv.ConfDayReservationID = @ConfDayReservationID) 

            IF @Discount IS NULL
            BEGIN 

                RETURN ( @toPayWorkshop +
                (Select SUM (CD.Price*((NumSeats-CDRv.NumStudents) +(CDRv.NumStudents)*(1-(StudentDiscount)))*(1-CDRv.Cancelled))  
                 from ConfDayReservations as CDRv 
                inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
                inner join Conference on Conference.ConferenceID = CD.ConfID
                where CDRv.ClientID = @ClientID and ConfDayReservationID = @ConfDayReservationID and CDRv.Cancelled = 0)
                )
            END
            ELSE
                RETURN ( @toPayWorkshop + 
                (Select SUM ((1-@Discount)*CD.Price*((NumSeats-CDRv.NumStudents) +(CDRv.NumStudents)*(1-(StudentDiscount)))*(1-CDRv.Cancelled))  
                 from ConfDayReservations as CDRv 
                inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
                inner join Conference on Conference.ConferenceID = CD.ConfID
                where CDRv.ClientID = @ClientID and ConfDayReservationID = @ConfDayReservationID and CDRv.Cancelled = 0)
                )
            RETURN 0.0
        END
GO




CREATE FUNCTION f_PriceToPay(@ClientID int)
        RETURNS float
        AS
        BEGIN
            
            DECLARE @ToPay float = (select Sum(dbo.f_PriceToPayPerDay(@ClientID, ConfDayReservations.ConfDayReservationID))
            from ConfDayReservations where ConfDayReservations.ClientID=@ClientID AND ConfDayReservations.Cancelled=0)

            RETURN (@toPay)
        END
GO


CREATE FUNCTION f_ConfDayParticipants (@ConfDayID int)
        RETURNS TABLE
        AS
        
            RETURN (SELECT dbo.Participants.FirstName, dbo.Participants.LastName, dbo.Participants.StudentCardID as 'StudentCard ID'
                    FROM dbo.ConferenceDays
                    INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ConfDayID = ConferenceDays.ConfDayID
                    INNER JOIN dbo.ConfDayRegistrations ON ConfDayRegistrations.ConfDayReservationID = ConfDayReservations.ConfDayReservationID
                    INNER JOIN dbo.Participants ON Participants.ParticipantID = ConfDayRegistrations.ParticipantID
                    WHERE ConferenceDays.ConfDayID = @ConfDayID)
GO




CREATE FUNCTION f_WorkshopParticipants (@WorkshopID int)
        RETURNS TABLE
        AS
        
            RETURN (SELECT dbo.Participants.FirstName, dbo.Participants.LastName, dbo.Participants.StudentCardID as 'StudentCard ID'
                    FROM dbo.Workshops
                    INNER JOIN dbo.WorkshopReservations ON WorkshopReservations.WorkshopID = Workshops.WorkshopID
                    inner JOIN dbo.WorkshopRegistrations ON WorkshopRegistrations.WorkshopReservID = WorkshopReservations.WorkshopReservID
                    INNER JOIN dbo.Participants ON Participants.ParticipantID = WorkshopRegistrations.ParticipantID
                    WHERE Workshops.WorkshopID = @WorkshopID)
GO

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
    @ConferenceID int = NULL OUT,
    @StudentDiscount float = 0
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION

        
        IF @AdressID IS NULL
            THROW 14,'Musisz podac adres', 1
        
        IF @Name IS NULL
            THROW 14, 'Musisz podac nazwe konferencji', 1
        IF @StudentDiscount IS NULL
            THROW 14, 'Musisz podac znizke studencka!', 1


        INSERT Conference (Name, AdressID,StudentDiscount)
        VALUES (@Name, @AdressID,@StudentDiscount)
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
            
        INSERT ConferenceDays (ConfID, Date, Price, SeatsNum) 
        VALUES (@ConfDayID, @Date, @Price, @SeatNums)
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
        

    --  Declare @ClientID int = (Select TOP 1 ClientID from Participants where Participants.ParticipantID=@ParticipantID)

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
GO

IF OBJECT_ID('v_ClientConfDayReservationCount') is not null
DROP VIEW v_ClientConfDayReservationCount;
GO


IF OBJECT_ID('v_MostActiveClients') is not null
DROP VIEW v_MostActiveClients;
GO

IF OBJECT_ID('v_CompanyToAddParticipants') is not null
DROP VIEW v_CompanyToAddParticipants;
GO

IF OBJECT_ID('v_ClientPayments') is not null
DROP VIEW v_ClientPayments;
GO

IF OBJECT_ID('v_ClientsWhoDidntPay') is not null
DROP VIEW v_ClientsWhoDidntPay;
GO

CREATE VIEW v_ClientConfDayReservationCount
        AS
        SELECT CD.ConfDayID AS 'ConfDayID' , C.ClientID AS 'ClientID', COUNT(*) AS 'Number of reservations'
         from ConfDayReservations as CDRv
        INNER JOIN ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
        INNER JOIN dbo.Clients AS C ON CDRv.ClientID = C.ClientID
        GROUP BY C.ClientID, CD.ConfDayID 
GO



CREATE VIEW v_ClientPayments
        AS
        SELECT Login,  ISNULL(CompanyName, 'Private person') AS 'Company name', SUM(PaidPrice) AS 'Paid price' FROM 
        dbo.Clients 
        INNER JOIN dbo.ConfDayReservations ON Clients.ClientID = ConfDayReservations.ClientID
        LEFT OUTER JOIN dbo.Companies ON Companies.CompanyID=Clients.CompanyID
        GROUP BY Login, CompanyName
GO



CREATE VIEW v_ClientsWhoDidntPay
        AS
        SELECT Login AS 'Login', ISNULL(CompanyName, 'Personal client') AS 'Company',  dbo.f_PriceToPayPerDay(Clients.ClientID, ConfDayReservationID) - PaidPrice AS 'Price to pay'
        FROM dbo.Clients
        INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ClientID = Clients.ClientID
        LEFT OUTER JOIN dbo.Companies ON Companies.CompanyID = Clients.CompanyID
        WHERE dbo.f_PriceToPayPerDay(Clients.ClientID, ConfDayReservationID) >PaidPrice AND 
        DATEDIFF(DAY, ReservationDate,  GETDATE()) > 7
        AND Cancelled = 1
GO



CREATE VIEW v_CompanyToAddParticipants
        AS
        SELECT CompanyName AS 'Company', Mail AS 'mail', DATEDIFF(DAY,  GETDATE(), dbo.ConferenceDays.Date) AS 'Days before conferention' FROM dbo.Companies
        INNER JOIN dbo.Clients ON Clients.CompanyID = Companies.CompanyID
        INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ClientID = Clients.ClientID
        INNER JOIN dbo.ConferenceDays ON ConferenceDays.ConfDayID = ConfDayReservations.ConfDayID
        INNER JOIN dbo.Conference ON Conference.ConferenceID = ConferenceDays.ConfID
        WHERE dbo.ConfDayReservationFreeSeats(ConfDayReservationID)>0 
        AND DATEDIFF(DAY,  GETDATE(), dbo.ConferenceDays.Date) BETWEEN 0 AND 14
GO


CREATE VIEW v_MostActiveClients
        AS
        SELECT Clients.ClientID AS 'ClientID', Login AS 'Login', COUNT(*)  AS 'Number of Reservations' FROM dbo.Clients
        INNER JOIN dbo.ConfDayReservations ON ConfDayReservations.ClientID = Clients.ClientID
        GROUP BY Clients.ClientID, Login

GO

IF OBJECT_ID ('ConferenceRegistrationsValidate') is not null
DROP TRIGGER ConferenceRegistrationsValidate;
GO

IF OBJECT_ID ('WorkshopsRegistrationValidate') is not null
DROP TRIGGER WorkshopsRegistrationValidate;
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

            IF dbo.ConfDayReservationFreeSeats(@ConfDayReservationID) <= 0
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


ALTER TABLE ConfDayRegistrations ENABLE TRIGGER ConferenceRegistrationsValidate

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