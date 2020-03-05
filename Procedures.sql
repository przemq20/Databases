CREATE PROCEDURE AddNewClient @Name nvarchar(50),
                                    @EMail varchar(50),
                                           @Password varchar(100),
                                                     @Street nvarchar(50) = NULL,
                                                             @PostalCode nvarchar(10) = NULL,
                                                                         @City nvarchar(20) = NULL,
                                                                               @Country nvarchar(20) = NULL,
                                                                                        @NIP varchar(10) = NULL AS BEGIN
SET NOCOUNT ON IF (@NIP IS NOT NULL) BEGIN
INSERT INTO Clients (Name, EMail, Password, Street, PostalCode, City, Country, isCompany)
VALUES (@Name,
        @EMail,
        '*********',
        @Street,
        @PostalCode,
        @City,
        @Country,
        1)
INSERT INTO Companies (ClientID, NIP)
VALUES (
          (SELECT ClientID
           FROM Clients
           WHERE Email = @Email), @NIP) END ELSE BEGIN
INSERT INTO Clients (Name, EMail, Password, Street, PostalCode, City, Country, isCompany)
VALUES (@Name,
        @EMail,
        '*********',
        @Street,
        @PostalCode,
        @City,
        @Country,
        0) END END

CREATE PROCEDURE UpdateClientData @EMail varchar(50),
                                         @Name nvarchar(50) = NULL,
                                               @Password varchar(100) = NULL,
                                                         @Street nvarchar(50) = NULL,
                                                                 @PostalCode varchar(10) = NULL,
                                                                             @City nvarchar(50) = NULL,
                                                                                   @Country nvarchar(50) = NULL,
                                                                                            @NIP varchar(10) = NULL AS BEGIN
SET NOCOUNT ON; IF @Name IS NOT NULL BEGIN
UPDATE Clients
SET Name = @Name
WHERE EMail = @EMail END
        IF @Password IS NOT NULL BEGIN
  UPDATE Clients
  SET Password = @Password WHERE EMail = @EMail END
        IF @Street IS NOT NULL BEGIN
  UPDATE Clients
  SET Street = @Street WHERE EMail = @EMail END
        IF @PostalCode IS NOT NULL BEGIN
  UPDATE Clients
  SET PostalCode = @PostalCode WHERE EMail = @EMail END
        IF @City IS NOT NULL BEGIN
  UPDATE Clients
  SET City = @City WHERE EMail = @EMail END
        IF @Country IS NOT NULL BEGIN
  UPDATE Clients
  SET Country = @Country
  WHERE EMail = @EMail END
        IF @NIP IS NOT NULL BEGIN
    UPDATE Clients
    SET isCompany = 1
    WHERE EMail = @EMail IF (
                               (SELECT Companies.ClientID
                                FROM Companies
                                INNER JOIN Clients C ON Companies.ClientID = C.ClientID
                                WHERE C.EMail = @EMail) IS NOT NULL) BEGIN
      UPDATE Companies
      SET NIP = @NIP
      WHERE ClientID =
          (SELECT Companies.ClientID
           FROM Companies
           INNER JOIN Clients C ON Companies.ClientID = C.ClientID
           WHERE C.EMail = @EMail) END ELSE BEGIN
      INSERT INTO Companies (ClientID, NIP)
      VALUES (
                (SELECT ClientID
                 FROM Clients
                 WHERE Email = @Email), @NIP) END END END

  CREATE PROCEDURE AddParticipant @FirstName nvarchar(50),
                                             @LastName nvarchar(50),
                                                       @Street nvarchar(50) = NULL,
                                                               @PostalCode nvarchar(10) = NULL,
                                                                           @City nvarchar(50) = NULL,
                                                                                 @Country nvarchar(50) = NULL,
                                                                                          @StudentID nvarchar(50) = NULL,
                                                                                                     @valid date = NULL AS BEGIN
  SET NOCOUNT ON IF @StudentID IS NOT NULL BEGIN
  INSERT INTO Participants (FirstName, LastName, Street, PostalCode, City, Country, isStudent)
  VALUES (@FirstName,
          @LastName,
          @Street,
          @PostalCode,
          @City,
          @Country,
          1)
  INSERT INTO Student (ParticipantID, StudentID, VALID)
  VALUES (
            (SELECT ParticipantID
             FROM Participants
             WHERE FirstName = @FirstName
               AND LastName = @LastName
               AND Street = @Street
               AND PostalCode = @PostalCode
               AND City = @City
               AND Country = @Country), @StudentID,
                                        @valid) END ELSE BEGIN
  INSERT INTO Participants (FirstName, LastName, Street, PostalCode, City, Country, isStudent)
  VALUES (@FirstName,
          @LastName,
          @Street,
          @PostalCode,
          @City,
          @Country,
          0) END END

  CREATE PROCEDURE AddParticipantToConferenceDay @ParticipantID int, @ConferenceDayBookingID int AS BEGIN
  SET NOCOUNT ON
  INSERT INTO ConferenceDayParticipants (ParticipantID, ConferenceDayBookingID)
  VALUES (@ParticipantID,
          @ConferenceDayBookingID) END

  CREATE PROCEDURE AddConference @Name nvarchar(50),
                                       @BeginTime date, @EndTime date, @Place nvarchar(50) AS BEGIN
  SET NOCOUNT ON;
  INSERT INTO Conferences (BeginTime, EndTime, Place, Name)
  VALUES (@BeginTime,
          @EndTime,
          @Place,
          @Name) END

  CREATE PROCEDURE CancelConference @ConferenceID int AS BEGIN
  SET NOCOUNT ON
  UPDATE Conferences
  SET isCancelled = 1
  WHERE ConferenceID = @ConferenceID END

  CREATE PROCEDURE AddConferenceDay @ConferenceID int, @Place nvarchar(50),
                                                              @MaxParticipants int, @Date date AS BEGIN
  SET NOCOUNT ON DECLARE @ConfStart date =
    (SELECT BeginTime
     FROM Conferences
     WHERE ConferenceID = @ConferenceID) DECLARE @ConfEnd date =
    (SELECT EndTime
     FROM Conferences
     WHERE ConferenceID = @ConferenceID) DECLARE @Allowed int =
    (SELECT 1
     FROM ConferenceDays
     WHERE ConferenceID = @ConferenceID
       AND Date = @Date) IF (@Date >= @ConfStart
                             AND @Date <= @ConfEnd
                             AND @Allowed <> 0) BEGIN
  INSERT INTO ConferenceDays (ConferenceID, Place, MaxParticipants, Date)
  VALUES (@ConferenceID,
          @Place,
          @MaxParticipants,
          @Date) END ELSE BEGIN RAISERROR ('Wrong date', -1, -1) END END

  CREATE PROCEDURE UpdateConferenceDay @ConferenceDayID int, @Place nvarchar(50) = NULL,
                                                                    @MaxParticipants int = NULL AS BEGIN
  SET NOCOUNT ON IF @Place IS NOT NULL BEGIN
  UPDATE ConferenceDays
  SET Place = @Place
  WHERE ConferenceDayID = @ConferenceDayID END
                                IF @MaxParticipants IS NOT NULL BEGIN
    UPDATE ConferenceDays
    SET MaxParticipants = @MaxParticipants
    WHERE ConferenceDayID = @ConferenceDayID END END

  CREATE PROCEDURE AddConferenceBooking @ConferenceID int, @ClientID int AS BEGIN
  INSERT INTO ConferenceBooking (ConferenceID, ClientID, isCancelled, BookingTime)
  VALUES (@ConferenceID,
          @ClientID,
          0,
          GETDATE()) END

  CREATE PROCEDURE CancelConfBooking @ConferenceBookingID int AS BEGIN
  SET NOCOUNT ON;
  UPDATE ConferenceBooking
  SET isCancelled = 1
  WHERE ConferenceBookingID = @ConferenceBookingID END

  CREATE PROCEDURE AddConferenceDayBooking @ConferenceBookingID int, @ParticipantsNo int, @StudentsNo int, @ConferenceDayID int AS BEGIN DECLARE @MaxParticipants int =
    (SELECT MaxParticipants
     FROM ConferenceDays
     WHERE ConferenceDayID = @ConferenceDayID) DECLARE @AlreadyBooked int =
    (SELECT isnull(SUM(ParticipantsNo), 0)
     FROM ConferenceDayBooking
     WHERE ConferenceDayID = @ConferenceDayID) DECLARE @Allowed int =
    (SELECT TOP 1 1
     FROM ConferenceBooking
     JOIN Conferences ON ConferenceBooking.ConferenceID = Conferences.ConferenceID
     JOIN ConferenceDays ON ConferenceDays.ConferenceID = Conferences.ConferenceID
     WHERE ConferenceDayID = @ConferenceDayID
       AND ConferenceBookingID = @ConferenceBookingID) IF (@ParticipantsNo + @AlreadyBooked <= @MaxParticipants
                                                           AND @Allowed = 1) BEGIN
  INSERT INTO ConferenceDayBooking (ConferenceBookingID, BookingTime, ParticipantsNo, StudentsNo, ConferenceDayID, isCancelled)
  VALUES (@ConferenceBookingID,
          GETDATE(),
          @ParticipantsNo,
          @StudentsNo,
          @ConferenceDayID,
          0) END ELSE BEGIN RAISERROR ('ParticipantsNo over MaxParticipants', -1, -1) END END

  CREATE PROCEDURE CancelConfereceBooking @ConferenceBookingID int AS BEGIN
  SET NOCOUNT ON
  UPDATE ConferenceBooking
  SET isCancelled = 1
  WHERE ConferenceBookingID = @ConferenceBookingID END

  CREATE PROCEDURE AddPrice @from date, @to date, @ConferenceID int, @Value MONEY,
                                                                            @StudentsDiscount decimal(3, 2) AS BEGIN
  SET NOCOUNT ON; DECLARE @ConfDate date =
    (SELECT BeginTime
     FROM Conferences
     WHERE ConferenceID = @ConferenceID) IF (@from < @to)
  AND (@to <= @ConfDate) BEGIN WHILE @from <= @to BEGIN
  INSERT INTO Prices (ConferenceID, Date, Value, StudentsDiscount)
  VALUES (@ConferenceID,
          @from,
          @Value,
          @StudentsDiscount)
  SET @from =
    (SELECT DATEADD(DAY, 1, @from)) END END ELSE BEGIN RAISERROR ('From >= To', -1, -1) END END

  CREATE PROCEDURE AddPayment @ConferenceBookingID int, @Value MONEY AS BEGIN
  SET NOCOUNT ON;
  INSERT INTO Payments (ConferenceBookingID, Value, TIME, isCancelled)
  VALUES (@ConferenceBookingID,
          @Value,
          GETDATE(),
          0) END
  CREATE PROCEDURE CancelPayment @PaymentID int AS BEGIN
  SET NOCOUNT ON;
  UPDATE Payments
  SET isCancelled = 1
  WHERE PaymentID = @PaymentID END

  CREATE PROCEDURE AddWorkshop @ConferenceDayID int, @Name nvarchar(50),
                                                           @BeginTime time(7),
                                                                      @EndTime time(7),
                                                                               @Place nvarchar(50),
                                                                                      @Price MONEY,
                                                                                             @MaxParticipants int AS BEGIN
  SET NOCOUNT ON
  INSERT INTO Workshops (ConferenceDayID, Name, BeginTime, EndTime, Place, Price, MaxParticipants)
  VALUES (@ConferenceDayID,
          @Name,
          @BeginTime,
          @EndTime,
          @Place,
          @Price,
          @MaxParticipants) END

  CREATE PROCEDURE AddWorkshop @WorkshopID int, @Name nvarchar(50),
                                                      @Place nvarchar(50),
                                                             @Price MONEY,
                                                                    @MaxParticipants int AS BEGIN
  SET NOCOUNT ON IF @Name IS NOT NULL BEGIN
  UPDATE Workshops
  SET Name = @Name WHERE WorkshopID = @WorkshopID END
                                                                    IF @Place IS NOT NULL BEGIN
  UPDATE Workshops
  SET Place = @Place WHERE WorkshopID = @WorkshopID END
                                                                    IF @Price IS NOT NULL BEGIN
  UPDATE Workshops
  SET Price = @Price
  WHERE WorkshopID = @WorkshopID END
                                                                    IF @MaxParticipants IS NOT NULL BEGIN
    UPDATE Workshops
    SET MaxParticipants = @MaxParticipants
    WHERE WorkshopID = @WorkshopID END END

  CREATE PROCEDURE AddNewWorkshopBooking @ConferenceDayBookingID int, @WorkshopID int, @ParticipantsNo int AS BEGIN DECLARE @MaxParticipants AS int DECLARE @AlreadyBooked AS int
  SET @MaxParticipants =
    (SELECT MaxParticipants
     FROM Workshops
     WHERE WorkshopID = @WorkshopID)
  SET @AlreadyBooked =
    (SELECT isnull(SUM(ParticipantsNo), 0)
     FROM WorkshopsBooking
     WHERE WorkshopID = @WorkshopID) DECLARE @Allowed AS int
  SET @Allowed =
    (SELECT TOP 1 1
     FROM ConferenceDayBooking
     JOIN ConferenceDays ON ConferenceDayBooking.ConferenceDayID = ConferenceDays.ConferenceDayID
     JOIN Workshops ON Workshops.ConferenceDayID = ConferenceDays.ConferenceDayID
     WHERE WorkshopID = @WorkshopID
       AND ConferenceDayBookingID = @ConferenceDayBookingID) IF (@MaxParticipants >= @AlreadyBooked + @ParticipantsNo
                                                                 AND @Allowed = 1) BEGIN
  INSERT INTO WorkshopsBooking (ConferenceDayBookingID, WorkshopID, ParticipantsNo, isCancelled, BookingTime)
  VALUES (@ConferenceDayBookingID,
          @WorkshopID,
          @ParticipantsNo,
          0,
          GETDATE()) END ELSE BEGIN RAISERROR ('ParticipantsNo over MaxParticipants', -1, -1) END END

  CREATE PROCEDURE CancelWorkshopBooking @WorkshopBookingID int AS BEGIN
  SET NOCOUNT ON
  UPDATE WorkshopsBooking
  SET isCancelled = 1
  WHERE WorkshopBookingID = @WorkshopBookingID END

  CREATE PROCEDURE AddParticipantToWorkshop @ParticipantID int, @WorkshopBookingID int AS BEGIN
  SET NOCOUNT ON DECLARE @ConferenceDayBookingID int =
    (SELECT ConferenceDayBookingID
     FROM WorkshopsBooking
     WHERE WorkshopBookingID = @WorkshopBookingID) DECLARE @ConferenceDayParticipantID int =
    (SELECT ConfDayParticipantID
     FROM ConferenceDayParticipants
     WHERE ConferenceDayBookingID = @ConferenceDayBookingID
       AND ParticipantID = @ParticipantID) DECLARE @WorkshopID int =
    (SELECT WorkshopID
     FROM WorkshopsBooking
     WHERE WorkshopBookingID = @WorkshopBookingID) DECLARE @Allowed int =
    (SELECT 1
     FROM WorkshopParticipants AS wp
     JOIN WorkshopsBooking AS wb ON wp.WorkshopBookingID = wb.WorkshopBookingID
     JOIN Workshops AS w ON w.WorkshopID = wb.WorkshopID
     WHERE wp.ConferenceDayParticipantID IN
         (SELECT ConfDayParticipantID
          FROM ConferenceDayParticipants
          WHERE ParticipantID = @ParticipantID)
       AND (w.BeginTime <
              (SELECT Workshops.EndTime
               FROM Workshops
               WHERE Workshops.WorkshopID = @WorkshopID)
            OR w.EndTime >
              (SELECT Workshops.BeginTime
               FROM Workshops
               WHERE Workshops.WorkshopID = @WorkshopID))) IF @Allowed = 1 BEGIN
  INSERT INTO WorkshopParticipants (WorkshopBookingID, ConferenceDayParticipantID)
  VALUES (@WorkshopBookingID,
          @ConferenceDayParticipantID) END ELSE BEGIN RAISERROR ('The participant takes part in another Workshop at the time', -1, -1) END END