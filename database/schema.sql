-- Run with sqlcmd -b -f 65001 -v DatabaseName="PhoneStoreDb" -i database/schema.sql
-- DatabaseName must be a simple identifier; Setup-Database.ps1 validates it.
USE [master];
GO
IF DB_ID(N'$(DatabaseName)') IS NULL
    EXEC(N'CREATE DATABASE [$(DatabaseName)]');
GO
USE [$(DatabaseName)];
GO
IF OBJECT_ID(N'dbo.Phones', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Phones
    (
        Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Phones PRIMARY KEY,
        Name NVARCHAR(150) NOT NULL,
        Price DECIMAL(18,0) NOT NULL,
        ImagePath NVARCHAR(500) NOT NULL,
        Description NVARCHAR(MAX) NOT NULL,
        CONSTRAINT CK_Phones_Price CHECK (Price >= 0),
        CONSTRAINT CK_Phones_Name CHECK (LEN(LTRIM(RTRIM(Name))) > 0)
    );
END;
GO
