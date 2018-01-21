

CREATE PROCEDURE AddParticipant (
	@ParticipantID int,
    @FirstName nvarchar(20),
    @LastName nvarchar(20),
    @AdressID int,
    @StudentCardID int
)
	AS BEGIN
	SET NOCOUNT ON

	