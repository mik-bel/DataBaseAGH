-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2018-01-07 22:08:09.77

-- tables
-- Table: Adresses
CREATE TABLE Adresses (
    AdressID int  NOT NULL,
    Country nvarchar(15)  NOT NULL,
    PostalCode nvarchar(6)  NOT NULL,
    City nvarchar(20)  NOT NULL,
    FstLine nvarchar(40)  NOT NULL,
    ScdLine nvarchar(40)  NOT NULL,
    CONSTRAINT Adresses_pk PRIMARY KEY  (AdressID)
);

CREATE INDEX AdressID on Adresses (AdressID ASC)
;

-- Table: Clients
CREATE TABLE Clients (
    ClientID int  NOT NULL,
    CompanyID int  NULL,
    Login nchar(10)  NOT NULL,
    Password nvarchar(255)  NOT NULL,
    Mail varchar(60)  NOT NULL,
    CONSTRAINT Clients_pk PRIMARY KEY  (ClientID)
);

CREATE INDEX ClientID on Clients (ClientID ASC,CompanyID ASC)
;

-- Table: Companies
CREATE TABLE Companies (
    CompanyID int  NOT NULL,
    CompanyName nvarchar(20)  NOT NULL,
    AdressID int  NOT NULL,
    NIP nvarchar(30)  NOT NULL,
    CONSTRAINT Companies_pk PRIMARY KEY  (CompanyID)
);

CREATE INDEX Companies_idx_1 on Companies (CompanyID ASC)
;

-- Table: ConfDayRegistrations
CREATE TABLE ConfDayRegistrations (
    ConfDayRegistrationID int  NOT NULL,
    ParticipantID int  NOT NULL,
    ConfDayReservationID int  NOT NULL,
    CONSTRAINT ConfDayRegistrations_pk PRIMARY KEY  (ConfDayRegistrationID)
);

CREATE INDEX ConfDayRegistrations_idx_1 on ConfDayRegistrations (ConfDayRegistrationID ASC)
;

-- Table: ConfDayReservations
CREATE TABLE ConfDayReservations (
    ConfDayReservationID int  NOT NULL,
    ClientID int  NOT NULL,
    ConfDayID int  NOT NULL,
    NumSeats int  NOT NULL,
    ReservationDate date  NOT NULL,
    PaidPrice float  NOT NULL,
    NumStudents int  NOT NULL,
    CONSTRAINT ConfDayReservations_pk PRIMARY KEY  (ConfDayReservationID)
);

CREATE INDEX ConfDayReservations_idx_1 on ConfDayReservations (ConfDayReservationID ASC)
;

-- Table: Conference
CREATE TABLE Conference (
    ID_Conference int  NOT NULL,
    Name varchar(50)  NOT NULL,
    AdressID int  NOT NULL,
    CONSTRAINT Conference_pk PRIMARY KEY  (ID_Conference)
);

CREATE INDEX ID_Conference on Conference (ID_Conference ASC)
;

-- Table: ConferenceDays
CREATE TABLE ConferenceDays (
    ConfDayID int  NOT NULL,
    ConfID int  NOT NULL,
    Date date  NOT NULL,
    Price float  NOT NULL,
    SeatsNum int  NOT NULL,
    CONSTRAINT ConferenceDays_pk PRIMARY KEY  (ConfDayID)
);

CREATE INDEX ConferenceDays_idx_1 on ConferenceDays (ConfDayID ASC)
;

-- Table: Discounts
CREATE TABLE Discounts (
    DiscountID int  NOT NULL,
    ConfDayID int  NOT NULL,
    DiscountStartDate date  NOT NULL,
    DiscountEndDate date  NOT NULL,
    Discount float  NOT NULL,
    CONSTRAINT Discounts_pk PRIMARY KEY  (DiscountID)
);

CREATE INDEX Discounts_idx_1 on Discounts (DiscountID ASC)
;

-- Table: Participants
CREATE TABLE Participants (
    ParticipantID int  NOT NULL,
    ClientID int  NOT NULL,
    FirstName nvarchar(20)  NOT NULL,
    LastName nvarchar(20)  NOT NULL,
    AdressID int  NOT NULL,
    StudentCardID int  NULL,
    CONSTRAINT Participants_pk PRIMARY KEY  (ParticipantID)
);

CREATE INDEX Participants_idx_1 on Participants (ParticipantID ASC)
;

-- Table: WorkshopRegistrations
CREATE TABLE WorkshopRegistrations (
    WorkshopRegID int  NOT NULL,
    WorkshopReservID int  NOT NULL,
    ParticipantID int  NOT NULL,
    ConfDayRegistrationID int  NOT NULL,
    CONSTRAINT WorkshopRegistrations_pk PRIMARY KEY  (WorkshopRegID)
);

CREATE INDEX WorkshopRegistrations_idx_1 on WorkshopRegistrations (WorkshopRegID ASC)
;

-- Table: WorkshopReservations
CREATE TABLE WorkshopReservations (
    WorkshopReservID int  NOT NULL,
    WorkshopID int  NOT NULL,
    ConfDayReservationID int  NOT NULL,
    NumReservs int  NOT NULL,
    ReservationDate date  NOT NULL,
    NumStudents int  NOT NULL,
    CONSTRAINT WorkshopReservations_pk PRIMARY KEY  (WorkshopReservID)
);

CREATE INDEX WorkshopReservations_idx_1 on WorkshopReservations (WorkshopReservID ASC)
;

-- Table: Workshops
CREATE TABLE Workshops (
    WorkshopID int  NOT NULL,
    ConfDayID int  NOT NULL,
    Name nvarchar(40)  NOT NULL,
    Seats int  NOT NULL,
    StartTime time  NOT NULL,
    EndTime time  NOT NULL,
    Price float  NOT NULL,
    CONSTRAINT Workshops_pk PRIMARY KEY  (WorkshopID)
);

CREATE INDEX Workshops_idx_1 on Workshops (WorkshopID ASC)
;

-- foreign keys
-- Reference: Clients_Companies (table: Clients)
ALTER TABLE Clients ADD CONSTRAINT Clients_Companies
    FOREIGN KEY (CompanyID)
    REFERENCES Companies (CompanyID)
    ON UPDATE  CASCADE;

-- Reference: Companies_Adresses (table: Companies)
ALTER TABLE Companies ADD CONSTRAINT Companies_Adresses
    FOREIGN KEY (AdressID)
    REFERENCES Adresses (AdressID);

-- Reference: ConfDayRegistration_Participants (table: ConfDayRegistrations)
ALTER TABLE ConfDayRegistrations ADD CONSTRAINT ConfDayRegistration_Participants
    FOREIGN KEY (ParticipantID)
    REFERENCES Participants (ParticipantID);

-- Reference: ConfDayReservation_Clients (table: ConfDayReservations)
ALTER TABLE ConfDayReservations ADD CONSTRAINT ConfDayReservation_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: ConfDayReservation_ConfDayRegistration (table: ConfDayRegistrations)
ALTER TABLE ConfDayRegistrations ADD CONSTRAINT ConfDayReservation_ConfDayRegistration
    FOREIGN KEY (ConfDayReservationID)
    REFERENCES ConfDayReservations (ConfDayReservationID);

-- Reference: ConfDayReservation_ConferenceDays (table: ConfDayReservations)
ALTER TABLE ConfDayReservations ADD CONSTRAINT ConfDayReservation_ConferenceDays
    FOREIGN KEY (ConfDayID)
    REFERENCES ConferenceDays (ConfDayID);

-- Reference: Conference_Adresses (table: Conference)
ALTER TABLE Conference ADD CONSTRAINT Conference_Adresses
    FOREIGN KEY (AdressID)
    REFERENCES Adresses (AdressID);

-- Reference: Discounts_ConferenceDays (table: Discounts)
ALTER TABLE Discounts ADD CONSTRAINT Discounts_ConferenceDays
    FOREIGN KEY (ConfDayID)
    REFERENCES ConferenceDays (ConfDayID);

-- Reference: Konferencje_Dni_Konferencje (table: ConferenceDays)
ALTER TABLE ConferenceDays ADD CONSTRAINT Konferencje_Dni_Konferencje
    FOREIGN KEY (ConfID)
    REFERENCES Conference (ID_Conference);

-- Reference: Participants_Adresses (table: Participants)
ALTER TABLE Participants ADD CONSTRAINT Participants_Adresses
    FOREIGN KEY (AdressID)
    REFERENCES Adresses (AdressID);

-- Reference: Participants_Clients (table: Participants)
ALTER TABLE Participants ADD CONSTRAINT Participants_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID)
    ON UPDATE  CASCADE;

-- Reference: WorkshopRegistrations_ConfDayRegistrations (table: WorkshopRegistrations)
ALTER TABLE WorkshopRegistrations ADD CONSTRAINT WorkshopRegistrations_ConfDayRegistrations
    FOREIGN KEY (ConfDayRegistrationID)
    REFERENCES ConfDayRegistrations (ConfDayRegistrationID);

-- Reference: WorkshopRegistrations_Participants (table: WorkshopRegistrations)
ALTER TABLE WorkshopRegistrations ADD CONSTRAINT WorkshopRegistrations_Participants
    FOREIGN KEY (ParticipantID)
    REFERENCES Participants (ParticipantID);

-- Reference: WorkshopRegistrations_WorkshopReservations (table: WorkshopRegistrations)
ALTER TABLE WorkshopRegistrations ADD CONSTRAINT WorkshopRegistrations_WorkshopReservations
    FOREIGN KEY (WorkshopReservID)
    REFERENCES WorkshopReservations (WorkshopReservID);

-- Reference: WorkshopReservations_ConfDayReservations (table: WorkshopReservations)
ALTER TABLE WorkshopReservations ADD CONSTRAINT WorkshopReservations_ConfDayReservations
    FOREIGN KEY (ConfDayReservationID)
    REFERENCES ConfDayReservations (ConfDayReservationID);

-- Reference: WorkshopReservations_Workshops (table: WorkshopReservations)
ALTER TABLE WorkshopReservations ADD CONSTRAINT WorkshopReservations_Workshops
    FOREIGN KEY (WorkshopID)
    REFERENCES Workshops (WorkshopID);

-- Reference: Workshops_ConferenceDays (table: Workshops)
ALTER TABLE Workshops ADD CONSTRAINT Workshops_ConferenceDays
    FOREIGN KEY (ConfDayID)
    REFERENCES ConferenceDays (ConfDayID);

-- End of file.

