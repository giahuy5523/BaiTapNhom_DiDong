-- Tạo CSDL và bảng điện thoại cho Bài tập 01, không xóa CSDL hoặc bảng đã có.
-- $(DatabaseName) là biến do sqlcmd thay trước khi gửi SQL; Setup-Database.ps1 kiểm tra tên này.
-- Có thể chạy qua scripts/Setup-Database.ps1; GO là dấu phân lô của công cụ SQL, không phải lệnh T-SQL.
-- Chuyển sang master để tạo CSDL mới; DB_ID trả NULL nếu tên CSDL chưa tồn tại.
USE [master];
GO
IF DB_ID(N'$(DatabaseName)') IS NULL
    EXEC(N'CREATE DATABASE [$(DatabaseName)]');
GO
-- Sau khi có CSDL, chuyển ngữ cảnh để các lệnh tạo bảng chạy đúng nơi.
USE [$(DatabaseName)];
GO
-- Chỉ tạo khi chưa có bảng người dùng dbo.Phones; chạy lại không tạo bảng trùng.
-- Script không tự nâng cấp cấu trúc một bảng đã tồn tại với thiết kế khác.
IF OBJECT_ID(N'dbo.Phones', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Phones
    (
        -- IDENTITY(1,1): bắt đầu từ 1, mỗi lần sinh tăng 1; PRIMARY KEY đảm bảo không trùng và không NULL.
        -- IDENTITY có thể có khoảng trống sau rollback hoặc xóa bản ghi, không phải số thứ tự luôn liên tiếp.
        Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Phones PRIMARY KEY,
        -- NVARCHAR lưu tiếng Việt; NOT NULL ngăn thiếu giá trị. Tên tối đa 150 ký tự.
        Name NVARCHAR(150) NOT NULL,
        -- DECIMAL(18,0) là giá VND chính xác, 18 chữ số và không có phần thập phân.
        Price DECIMAL(18,0) NOT NULL,
        -- Chỉ lưu đường dẫn /images/...; tệp ảnh nằm trong backend để Flutter tải bằng HTTP.
        ImagePath NVARCHAR(500) NOT NULL,
        -- NVARCHAR(MAX) chứa mô tả dài; màn danh sách và chi tiết có thể dùng chung dữ liệu này.
        Description NVARCHAR(MAX) NOT NULL,
        -- CHECK kiểm tra dữ liệu ngay tại SQL Server, kể cả khi chèn bằng công cụ ngoài API.
        -- Giá phải ≥ 0; LTRIM/RTRIM bỏ khoảng trắng đầu cuối để không chấp nhận tên chỉ có khoảng trắng.
        CONSTRAINT CK_Phones_Price CHECK (Price >= 0),
        CONSTRAINT CK_Phones_Name CHECK (LEN(LTRIM(RTRIM(Name))) > 0)
    );
END;
GO
