CREATE FUNCTION conference_days(
    @conferenceId INT
)
    RETURNS @days TABLE
                  (
                      conferenceDayId INT,
                      date            DATE,
                      MaxParticipants INT
                  )
AS
BEGIN
    INSERT INTO @days
    SELECT ConferenceDayID, Date, MaxParticipants
    FROM ConferenceDays
    WHERE ConferenceID = @conferenceId
    RETURN
END


CREATE FUNCTION PriceOnDate(@conferenceId INT,
                            @date DATE)
    RETURNS INT
AS
BEGIN
    RETURN (
        SELECT
        top 1
        Prices.Value
        FROM Prices
        WHERE Prices.ConferenceID = @conferenceId
          and Prices.Date = @date
        ORDER BY Prices.Date
    )
END


CREATE FUNCTION availablePlaces(@conferenceDayId INT
)
    RETURNS INT
AS
BEGIN
    RETURN (
        SELECT ConferenceDays.MaxParticipants - SUM(CDB.ParticipantsNo)
        FROM ConferenceDays
                 LEFT JOIN ConferenceDayBooking CDB
                           on ConferenceDays.ConferenceDayID = CDB.ConferenceDayID AND CDB.isCancelled = 0
        WHERE ConferenceDays.ConferenceDayID = @conferenceDayId
        GROUP BY ConferenceDays.ConferenceDayID, ConferenceDays.MaxParticipants
    )
END


CREATE FUNCTION BeginTimeWorkshop(@WorshopID INT
)
    RETURNS datetime
AS
BEGIN
    RETURN (
        SELECT CAST(Workshops.BeginTime AS DATETIME) + CAST(CD.Date AS DATETIME)
        FROM Workshops
                 INNER JOIN ConferenceDays CD on Workshops.ConferenceDayID = CD.ConferenceDayID
        WHERE WorkshopID = @WorshopID
    )
END


CREATE FUNCTION EndTimeWorkshop(@WorshopID INT
)
    RETURNS datetime
AS
BEGIN
    RETURN (
        SELECT CAST(Workshops.EndTime AS DATETIME) + CAST(CD.Date AS DATETIME)
        FROM Workshops
                 INNER JOIN ConferenceDays CD on Workshops.ConferenceDayID = CD.ConferenceDayID
        WHERE WorkshopID = @WorshopID
    )
END


CREATE FUNCTION AreWorkshopAtTheSameTime(@Workshop1 int,
                                         @Workshop2 int)
    RETURNS bit
AS
BEGIN
    DECLARE @Begin1 datetime = dbo.BeginTimeWorkshop(@Workshop1);
    DECLARE @End1 datetime = dbo.EndTimeWorkshop(@Workshop1);
    DECLARE @Begin2 datetime =dbo.BeginTimeWorkshop(@Workshop2);
    DECLARE @End2 datetime = dbo.EndTimeWorkshop(@Workshop2);
    IF (@Begin1 < @Begin2 AND @Begin2 < @End1) RETURN 1
    IF (@Begin2 < @Begin1 AND @Begin1 < @End2) RETURN 1
    IF (@Begin1 >= @Begin2 AND @End2 >= @End1) RETURN 1
    IF (@Begin2 >= @Begin1 AND @End1 >= @End2) RETURN 1
    RETURN 0
end
