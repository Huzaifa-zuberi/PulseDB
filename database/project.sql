/* =====================================================================
   PULSEDB  -  Music Streaming Platform
   SQL Server Backend  -  Full Schema + Data + Queries + Views
   ===================================================================== */

-- =====================================================================
-- SECTION 1 - DATABASE & TABLES (CLO 1 - PK, FK, Constraints)
-- =====================================================================

CREATE TABLE [User] (
    UserID      INT          PRIMARY KEY,
    Username    VARCHAR(50)  NOT NULL UNIQUE,
    Email       VARCHAR(100) NOT NULL UNIQUE,
    Country     VARCHAR(50)  NOT NULL,
    PlanType    VARCHAR(10)  NOT NULL DEFAULT 'Free'
                CHECK (PlanType IN ('Free','Premium')),
    JoinDate    DATE         NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Artist (
    ArtistID         INT         PRIMARY KEY,
    StageName        VARCHAR(80) NOT NULL,
    Genre            VARCHAR(40) NOT NULL,
    Country          VARCHAR(50) NOT NULL,
    MonthlyListeners INT         NOT NULL DEFAULT 0
                     CHECK (MonthlyListeners >= 0)
);

CREATE TABLE Song (
    SongID      INT          PRIMARY KEY,
    Title       VARCHAR(100) NOT NULL,
    ArtistID    INT          NOT NULL,
    Album       VARCHAR(80)  NULL,
    Duration    INT          NOT NULL CHECK (Duration > 0),
    ReleaseDate DATE         NULL,
    Language    VARCHAR(30)  NOT NULL DEFAULT 'English',
    CONSTRAINT FK_Song_Artist FOREIGN KEY (ArtistID)
        REFERENCES Artist(ArtistID)
);

CREATE TABLE Playlist (
    PlaylistID   INT          PRIMARY KEY,
    UserID       INT          NOT NULL,
    PlaylistName VARCHAR(80)  NOT NULL,
    IsPublic     BIT          NOT NULL DEFAULT 1,
    CreatedDate  DATE         NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Playlist_User FOREIGN KEY (UserID)
        REFERENCES [User](UserID)
);

CREATE TABLE StreamHistory (
    StreamID   INT       PRIMARY KEY,
    UserID     INT       NOT NULL,
    SongID     INT       NOT NULL,
    StreamedAt DATETIME  NOT NULL DEFAULT GETDATE(),
    DeviceType VARCHAR(15) NOT NULL
               CHECK (DeviceType IN ('Mobile','Desktop','Tablet','Web')),
    CONSTRAINT FK_Stream_User FOREIGN KEY (UserID)
        REFERENCES [User](UserID),
    CONSTRAINT FK_Stream_Song FOREIGN KEY (SongID)
        REFERENCES Song(SongID)
);
GO

-- =====================================================================
-- SECTION 2 - SAMPLE DATA (CLO 1 - 10+ rows per table)
-- =====================================================================

INSERT INTO [User] (UserID, Username, Email, Country, PlanType, JoinDate) VALUES
 (1 ,'Jawwad' ,'jawwad@mail.com'  ,'Pakistan','Premium','2025-01-10'),
 (2 ,'Huzaifa' ,'huzaifa@mail.com'  ,'USA'     ,'Free'   ,'2025-02-14'),
 (3 ,'Riaz'  ,'riaz@mail.com'   ,'UK'      ,'Premium','2025-03-01'),
 (4 ,'Uzair'  ,'uzair@mail.com'   ,'Japan'   ,'Premium','2025-03-22'),
 (5 ,'emma_l'  ,'emma@mail.com'   ,'Canada'  ,'Free'   ,'2025-04-05'),
 (6 ,'carlos_m','carlos@mail.com' ,'Spain'   ,'Premium','2025-04-18'),
 (7 ,'fatima_a','fatima@mail.com' ,'Pakistan','Free'   ,'2025-05-09'),
 (8 ,'john_d'  ,'john@mail.com'   ,'USA'     ,'Premium','2025-05-21'),
 (9 ,'lena_s'  ,'lena@mail.com'   ,'Germany' ,'Free'   ,'2025-06-02'),
 (10,'raj_p'   ,'raj@mail.com'    ,'India'   ,'Premium','2025-06-15'),
 (11,'nora_b'  ,'nora@mail.com'   ,'France'  ,'Free'   ,'2025-07-01'),
 (12,'tom_h'   ,'tom@mail.com'    ,'UK'      ,'Premium','2025-07-12');

INSERT INTO Artist (ArtistID, StageName, Genre, Country, MonthlyListeners) VALUES
 (1 ,'Luna Ray'          ,'Pop'       ,'USA'     ,4200000),
 (2 ,'The Midnight Echo' ,'Rock'      ,'UK'      ,2100000),
 (3 ,'Zara Khan'         ,'Pop'       ,'Pakistan',1800000),
 (4 ,'DJ Volt'           ,'Electronic','Germany' ,3300000),
 (5 ,'Marcus Stone'      ,'Hip-Hop'   ,'USA'     ,2750000),
 (6 ,'Aria Blue'         ,'R&B'       ,'Canada'  ,1500000),
 (7 ,'The Velvet Keys'   ,'Jazz'      ,'France'  , 620000),
 (8 ,'Kai Tanaka'        ,'Electronic','Japan'   ,1950000),
 (9 ,'Sofia Lopez'       ,'Latin'     ,'Spain'   ,2400000),
 (10,'Ethan Wells'       ,'Country'   ,'USA'     , 880000),
 (11,'Nova Beats'        ,'Hip-Hop'   ,'UK'      ,1320000),
 (12,'Vienna Strings'    ,'Classical' ,'Austria' , 310000);

INSERT INTO Song (SongID, Title, ArtistID, Album, Duration, ReleaseDate, Language) VALUES
 (1 ,'Midnight Sky'   ,1 ,'Neon Dreams'   ,212,'2025-01-15','English'),
 (2 ,'Golden Hour'    ,1 ,'Neon Dreams'   ,198,'2025-01-15','English'),
 (3 ,'Electric Dreams',2 ,'Voltage'       ,245,'2024-11-20','English'),
 (4 ,'Thunder Road'   ,2 ,'Voltage'       ,260,'2024-11-20','English'),
 (5 ,'Dil Se'         ,3 ,'Roohi'         ,230,'2025-02-10','Urdu'   ),
 (6 ,'Voltage'        ,4 ,'Circuit'       ,205,'2025-03-05','English'),
 (7 ,'Bass Drop'      ,4 ,'Circuit'       ,189,'2025-03-05','English'),
 (8 ,'City Lights'    ,5 ,'Concrete'      ,221,'2025-01-28','English'),
 (9 ,'Ocean Eyes'     ,6 ,'Tides'         ,236,'2025-02-22','English'),
 (10,'Smooth Sailing' ,7 ,'Late Night'    ,300,'2024-12-12','English'),
 (11,'Neon Tokyo'     ,8 ,'Shibuya'       ,214,'2025-04-01','Japanese'),
 (12,'Corazon'        ,9 ,'Fuego'         ,201,'2025-03-18','Spanish'),
 (13,'Open Road'      ,10,'Highway 9'     ,255,'2025-02-05','English'),
 (14,'Rhyme Time'     ,11,'Cipher'        ,193,'2025-04-10','English'),
 (15,'Symphony No.5'  ,12,'Masterworks'   ,420,'2024-10-30','Instrumental'),
 (16,'Pardes'         ,3 ,'Roohi'         ,215,'2025-02-10','Urdu'   );

INSERT INTO Playlist (PlaylistID, UserID, PlaylistName, IsPublic, CreatedDate) VALUES
 (1 ,1 ,'Morning Vibes' ,1,'2025-05-01'),
 (2 ,2 ,'Workout Mix'   ,1,'2025-05-03'),
 (3 ,3 ,'Chill Beats'   ,0,'2025-05-05'),
 (4 ,4 ,'Tokyo Nights'  ,1,'2025-05-07'),
 (5 ,5 ,'Study Focus'   ,0,'2025-05-09'),
 (6 ,6 ,'Latin Heat'    ,1,'2025-05-11'),
 (7 ,7 ,'Desi Hits'     ,1,'2025-05-13'),
 (8 ,8 ,'Road Trip'     ,1,'2025-05-15'),
 (9 ,9 ,'Deep House'    ,0,'2025-05-17'),
 (10,10,'Bollywood Gold',1,'2025-05-19'),
 (11,11,'Jazz Cafe'     ,1,'2025-05-21'),
 (12,12,'Rock Legends'  ,0,'2025-05-23');

INSERT INTO StreamHistory (StreamID, UserID, SongID, StreamedAt, DeviceType) VALUES
 (1 ,1 ,1 ,'2026-06-14 08:30','Mobile'),
 (2 ,1 ,1 ,'2026-06-14 18:00','Desktop'),
 (3 ,1 ,5 ,'2026-06-13 09:00','Mobile'),
 (4 ,1 ,2 ,'2026-06-12 22:00','Mobile'),
 (5 ,1 ,1 ,'2026-06-11 07:45','Mobile'),
 (6 ,1 ,5 ,'2026-06-10 12:00','Tablet'),
 (7 ,2 ,3 ,'2026-06-14 14:00','Web'),
 (8 ,2 ,8 ,'2026-06-13 16:00','Desktop'),
 (9 ,2 ,1 ,'2026-06-12 10:00','Mobile'),
 (10,3 ,3 ,'2026-06-14 20:00','Desktop'),
 (11,3 ,4 ,'2026-06-13 21:00','Mobile'),
 (12,3 ,14,'2026-06-11 19:00','Mobile'),
 (13,4 ,11,'2026-06-14 23:00','Mobile'),
 (14,4 ,6 ,'2026-06-13 22:30','Desktop'),
 (15,4 ,11,'2026-06-12 23:00','Mobile'),
 (16,5 ,9 ,'2026-06-14 11:00','Tablet'),
 (17,5 ,1 ,'2026-06-13 11:00','Mobile'),
 (18,6 ,12,'2026-06-14 13:00','Mobile'),
 (19,6 ,12,'2026-06-12 13:00','Mobile'),
 (20,8 ,8 ,'2026-06-14 17:00','Desktop'),
 (21,8 ,1 ,'2026-06-13 17:30','Mobile'),
 (22,8 ,13,'2026-06-10 15:00','Mobile'),
 (23,10,5 ,'2026-06-14 09:30','Mobile'),
 (24,10,7 ,'2026-06-13 09:30','Desktop'),
 (25,7 ,16,'2026-06-14 10:15','Mobile');
GO

-- =====================================================================
-- SECTION 3 - FEATURE QUERIES (CLO 2 - JOIN / GROUP BY / HAVING / Subquery)
-- =====================================================================

/* Q1 - Browse Library */
SELECT s.SongID, s.Title, a.StageName AS Artist, a.Genre, s.Language
FROM Song s
JOIN Artist a ON s.ArtistID = a.ArtistID
ORDER BY a.StageName, s.Title;

/* Q2 - Trending Now (Top 5) */
SELECT TOP 5 s.Title, a.StageName AS Artist, COUNT(*) AS TotalStreams
FROM StreamHistory sh
JOIN Song s   ON sh.SongID = s.SongID
JOIN Artist a ON s.ArtistID = a.ArtistID
GROUP BY s.Title, a.StageName
ORDER BY TotalStreams DESC;

/* Q3 - Power Listeners (3+ streams) */
SELECT u.Username, u.Country, COUNT(*) AS StreamCount
FROM StreamHistory sh
JOIN [User] u ON sh.UserID = u.UserID
GROUP BY u.Username, u.Country
HAVING COUNT(*) >= 3
ORDER BY StreamCount DESC;

/* Q4 - Prolific Artists (more than 1 song) */
SELECT a.StageName, a.Genre, COUNT(s.SongID) AS SongCount
FROM Artist a
JOIN Song s ON a.ArtistID = s.ArtistID
GROUP BY a.StageName, a.Genre
HAVING COUNT(s.SongID) > 1;

/* Q5 - Most popular genre by total streams */
SELECT a.Genre, COUNT(*) AS TotalStreams
FROM StreamHistory sh
JOIN Song s   ON sh.SongID = s.SongID
JOIN Artist a ON s.ArtistID = a.ArtistID
GROUP BY a.Genre
ORDER BY TotalStreams DESC;

/* Q6 - Hidden Gems (never streamed) */
SELECT s.Title, a.StageName AS Artist
FROM Song s
JOIN Artist a ON s.ArtistID = a.ArtistID
WHERE s.SongID NOT IN (SELECT SongID FROM StreamHistory);

/* Q7 - Above-average hits */
SELECT s.Title, COUNT(*) AS Streams
FROM StreamHistory sh
JOIN Song s ON sh.SongID = s.SongID
GROUP BY s.Title
HAVING COUNT(*) > (
    SELECT AVG(playCount) FROM (
        SELECT COUNT(*) AS playCount
        FROM StreamHistory
        GROUP BY SongID
    ) AS perSong
);

/* Q8 - Personalized recommendations for user 1 */
SELECT s.Title, a.StageName AS Artist, a.Genre
FROM Song s
JOIN Artist a ON s.ArtistID = a.ArtistID
WHERE a.Genre = (
    SELECT TOP 1 a2.Genre
    FROM StreamHistory sh2
    JOIN Song s2   ON sh2.SongID = s2.SongID
    JOIN Artist a2 ON s2.ArtistID = a2.ArtistID
    WHERE sh2.UserID = 1
    GROUP BY a2.Genre
    ORDER BY COUNT(*) DESC
)
AND s.SongID NOT IN (
    SELECT SongID FROM StreamHistory WHERE UserID = 1
);

/* Q9 - Public playlists */
SELECT p.PlaylistName, u.Username AS Owner, p.CreatedDate
FROM Playlist p
JOIN [User] u ON p.UserID = u.UserID
WHERE p.IsPublic = 1
ORDER BY p.CreatedDate;

/* Q10 - Device usage breakdown */
SELECT DeviceType, COUNT(*) AS Plays
FROM StreamHistory
GROUP BY DeviceType
ORDER BY Plays DESC;

/* Q11 - Premium vs Free activity */
SELECT u.PlanType, COUNT(*) AS TotalStreams
FROM StreamHistory sh
JOIN [User] u ON sh.UserID = u.UserID
GROUP BY u.PlanType;
GO

-- =====================================================================
-- SECTION 4 - VIEWS (CLO 2 - Reusable product features)
-- =====================================================================

CREATE VIEW vw_TrendingSongs AS
SELECT s.SongID, s.Title, a.StageName AS Artist, a.Genre,
       COUNT(sh.StreamID) AS TotalStreams
FROM Song s
JOIN Artist a        ON s.ArtistID = a.ArtistID
LEFT JOIN StreamHistory sh ON s.SongID = sh.SongID
GROUP BY s.SongID, s.Title, a.StageName, a.Genre;
GO

CREATE VIEW vw_ArtistDashboard AS
SELECT a.ArtistID, a.StageName, a.Genre, a.MonthlyListeners,
       COUNT(DISTINCT s.SongID)   AS SongCount,
       COUNT(sh.StreamID)         AS TotalStreams
FROM Artist a
LEFT JOIN Song s          ON a.ArtistID = s.ArtistID
LEFT JOIN StreamHistory sh ON s.SongID  = sh.SongID
GROUP BY a.ArtistID, a.StageName, a.Genre, a.MonthlyListeners;
GO

CREATE VIEW vw_PublicPlaylists AS
SELECT p.PlaylistID, p.PlaylistName, u.Username AS Owner,
       u.Country, p.CreatedDate
FROM Playlist p
JOIN [User] u ON p.UserID = u.UserID
WHERE p.IsPublic = 1;
GO

SELECT * FROM vw_TrendingSongs   ORDER BY TotalStreams DESC;
SELECT * FROM vw_ArtistDashboard ORDER BY TotalStreams DESC;
SELECT * FROM vw_PublicPlaylists ORDER BY CreatedDate;
GO

/* ===========================  END OF SCRIPT  ======================== */
