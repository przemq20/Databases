CREATE TABLE [dbo].[Participants]
(
    [ParticipantID] [int] IDENTITY (1,1) NOT NULL,
    [FirstName]     [nvarchar](50)       NOT NULL,
    [LastName]      [nvarchar](50)       NOT NULL,
    [Street]        [nvarchar](50)       NULL,
    [PostalCode]    [varchar](10)        NULL,
    [City]          [nvarchar](50)       NULL,
    [Country]       [nvarchar](50)       NULL,
    [isStudent]     [bit]                NOT NULL DEFAULT 0,
    CONSTRAINT [PK_Participants] PRIMARY KEY CLUSTERED
        (
         [ParticipantID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Participants]
    WITH CHECK ADD CONSTRAINT [CK_Participants_PostalCode]
        CHECK (([PostalCode] LIKE '[0-9][0-9]-[0-9][0-9][0-9]'
            OR [PostalCode] LIKE '[0-9][0-9][0-9][0-9][0-9]'
            OR [PostalCode] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9]'))


CREATE TABLE [dbo].[Student]
(
    [ParticipantID] [INT]      NOT NULL,
    [StudentID]     [CHAR](10) NOT NULL,
    [Valid]         [Date]     NOT NULL,
    CONSTRAINT [UQ_Student_ParticipantID] UNIQUE NONCLUSTERED ([ParticipantID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
            IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON)
) ON [PRIMARY]
ALTER TABLE [dbo].[Student]
    WITH CHECK ADD CONSTRAINT [FK_Participants_Student] FOREIGN KEY ([ParticipantID])
        REFERENCES [dbo].[Participants] ([ParticipantID])
ALTER TABLE [dbo].[Student]
    CHECK CONSTRAINT [FK_Participants_Student]


CREATE TABLE [dbo].[Conferences]
(
    [ConferenceID] [int] IDENTITY (1,1) NOT NULL,
    [BeginTime]    [date]               NULL,
    [EndTime]      [date]               NULL,
    [Place]        [nvarchar](50)       NULL,
    [Name]         [nvarchar](50)       NOT NULL,
    [isCancelled]  [bit]                NOT NULL DEFAULT 0,
    CONSTRAINT [PK_Conferences] PRIMARY KEY CLUSTERED
        (
         [ConferenceID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [dbo].[Prices]
(
    [PriceID]          [int] IDENTITY (1,1) NOT NULL,
    [ConferenceID]     [int]                NOT NULL,
    [Date]             [date]               NOT NULL,
    [Value]            [money]              NOT NULL,
    [StudentsDiscount] [decimal](3, 2)      NOT NULL,
    CONSTRAINT [PK_Prices] PRIMARY KEY CLUSTERED
        (
         [PriceID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[Prices]
    WITH CHECK ADD CONSTRAINT [FK_Prices_Conferences] FOREIGN KEY ([ConferenceID])
        REFERENCES [dbo].[Conferences] ([ConferenceID])
ALTER TABLE [dbo].[Prices]
    CHECK CONSTRAINT [FK_Prices_Conferences]
ALTER TABLE [dbo].[Prices]
    WITH CHECK ADD CONSTRAINT [CK_StudentsDiscount] CHECK
        (([StudentsDiscount] < (1) AND [StudentsDiscount] >= (0)))
ALTER TABLE [dbo].[Prices]
    CHECK CONSTRAINT [CK_StudentsDiscount]


CREATE TABLE [dbo].[Clients]
(
    [ClientID]   [int] IDENTITY (1,1) NOT NULL,
    [isCompany]  [bit]                NOT NULL DEFAULT 0,
    [Name]       [nvarchar](50)       NOT NULL,
    [EMail]      [varchar](50)        NULL,
    [Password]   [varchar](20)        NOT NULL,
    [Street]     [nvarchar](50)       NULL,
    [PostalCode] [varchar](10)        NULL,
    [City]       [nvarchar](50)       NULL,
    [Country]    [nvarchar](50)       NULL,
    CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED
        (
         [ClientID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
    CONSTRAINT [UniqueEMail_Clients] UNIQUE NONCLUSTERED
        (
         [EMail] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
)
ALTER TABLE [dbo].[Clients]
    WITH CHECK ADD CONSTRAINT [CK_Clients_Email]
        CHECK ((EMail LIKE '%@%.%'))

ALTER TABLE [dbo].[Clients]
    WITH CHECK ADD CONSTRAINT [CK_Clients_PostalCode]
        CHECK (([PostalCode] LIKE '[0-9][0-9]-[0-9][0-9][0-9]'
            OR [PostalCode] LIKE '[0-9][0-9][0-9][0-9][0-9]'
            OR [PostalCode] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9]'))


CREATE TABLE [dbo].[Companies]
(
    [ClientID] [INT]      NOT NULL,
    [NIP]      [CHAR](10) NOT NULL,
    CONSTRAINT [PK_Companies] PRIMARY KEY CLUSTERED ([ClientID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
            IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
    CONSTRAINT [UQ_Companies_NIP] UNIQUE NONCLUSTERED ([NIP] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
            IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[Companies]
    WITH CHECK ADD CONSTRAINT [FK_Clients_Companies] FOREIGN KEY ([ClientID])
        REFERENCES [dbo].[Clients] ([ClientID])


CREATE TABLE [dbo].[ConferenceDays]
(
    [ConferenceDayID] [int] IDENTITY (1,1) NOT NULL,
    [ConferenceID]    [int]                NOT NULL,
    [Place]           [nvarchar](50)       NULL,
    [MaxParticipants] [int]                NOT NULL,
    [Date]            [date]               NOT NULL,
    CONSTRAINT [PK_ConferenceDays] PRIMARY KEY CLUSTERED
        (
         [ConferenceDayID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[ConferenceDays]
    WITH CHECK ADD CONSTRAINT [FK_ConferenceDays_Conferences] FOREIGN
        KEY ([ConferenceID])
        REFERENCES [dbo].[Conferences] ([ConferenceID])
ALTER TABLE [dbo].[ConferenceDays]
    CHECK CONSTRAINT [FK_ConferenceDays_Conferences]
ALTER TABLE [dbo].[ConferenceDays]
    WITH CHECK ADD CONSTRAINT [CK_MaxParticipants] CHECK
        (([MaxParticipants] > (0)))
ALTER TABLE [dbo].[ConferenceDays]
    CHECK CONSTRAINT [CK_MaxParticipants]


CREATE TABLE [dbo].[ConferenceBooking]
(
    [ConferenceBookingID] [int] IDENTITY (1,1) NOT NULL,
    [ConferenceID]        [int]                NOT NULL,
    [ClientID]            [int]                NOT NULL,
    [isCancelled]         [bit]                NOT NULL DEFAULT 0,
    [BookingTime]         [datetime]           NOT NULL,
    CONSTRAINT [PK_ConferenceBooking] PRIMARY KEY CLUSTERED
        (
         [ConferenceBookingID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[ConferenceBooking]
    WITH CHECK ADD CONSTRAINT [FK_ConferenceBooking_Clients] FOREIGN
        KEY ([ClientID])
        REFERENCES [dbo].[Clients] ([ClientID])
ALTER TABLE [dbo].[ConferenceBooking]
    CHECK CONSTRAINT [FK_ConferenceBooking_Clients]
ALTER TABLE [dbo].[ConferenceBooking]
    WITH CHECK ADD CONSTRAINT [FK_ConferenceBooking_Conferences] FOREIGN
        KEY ([ConferenceID])
        REFERENCES [dbo].[Conferences] ([ConferenceID])
ALTER TABLE [dbo].[ConferenceBooking]
    CHECK CONSTRAINT [FK_ConferenceBooking_Conferences]

CREATE TABLE [dbo].[Payments]
(
    [PaymentID]           [int] IDENTITY (1,1) NOT NULL,
    [ConferenceBookingID] [int]                NOT NULL,
    [Value]               [money]              NOT NULL,
    [Time]                [datetime]           NOT NULL,
    [isCancelled]         [bit]                NOT NULL DEFAULT 0,
    CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED
        (
         [PaymentID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[Payments]
    WITH CHECK ADD CONSTRAINT [FK_Payments_ConferenceBooking] FOREIGN
        KEY ([ConferenceBookingID])
        REFERENCES [dbo].[ConferenceBooking] ([ConferenceBookingID])
ALTER TABLE [dbo].[Payments]
    CHECK CONSTRAINT [FK_Payments_ConferenceBooking]

CREATE TABLE [dbo].[ConferenceDayBooking]
(
    [ConferenceDayBookingID] [int]IDENTITY (1,1) NOT NULL,
    [ConferenceBookingID]    [int]               NOT NULL,
    [BookingTime]            [datetime]          NOT NULL,
    [ParticipantsNo]         [int]               NOT NULL,
    [StudentsNo]             [int]               NOT NULL,
    [ConferenceDayID]        [int]               NOT NULL,
    [isCancelled]            [bit]               NOT NULL DEFAULT 0,
    CONSTRAINT [PK_ConferenceDayBooking] PRIMARY KEY CLUSTERED
        (
         [ConferenceDayBookingID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[ConferenceDayBooking]
    WITH CHECK ADD CONSTRAINT [FK_ConferenceDayBooking_ConferenceBooking] FOREIGN
        KEY ([ConferenceBookingID])
        REFERENCES [dbo].[ConferenceBooking] ([ConferenceBookingID])
ALTER TABLE [dbo].[ConferenceDayBooking]
    CHECK CONSTRAINT [FK_ConferenceDayBooking_ConferenceBooking]
ALTER TABLE [dbo].[ConferenceDayBooking]
    WITH CHECK ADD CONSTRAINT [FK_ConferenceDayBooking_ConferenceDays] FOREIGN
        KEY ([ConferenceDayID])
        REFERENCES [dbo].[ConferenceDays] ([ConferenceDayID])
ALTER TABLE [dbo].[ConferenceDayBooking]
    CHECK CONSTRAINT [FK_ConferenceDayBooking_ConferenceDays]
ALTER TABLE [dbo].[ConferenceDayBooking]
    WITH CHECK ADD CONSTRAINT [CK_ParticipantsNo] CHECK
        (([ParticipantsNo] > (0)))
ALTER TABLE [dbo].[ConferenceDayBooking]
    CHECK CONSTRAINT [CK_ParticipantsNo]
ALTER TABLE [dbo].[ConferenceDayBooking]
    WITH CHECK ADD CONSTRAINT [CK_ParticipantsStudentsNo] CHECK
        (([ParticipantsNo] >= [StudentsNo]))
ALTER TABLE [dbo].[ConferenceDayBooking]
    CHECK CONSTRAINT [CK_ParticipantsStudentsNo]
ALTER TABLE [dbo].[ConferenceDayBooking]
    WITH CHECK ADD CONSTRAINT [CK_StudentsNo] CHECK (([StudentsNo] >= (0)))
ALTER TABLE [dbo].[ConferenceDayBooking]
    CHECK CONSTRAINT [CK_StudentsNo]


CREATE TABLE [dbo].[Workshops]
(
    [WorkshopID]      [int] IDENTITY (1,1) NOT NULL,
    [ConferenceDayID] [int]                NOT NULL,
    [Name]            [nvarchar](50)       NOT NULL,
    [BeginTime]       [time](7)            NOT NULL,
    [EndTime]         [time](7)            NOT NULL,
    [Place]           [nvarchar](50)       NULL,
    [Price]           [money]              NULL,
    [MaxParticipants] [int]                NOT NULL,
    CONSTRAINT [PK_Workshops] PRIMARY KEY CLUSTERED
        (
         [WorkshopID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[Workshops]
    WITH CHECK ADD CONSTRAINT [FK_Workshops_ConferenceDays] FOREIGN
        KEY ([ConferenceDayID])
        REFERENCES [dbo].[ConferenceDays] ([ConferenceDayID])
ALTER TABLE [dbo].[Workshops]
    CHECK CONSTRAINT [FK_Workshops_ConferenceDays]
ALTER TABLE [dbo].[Workshops]
    WITH CHECK ADD CONSTRAINT [CK_ParticipansLimit_Workshops] CHECK
        (([MaxParticipants] > (0)))
ALTER TABLE [dbo].[Workshops]
    CHECK CONSTRAINT [CK_ParticipansLimit_Workshops]


CREATE TABLE [dbo].[ConferenceDayParticipants]
(
    [ConfDayParticipantID]   [int]IDENTITY (1,1) NOT NULL,
    [ParticipantID]          [int]               NOT NULL,
    [ConferenceDayBookingID] [int]               NOT NULL,
    [isStudent]              [bit]               NOT NULL DEFAULT 0,
    CONSTRAINT [PK_ConferenceDayParticipants] PRIMARY KEY CLUSTERED
        (
         [ConfDayParticipantID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[ConferenceDayParticipants]
    WITH CHECK ADD CONSTRAINT
        [FK_ConferenceDayParticipants_ConferenceDayBooking] FOREIGN KEY ([ConferenceDayBookingID])
            REFERENCES [dbo].[ConferenceDayBooking] ([ConferenceDayBookingID])
ALTER TABLE [dbo].[ConferenceDayParticipants]
    CHECK CONSTRAINT [FK_ConferenceDayParticipants_ConferenceDayBooking]
ALTER TABLE [dbo].[ConferenceDayParticipants]
    WITH CHECK ADD CONSTRAINT [FK_ConferenceDayParticipants_Participants]
        FOREIGN KEY ([ParticipantID])
            REFERENCES [dbo].[Participants] ([ParticipantID])
ALTER TABLE [dbo].[ConferenceDayParticipants]
    CHECK CONSTRAINT [FK_ConferenceDayParticipants_Participants]


CREATE TABLE [dbo].[WorkshopsBooking]
(
    [WorkshopBookingID]      [int]IDENTITY (1,1) NOT NULL,
    [ConferenceDayBookingID] [int]               NOT NULL,
    [WorkshopID]             [int]               NOT NULL,
    [ParticipantsNo]         [int]               NOT NULL,
    [isCancelled]            [bit]               NOT NULL DEFAULT 0,
    [BookingTime]            [datetime]          NOT NULL,
    CONSTRAINT [PK_WorkshopsBooking] PRIMARY KEY CLUSTERED
        (
         [WorkshopBookingID] ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[WorkshopsBooking]
    WITH CHECK ADD CONSTRAINT [FK_WorkshopsBooking_ConferenceDayBooking]
        FOREIGN KEY ([ConferenceDayBookingID])
            REFERENCES [dbo].[ConferenceDayBooking] ([ConferenceDayBookingID])
ALTER TABLE [dbo].[WorkshopsBooking]
    CHECK CONSTRAINT [FK_WorkshopsBooking_ConferenceDayBooking]
ALTER TABLE [dbo].[WorkshopsBooking]
    WITH CHECK ADD CONSTRAINT [FK_WorkshopsBooking_Workshops] FOREIGN
        KEY ([WorkshopID])
        REFERENCES [dbo].[Workshops] ([WorkshopID])
ALTER TABLE [dbo].[WorkshopsBooking]
    CHECK CONSTRAINT [FK_WorkshopsBooking_Workshops]
ALTER TABLE [dbo].[WorkshopsBooking]
    WITH CHECK ADD CONSTRAINT [CK_ParticipantsNo_WorkshopsBooking]
        CHECK (([ParticipantsNo] > (0)))
ALTER TABLE [dbo].[WorkshopsBooking]
    CHECK CONSTRAINT [CK_ParticipantsNo_WorkshopsBooking]


CREATE TABLE [dbo].[WorkshopParticipants]
(
    [WorkshopBookingID]          [int] NOT NULL,
    [ConferenceDayParticipantID] [int] NOT NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[WorkshopParticipants]
    WITH CHECK ADD CONSTRAINT
        [FK_WorkshopParticipants_ConferenceDayParticipants] FOREIGN KEY ([ConferenceDayParticipantID])
            REFERENCES [dbo].[ConferenceDayParticipants] ([ConfDayParticipantID])
ALTER TABLE [dbo].[WorkshopParticipants]
    CHECK CONSTRAINT [FK_WorkshopParticipants_ConferenceDayParticipants]
ALTER TABLE [dbo].[WorkshopParticipants]
    WITH CHECK ADD CONSTRAINT
        [FK_WorkshopParticipants_WorkshopsBooking] FOREIGN KEY ([WorkshopBookingID])
            REFERENCES [dbo].[WorkshopsBooking] ([WorkshopBookingID])
ALTER TABLE [dbo].[WorkshopParticipants]
    CHECK CONSTRAINT [FK_WorkshopParticipants_WorkshopsBooking]