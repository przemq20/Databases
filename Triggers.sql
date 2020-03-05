CREATE TRIGGER ConferenceDayParticipantsCheckTrigger
    ON ConferenceDayParticipants
    FOR INSERT AS
BEGIN
    DECLARE @ConferenceDayBookingID int = (SELECT ConferenceDayBookingID FROM inserted)
    DECLARE @ParticipantsCount int = (SELECT COUNT(*)
                                      FROM ConferenceDayParticipants
                                      WHERE ConferenceDayBookingID =
                                            @ConferenceDayBookingID)
    DECLARE @ParticipantsNo int = (SELECT ParticipantsNo
                                   FROM ConferenceDayBooking
                                   WHERE ConferenceDayBookingID =
                                         @ConferenceDayBookingID)
    IF (@ParticipantsNo < @ParticipantsCount)
        BEGIN
            Throw 52000, 'Participants number over ParticipantsNo from ConferenceDayBooking', 1
            ROLLBACK TRANSACTION
        END
END


CREATE TRIGGER WorkshopParticipantsCheckTrigger
    ON WorkshopParticipants
    FOR INSERT AS
BEGIN
    DECLARE @WorkshopBookingID int = (SELECT WorkshopBookingID FROM inserted)
    DECLARE @ParticipantsCount int = (SELECT COUNT(*)
                                      FROM WorkshopParticipants
                                      WHERE WorkshopBookingID =
                                            @WorkshopBookingID)
    DECLARE @ParticipantsNo int = (SELECT ParticipantsNo
                                   FROM WorkshopsBooking
                                   WHERE WorkshopBookingID =
                                         @WorkshopBookingID)
    IF (@ParticipantsNo < @ParticipantsCount)
        BEGIN
            THROW 52000, 'Participants number over ParticipantsNo from WorkshopsBooking', 1
            ROLLBACK TRANSACTION
        END
END


CREATE TRIGGER CancelConferenceTrigger
    ON Conferences
    FOR UPDATE AS
BEGIN
    IF UPDATE(isCancelled)
        BEGIN
            DECLARE @ConferenceID int = (SELECT ConferenceID FROM inserted)
            IF (SELECT isCancelled FROM inserted) = 1
                BEGIN
                    UPDATE ConferenceBooking SET isCancelled = 1 WHERE ConferenceBookingID = @ConferenceID
                END
        END
END


CREATE TRIGGER CancelConferenceBookingTrigger
    ON ConferenceBooking
    FOR UPDATE AS
BEGIN
    IF UPDATE(isCancelled)
        BEGIN
            DECLARE @ConferenceBookingID int = (SELECT ConferenceBookingID FROM inserted)
            IF (SELECT isCancelled FROM inserted) = 1
                BEGIN
                    UPDATE ConferenceDayBooking SET isCancelled = 1 WHERE ConferenceBookingID = @ConferenceBookingID
                END
        END
END


CREATE TRIGGER CancelWorkshopBookingTrigger
    ON ConferenceDayBooking
    FOR UPDATE AS
BEGIN
    IF UPDATE(isCancelled)
        BEGIN
            DECLARE @ConferenceDayBookingID int = (SELECT ConferenceDayBookingID FROM inserted)
            IF (SELECT isCancelled FROM inserted) = 1
                BEGIN
                    UPDATE WorkshopsBooking
                    SET isCancelled = 1
                    WHERE ConferenceDayBookingID = @ConferenceDayBookingID
                END
        END
END


CREATE TRIGGER ConferenceDayWithinConference
    ON ConferenceDays
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS(
            SELECT *
            FROM inserted as i
                     join Conferences AS c ON c.ConferenceID = i.ConferenceID
            WHERE i.Date > C.EndTime
               OR i.Date < C.BeginTime
        )
        BEGIN
            ; THROW 50001 , 'Conference day(s) is(are) outside of conference duration .' ,1
        end
    CREATE TRIGGER BookPastConference
        ON ConferenceDayBooking
        AFTER INSERT
        AS
    BEGIN
        SET NOCOUNT ON
        IF EXISTS(
                SELECT *
                FROM inserted as i
                         join ConferenceDayBooking AS c ON c.ConferenceBookingID = i.ConferenceDayBookingID
                         join ConferenceDays CD on c.ConferenceDayID = CD.ConferenceDayID
                WHERE i.BookingTime > CD.Date
            )
            BEGIN
                ; THROW 50001 , 'Booking is outside of conference day duration .' ,1
            end
    end

end

