CREATE VIEW CancelledConferences AS
SELECT dbo.Conferences.Name, dbo.Conferences.BeginTime, dbo.Conferences.EndTime, dbo.Conferences.Place
FROM dbo.Conferences
WHERE dbo.Conferences.isCancelled = 1


CREATE VIEW ClientsWithMostReservations AS
SELECT a.ClientID,
       Clients.Name,
       ConferenceBookingsCount,
       ConferenceDayBookingsCount,
       WorkshopsBookingsCount,
       ConferenceBookingsCount + ConferenceDayBookingsCount + WorkshopsBookingsCount AS AllBookings
FROM (SELECT ClientID, COUNT(ConferenceBooking.ConferenceBookingID) AS ConferenceBookingsCount
      FROM ConferenceBooking
      GROUP BY ClientID) AS a
         JOIN
     (SELECT ClientID, COUNT(ConferenceDayBooking.ConferenceDayBookingID) AS ConferenceDayBookingsCount
      FROM ConferenceDayBooking
               LEFT JOIN ConferenceBooking ON ConferenceDayBooking.ConferenceBookingID =
                                              ConferenceBooking.ConferenceBookingID
      GROUP BY ClientID) AS b
     ON a.ClientID = b.ClientID
         JOIN
     (SELECT ConferenceBooking.ClientID, COUNT(WorkshopsBooking.WorkshopBookingID) AS WorkshopsBookingsCount
      FROM WorkshopsBooking
               LEFT JOIN ConferenceDayBooking ON WorkshopsBooking.ConferenceDayBookingID =
                                                 ConferenceDayBooking.ConferenceDayBookingID
               LEFT JOIN ConferenceBooking ON ConferenceDayBooking.ConferenceBookingID =
                                              ConferenceBooking.ConferenceBookingID
      GROUP BY ConferenceBooking.ClientID) AS c
         INNER JOIN Clients on c.ClientID = Clients.ClientID
                    ON b.ClientID = c.ClientID


CREATE VIEW FutureConferences AS
SELECT Conferences.Name,
       Conferences.BeginTime,
       Conferences.EndTime,
       Conferences.Place,
       SUM(ConferenceDays.MaxParticipants) AS MaxParticipants,
       (SELECT SUM(daySum)
        FROM (SELECT SUM(ConferenceDayBooking.ParticipantsNo) AS daySum, ConferenceDayID
              FROM ConferenceDayBooking
              WHERE ConferenceDayBooking.isCancelled = 0
              GROUP BY ConferenceDayID) AS s
                 JOIN ConferenceDays ON s.ConferenceDayID = ConferenceDays.ConferenceDayID
                 JOIN Conferences AS c ON c.ConferenceID = ConferenceDays.ConferenceID
        WHERE Conferences.ConferenceID = c.ConferenceID
        GROUP BY c.ConferenceID)           AS Reserved
FROM Conferences
         LEFT OUTER JOIN ConferenceDays ON Conferences.ConferenceID =
                                           ConferenceDays.ConferenceID
WHERE (Conferences.EndTime >= GETDATE())
GROUP BY Conferences.ConferenceID, Conferences.Name, Conferences.BeginTime, Conferences.EndTime,
         Conferences.Place


CREATE VIEW UnpaidCompanyBookings AS
SELECT Clients.Name,
       ConferenceBooking.ConferenceBookingID,
       Clients.EMail    AS [Client Email],
       Conferences.Name AS [Conference Name]
FROM (ConferenceBooking LEFT JOIN Payments P on ConferenceBooking.ConferenceBookingID = P.ConferenceBookingID)
         INNER JOIN Clients ON Clients.ClientID = ConferenceBooking.ConferenceBookingID
         INNER JOIN Conferences ON Conferences.ConferenceID = ConferenceBooking.ConferenceID
WHERE P.Value IS NULL
  AND ConferenceBooking.isCancelled = 0
  AND Clients.isCompany = 1


CREATE VIEW UnpaidPersonBookings AS
select Clients.Name,
       ConferenceBooking.ConferenceBookingID,
       Clients.EMail    AS [Client Email],
       Conferences.Name AS [Conference Name]
from (ConferenceBooking left join Payments P on ConferenceBooking.ConferenceBookingID = P.ConferenceBookingID)
         INNER JOIN Clients ON Clients.ClientID = ConferenceBooking.ConferenceBookingID
         INNER JOIN Conferences ON Conferences.ConferenceID = ConferenceBooking.ConferenceID
Where P.Value IS NULL
  AND ConferenceBooking.isCancelled = 0
  AND Clients.isCompany = 0


CREATE VIEW ParticipantsInFutureConferences AS
SELECT DISTINCT Participants.ParticipantID,
                Participants.FirstName,
                Participants.LastName,
                ConferenceDays.Date,
                Conferences.Name As [Conference Name]
FROM Participants
         JOIN ConferenceDayParticipants ON Participants.ParticipantID =
                                           ConferenceDayParticipants.ParticipantID
         JOIN ConferenceDayBooking ON ConferenceDayBooking.ConferenceDayBookingID =
                                      ConferenceDayParticipants.ConferenceDayBookingID AND
                                      ConferenceDayBooking.isCancelled = 0
         JOIN ConferenceDays ON ConferenceDayBooking.ConferenceDayID =
                                ConferenceDays.ConferenceDayID
         JOIN Conferences ON ConferenceDays.ConferenceID = Conferences.ConferenceID
WHERE (ConferenceDays.Date >= CAST(GETDATE() AS DATE))


CREATE VIEW FutureConferencesDays AS
SELECT ConferenceDayBooking.ConferenceDayBookingID,
       ConferenceDayBooking.isCancelled,
       ConferenceDays.Date,
       ConferenceDayBooking.ParticipantsNo,
       ConferenceDayBooking.StudentsNo,
       COUNT(ConferenceDayParticipants.ConfDayParticipantID)                    AS TotalCount,
       SUM(CASE WHEN ConferenceDayParticipants.isStudent = 1 THEN 1 ELSE 0 END) AS StudentCount
FROM ConferenceDayBooking
         LEFT JOIN ConferenceDayParticipants ON ConferenceDayBooking.ConferenceDayBookingID =
                                                ConferenceDayParticipants.ConferenceDayBookingID
         JOIN ConferenceDays ON ConferenceDays.ConferenceDayID =
                                ConferenceDayBooking.ConferenceDayID
WHERE ConferenceDays.Date <= DATEADD(day, 30, CAST(GETDATE() AS date))
  AND ConferenceDays.Date >= CAST(GETDATE() AS date)
GROUP BY ConferenceDayBooking.ConferenceDayBookingID, ConferenceDayBooking.isCancelled, ConferenceDays.Date,
         ConferenceDayBooking.ParticipantsNo, ConferenceDayBooking.StudentsNo


CREATE VIEW FutureWorkshops AS
SELECT WorkshopsBooking.WorkshopBookingID,
       WorkshopsBooking.isCancelled,
       Workshops.Name,
       ConferenceDays.Date,
       Workshops.BeginTime,
       Workshops.EndTime,
       WorkshopsBooking.ParticipantsNo,
       COUNT(WorkshopParticipants.ConfDayParticipantID) AS fullParticipants
FROM WorkshopsBooking
         LEFT JOIN WorkshopParticipants ON WorkshopsBooking.WorkshopBookingID =
                                           WorkshopParticipants.WorkshopBookingID
         JOIN Workshops ON WorkshopsBooking.WorkshopID = Workshops.WorkshopID
         JOIN ConferenceDays ON ConferenceDays.ConferenceDayID = Workshops.ConferenceDayID
WHERE ConferenceDays.Date <= DATEADD(day, 30, CAST(GETDATE() AS date))
  AND ConferenceDays.Date >= CAST(GETDATE() AS date)
GROUP BY WorkshopsBooking.WorkshopBookingID, WorkshopsBooking.isCancelled, Workshops.Name,
         ConferenceDays.Date, Workshops.BeginTime, Workshops.EndTime, WorkshopsBooking.ParticipantsNo


CREATE VIEW WorkshopOccupancy AS
Select WB1.WorkshopID,
       W1.name,
       W1.MaxParticipants,
       Sum(WB1.ParticipantsNo) AS EmptySeats,
       CAST(CONVERT(DECIMAL(5, 2), (Sum(WB1.ParticipantsNo)) / CONVERT(DECIMAL(5, 2), W1.MaxParticipants)) *
            100 AS Varchar)    AS FillPercent
from WorkshopsBooking AS WB1
         INNER JOIN Workshops W1 on WB1.WorkshopID = W1.WorkshopID
GROUP BY WB1.WorkshopID, W1.MaxParticipants, w1.name


CREATE VIEW ConferenceOccupancy AS
SELECT ConferenceDays.ConferenceID,
       C.Name,
       sum(ConferenceDays.MaxParticipants) AS MaxParticipants,
       sum(CDB.ParticipantsNo)             AS TakenSeats,
       CONVERT(DECIMAL(15, 8), (Sum(CDB.ParticipantsNo)) / CONVERT(DECIMAL(15, 8), ConferenceDays.MaxParticipants) *
                               100)        AS FillPercent
from ConferenceDays
         INNER JOIN ConferenceDayBooking CDB on ConferenceDays.ConferenceDayID = CDB.ConferenceDayID
         INNER JOIN Conferences C on ConferenceDays.ConferenceID = C.ConferenceID
GROUP BY ConferenceDays.ConferenceID, C.Name, ConferenceDays.MaxParticipants


CREATE VIEW BookingsToCancell AS
SELECT C.Name AS [Client name], C2.Name AS [Conference Name], C2.BeginTime AS [Conference Begin Time]
from ConferenceBooking
         LEFT JOIN Payments P on ConferenceBooking.ConferenceBookingID = P.ConferenceBookingID
         INNER JOIN Clients C on ConferenceBooking.ClientID = C.ClientID
         INNER JOIN Conferences C2 on ConferenceBooking.ConferenceID = C2.ConferenceID
WHERE P.Time is null
  AND ABS(DATEDIFF(Day, GETDATE(), C2.BeginTime)) < 7
