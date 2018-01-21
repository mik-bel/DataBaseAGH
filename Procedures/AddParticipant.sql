IF OBJECT_ID ('AddParticipant') is not null
DROP PROC AddParticipant;
GO

CREATE PROCEDURE AddParticipant (
    @FirstName nvarchar(20),
    @LastName nvarchar(20),
    @AdressID int,
    @StudentCardID int,
    @ClientID int,
    @ParticipantID int = NULL OUT,
) AS BEGIN
	SET NOCOUNT ON


	IF @FirstName is null
		THROW (2501, 'First name cant be null!', 1)
	
	IF @LastName is null
		(THROW 2501, 'LastName cant be null!', 1)

	IF @AdressID is null
		(THROW 2501, 'AdressID cant be null!', 1)

	IF @ClientID is null
		(THROW 2501, 'ClientID cant be null', 1)


	INSERT INTO Participants (ClientID, FirstName, LastName, AdressID, StudentCardID)
	VALUES (@ClientID, @FirstName, @LastName, @AdressID, @StudentCardID)
	SET @ParticipantID = SCOPE_IDENTITY();
END
