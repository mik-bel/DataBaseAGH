--procedures

IF OBJECT_ID ('Add_Clients') is not null
DROP PROC Add_Clients;
GO

IF OBJECT_ID ('Add_Participants') is not null
DROP PROC Add_Participants;
GO

IF OBJECT_ID ('Add_Conferences') is not null
DROP PROC Add_Conferences;
GO

IF OBJECT_ID ('Add_ConfDay') is not null
DROP PROC Add_Conf_Day;
GO

IF OBJECT_ID('Add_ConfDayReservations') is not null 
DROP PROC Add_ConfDayReservations;
GO

IF OBJECT_ID('Add_ConfDayRegistrations') is not null
DROP Add_ConfDayRegistrations;
GO

IF OBJECT_ID ('Add_WorkshopRegistrations') is not null
DROP PROC Add_WorkshopRegistrations;
GO

IF OBJECT_ID('Add_WorkshopReservations') is not null
DROP PROC Add_WorkshopReservations;
GO

IF OBJECT_ID('Add_Workshop') is not null
DROP PROC Add_Workshop;
GO

--CREATE PROCEDURE Add_Clients
	--	@ClientID int,
		--@CompanyID int,
		--@Login nchar(10),
		--@Password nvarchar(255),
		--@Mail varchar(60)
		--AS 
		--BEGIN
			--SET NOCOUNT ON;
			--DECLARE
		
		
