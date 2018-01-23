-- Rejestracje na warsztaty
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
DROP FUNCTION WorshopFreeSeats;
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

IF OBJECT_ID('f_PriceToPay') is not null
DROP FUNCTION f_PriceToPay;
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

IF OBJECT_ID('f_PriceToPayPerDay') is not null
DROP FUNCTION f_PriceToPayPerDay;
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
                where CDRv.ClientID = @ClientID and ConfDayReservationID = @ConfDayReservationID and CDRv.Cancelled = 0)
                )
            END
            ELSE
                RETURN ( @toPayWorkshop + 
                (Select SUM ((1-@Discount)*CD.Price*((NumSeats-CDRv.NumStudents) +(CDRv.NumStudents)*(1-(StudentDiscount)))*(1-CDRv.Cancelled))  
                 from ConfDayReservations as CDRv 
                inner join ConferenceDays as CD on CDRv.ConfDayID = CD.ConfDayID
                where CDRv.ClientID = @ClientID and ConfDayReservationID = @ConfDayReservationID and CDRv.Cancelled = 0)
                )
            RETURN 0.0
        END
GO

IF OBJECT_ID('f_ConfDayParticipants') is not null
DROP FUNCTION f_ConfDayParticipants;
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


IF OBJECT_ID('f_WorkshopParticipants') is not null
DROP FUNCTION f_WorkshopParticipants;
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

