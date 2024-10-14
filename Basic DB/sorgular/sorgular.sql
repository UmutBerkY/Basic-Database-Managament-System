use ag;
CREATE TABLE Sanatcilar (
    SanatciID INT PRIMARY KEY,
    Ad NVARCHAR(100),
    DogumTarihi DATE,
    OlumTarihi DATE,
    Ulke NVARCHAR(100)
);

CREATE TABLE MuzeCalisanlar (
    GorevliID INT PRIMARY KEY,
    Ad NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20)
);

CREATE TABLE Eserler (
    EserID INT PRIMARY KEY,
    Ad NVARCHAR(100),
    Tur NVARCHAR(50),
    Zaman DATE,
    SanatciID INT,
    Deger DECIMAL(18, 2),
    Durum NVARCHAR(50),
    FOREIGN KEY (SanatciID) REFERENCES Sanatcilar(SanatciID)
);

CREATE TABLE Sergiler (
    SergiID INT PRIMARY KEY,
    Ad NVARCHAR(100),
    BaslangicTarihi DATE,
    BitisTarihi DATE,
    Yer NVARCHAR(100),
    GorevliID INT,
    FOREIGN KEY (GorevliID) REFERENCES MuzeCalisanlar(GorevliID)
);

CREATE TABLE Koleksiyonlar (
    KoleksiyonID INT PRIMARY KEY,
    Ad NVARCHAR(100),
    Aciklama TEXT,
    GorevliID INT,
    FOREIGN KEY (GorevliID) REFERENCES MuzeCalisanlar(GorevliID)
);

CREATE TABLE EserlerinSergileri (
    EserID INT,
    SergiID INT,
    PRIMARY KEY (EserID, SergiID),
    FOREIGN KEY (EserID) REFERENCES Eserler(EserID),
    FOREIGN KEY (SergiID) REFERENCES Sergiler(SergiID)
);

CREATE TABLE EserlerinKoleksiyonlari (
    EserID INT,
    KoleksiyonID INT,
    PRIMARY KEY (EserID, KoleksiyonID),
    FOREIGN KEY (EserID) REFERENCES Eserler(EserID),
    FOREIGN KEY (KoleksiyonID) REFERENCES Koleksiyonlar(KoleksiyonID)
);

CREATE TABLE EserLoglari (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EserID INT,
    Islem NVARCHAR(50),
    IslemTarihi DATETIME DEFAULT GETDATE()
);
GO

-- EserEklemeSonrasi Trigger
CREATE TRIGGER EserEklemeSonrasi
ON Eserler
AFTER INSERT
AS
BEGIN
    INSERT INTO EserLoglari (EserID, Islem, IslemTarihi)
    SELECT i.EserID, 'INSERT', GETDATE()
    FROM inserted i;
END;
GO

-- EserGuncellemeSonrasi Trigger
CREATE TRIGGER EserGuncellemeSonrasi
ON Eserler
AFTER UPDATE
AS
BEGIN
    INSERT INTO EserLoglari (EserID, Islem, IslemTarihi)
    SELECT i.EserID, 'UPDATE', GETDATE()
    FROM inserted i;
END;
GO

CREATE TABLE SergiLoglari (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    SergiID INT,
    Islem NVARCHAR(50),
    IslemTarihi DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER SergiEklemeSonrasi
ON Sergiler
AFTER INSERT
AS
BEGIN
    INSERT INTO SergiLoglari (SergiID, Islem, IslemTarihi)
    SELECT i.SergiID, 'INSERT', GETDATE()
    FROM inserted i;
END;
GO

CREATE TRIGGER SergiGuncellemeSonrasi
ON Sergiler
AFTER UPDATE
AS
BEGIN
    INSERT INTO SergiLoglari (SergiID, Islem, IslemTarihi)
    SELECT i.SergiID, 'UPDATE', GETDATE()
    FROM inserted i;
END;
GO


CREATE PROCEDURE EserGuncelle
    @EserID INT,
    @Ad NVARCHAR(100),
    @Tur NVARCHAR(50),
    @Zaman DATE,
    @SanatciID INT,
    @Deger DECIMAL(18, 2),
    @Durum NVARCHAR(50)
AS
BEGIN
    UPDATE Eserler
    SET Ad = @Ad,
        Tur = @Tur,
        Zaman = @Zaman,
        SanatciID = @SanatciID,
        Deger = @Deger,
        Durum = @Durum
    WHERE EserID = @EserID;
END;
GO

CREATE PROCEDURE EserSil
    @EserID INT
AS
BEGIN
    DELETE FROM Eserler
    WHERE EserID = @EserID;
END;
GO

CREATE VIEW SanatciEserDetaylari AS
SELECT e.EserID, e.Ad AS EserAdi, e.Tur, e.Zaman, e.Deger,
       s.Ad AS SanatciAdi, s.Ulke
FROM Eserler e
JOIN Sanatcilar s ON e.SanatciID = s.SanatciID;

CREATE VIEW SergiDetaylari AS
SELECT se.SergiID, se.Ad AS SergiAdi, se.BaslangicTarihi, se.BitisTarihi, se.Yer,
       mc.Ad AS GorevliAdi, mc.Email, mc.Phone
FROM Sergiler se
JOIN MuzeCalisanlar mc ON se.GorevliID = mc.GorevliID;

CREATE VIEW EserlerinSergiBilgileri AS
SELECT es.EserID, e.Ad AS EserAdi, se.SergiID, se.Ad AS SergiAdi, se.BaslangicTarihi, se.BitisTarihi, se.Yer
FROM EserlerinSergileri es
JOIN Eserler e ON es.EserID = e.EserID
JOIN Sergiler se ON es.SergiID = se.SergiID;

CREATE VIEW KoleksiyonDetaylari AS
SELECT k.KoleksiyonID, k.Ad AS KoleksiyonAdi, k.Aciklama,
       mc.Ad AS GorevliAdi, mc.Email, mc.Phone
FROM Koleksiyonlar k
JOIN MuzeCalisanlar mc ON k.GorevliID = mc.GorevliID;

CREATE VIEW CalisanGorevleri AS
SELECT mc.Ad AS CalisanAdi, mc.Email, mc.Phone, se.Ad AS SergiAdi
FROM MuzeCalisanlar mc
LEFT JOIN Sergiler se ON mc.GorevliID = se.GorevliID;

INSERT INTO Sanatcilar (SanatciID, Ad, DogumTarihi, OlumTarihi, Ulke) VALUES
(1, 'Leonardo da Vinci', '1452-04-15', '1519-05-02', 'Italy'),
(2, 'Vincent van Gogh', '1853-03-30', '1890-07-29', 'Netherlands'),
(3, 'Pablo Picasso', '1881-10-25', '1973-04-08', 'Spain'),
(4, 'Michelangelo Buonarroti', '1475-03-06', '1564-02-18', 'Italy'),
(5, 'Rembrandt van Rijn', '1606-07-15', '1669-10-04', 'Netherlands'),
(6, 'Claude Monet', '1840-11-14', '1926-12-05', 'France'),
(7, 'Raphael', '1483-04-06', '1520-04-06', 'Italy'),
(8, 'Georgia O''Keeffe', '1887-11-15', '1986-03-06', 'USA');

INSERT INTO Eserler (EserID, Ad, Tur, Zaman, SanatciID, Deger, Durum) VALUES
(1, 'Mona Lisa', 'Tablo', '1503-01-01', 1, 1000000000, 'Gösterimde'),
(2, 'The Starry Night', 'Tablo', '1889-01-01', 2, 800000000, 'Gösterimde'),
(3, 'Guernica', 'Tablo', '1937-01-01', 3, 600000000, 'Gösterimde'),
(4, 'David', 'Heykel', '1504-01-01', 4, 1200000000, 'Gösterimde'),
(5, 'Night Watch', 'Tablo', '1642-01-01', 5, 400000000, 'Gösterimde'),
(6, 'Water Lilies', 'Tablo', '1916-01-01', 6, 700000000, 'Gösterimde'),
(7, 'The School of Athens', 'Tablo', '1510-01-01', 7, 900000000, 'Gösterimde'),
(8, 'Sunflower', 'Tablo', '1888-01-01', 2, 600000000, 'Gösterimde');

INSERT INTO Sergiler (SergiID, Ad, BaslangicTarihi, BitisTarihi, Yer, GorevliID) VALUES
(1, 'Ünlü Eserler Retrospektifi', '2024-06-01', '2024-09-30', 'Ana Salon', 1),
(2, 'Modern Sanat Sergisi', '2024-07-01', '2024-10-31', 'Galeri B', 2),
(3, 'Çaðdaþ Heykel Sergisi', '2024-08-01', '2024-11-30', 'Galeri C', 3),
(4, 'Rönesans Dönemi Tablolarý', '2024-09-01', '2024-12-31', 'Galeri A', 4),
(5, 'Surrealist Sanat Eserleri', '2024-10-01', '2025-01-31', 'Galeri B', 5),
(6, 'Impresyonist Sanat Akýmý', '2024-11-01', '2025-02-28', 'Galeri C', 6),
(7, 'Barok Dönemi Eserleri', '2024-12-01', '2025-03-31', 'Galeri A', 1),
(8, 'Postmodern Sanat Sergisi', '2025-01-01', '2025-04-30', 'Galeri B', 2);

INSERT INTO Koleksiyonlar (KoleksiyonID, Ad, Aciklama, GorevliID) VALUES
(1, 'Antik Eserler Koleksiyonu', 'Tarihi antik eserlerden oluþan koleksiyon.', 1),
(2, 'Rönesans Dönemi Koleksiyonu', 'Rönesans dönemine ait eserlerden oluþan koleksiyon.', 2),
(3, 'Modern Sanat Koleksiyonu', 'Modern sanat eserlerinden oluþan koleksiyon.', 3),
(4, 'Ýslam Sanatlarý Koleksiyonu', 'Ýslam sanatýna ait eserlerden oluþan koleksiyon.', 4),
(5, 'Asya Sanat Koleksiyonu', 'Asya sanatýna ait eserlerden oluþan koleksiyon.', 5),
(6, 'Avrupa Resim Koleksiyonu', 'Avrupa ressamlarýnýn eserlerinden oluþan koleksiyon.', 6),
(7, 'Heykel Koleksiyonu', 'Ünlü heykellerden oluþan koleksiyon.', 1),
(8, 'Çaðdaþ Sanat Koleksiyonu', 'Çaðdaþ sanat eserlerinden oluþan koleksiyon.', 2);

INSERT INTO MuzeCalisanlar (GorevliID, Ad, Email, Phone) VALUES
(1, 'Ayþe Kýzýl', 'ayse.kizil@example.com', '123-456-7890'),
(2, 'Mehmet Kara', 'mehmet.kara@example.com', '234-567-8901'),
(3, 'Fatma Yýlmaz', 'fatma.yilmaz@example.com', '345-678-9012'),
(4, 'Mehmet Aða', 'mehmet.aga@example.com', '456-789-0123'),
(5, 'Seda Yýldýz', 'seda.yildiz@example.com', '567-890-1234'),
(6, 'Ali Koç', 'ali.koc@example.com', '678-901-2345');

INSERT INTO EserlerinSergileri (EserID, SergiID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8);

INSERT INTO EserlerinKoleksiyonlari (EserID, KoleksiyonID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8);

CREATE OR ALTER PROCEDURE SorguSiralama
    @Sorgu NVARCHAR(MAX),
    @SiralamaKriteri NVARCHAR(100)
AS
BEGIN
    DECLARE @Sql NVARCHAR(MAX);
    SET @Sql = @Sorgu + ' ORDER BY ' + @SiralamaKriteri;
    EXEC sp_executesql @Sql;
END;
GO


--Sorgu 1,2
EXEC SorguSiralama 'SELECT * FROM Eserler', 'Zaman ASC';
EXEC SorguSiralama 'SELECT * FROM Eserler WHERE Durum = ''Gösterimde''', 'Deger DESC';

--Sorgu 3
SELECT * FROM Eserler
ORDER BY Zaman ASC;

--Sorgu 4
SELECT Tur,Sum(Deger) AS ToplamDeger
FROM Eserler
GROUP BY Tur;

--Sorgu 5
UPDATE Eserler
SET Ad='Mona Lisa', Tur='Tablo'
WHERE EserID=1;

--Sorgu 6
INSERT INTO Eserler (EserID,Ad,Tur,Zaman,SanatciID,Deger,Durum)
VALUES (10,'deneme','para','2024-02-02','7','10000.00','Depoda');

--Sorgu 7
DELETE FROM Eserler WHERE EserID=9;

--Sorgu 8
EXEC EserEkle 
    @EserID = 9, 
    @Ad = N'New Artwork', 
    @Tur = N'Tablo', 
    @Zaman = '2024-01-01', 
    @SanatciID = 1, 
    @Deger = 500000.00, 
    @Durum = N'Gösterimde';

--Sorgu 9
EXEC EserSil 
    @EserID = 9;

--Sorgu 10,11
SELECT * FROM KoleksiyonDetaylari;
SELECT * FROM SergiDetaylari;

--Sorgu 12
SELECT s.SanatciID, s.Ad AS SanatciAdi, COUNT(e.EserID) AS ToplamEser
FROM Sanatcilar s
LEFT JOIN Eserler e ON s.SanatciID = e.SanatciID
GROUP BY s.SanatciID, s.Ad
ORDER BY ToplamEser DESC;

--Sorgu 13
SELECT Sanatcilar.Ad AS SanatciAdi, Eserler.Ad AS EserAdi
FROM Sanatcilar
JOIN Eserler ON Sanatcilar.SanatciID = Eserler.SanatciID;

--Sorgu 14
SELECT * FROM EserlerinSergiBilgileri;