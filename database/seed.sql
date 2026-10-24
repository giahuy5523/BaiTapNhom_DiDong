USE [$(DatabaseName)];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
DECLARE @Sample TABLE (Id INT, Name NVARCHAR(150), Price DECIMAL(18,0), ImagePath NVARCHAR(500), Description NVARCHAR(MAX));
INSERT INTO @Sample VALUES
(1, N'iPhone 15 pro Max', 18000000, N'/images/iphone15promax.jpg', N'iPhone 15 Pro Max là điện thoại cao cấp ra mắt năm 2023. Thiết kế hiện đại, màn hình lớn và hiệu năng mạnh mẽ, phù hợp nhu cầu học tập, làm việc và giải trí.'),
(2, N'iPhone 15', 14000000, N'/images/iphone15.jpg', N'Điện thoại iPhone 15 với thiết kế gọn gàng và màu sắc trẻ trung. Sản phẩm chính hãng, phục vụ liên lạc, chụp ảnh và sử dụng ứng dụng hằng ngày.'),
(3, N'Oppo Reno 10 Pro+', 13000000, N'/images/oppo-reno10-pro-plus.jpg', N'Oppo Reno 10 Pro+ có thiết kế thanh lịch, màn hình lớn và camera phục vụ nhu cầu chụp ảnh. Sản phẩm chính hãng.'),
(4, N'Oppo Reno 11F', 10000000, N'/images/oppo-reno11f.jpg', N'Oppo Reno 11F có kiểu dáng mỏng và màu sắc hiện đại. Phù hợp học tập, giải trí và kết nối hằng ngày. Sản phẩm chính hãng.'),
(5, N'Galaxy 24 Plus', 16500000, N'/images/galaxy24-plus.jpg', N'Samsung Galaxy S24 Plus có màn hình lớn và thiết kế cao cấp, phù hợp làm việc, xem nội dung và chụp ảnh. Sản phẩm chính hãng.'),
(6, N'Xiaomi 14', 12000000, N'/images/xiaomi14.jpg', N'Xiaomi 14 có thiết kế hiện đại và hiệu năng đáp ứng nhiều nhu cầu sử dụng. Sản phẩm chính hãng.'),
(7, N'Xiaomi-Redmi A3', 2500000, N'/images/redmi-a3.jpg', N'Xiaomi Redmi A3 là điện thoại phổ thông phục vụ liên lạc, học tập và giải trí cơ bản. Sản phẩm chính hãng.');
-- Insert missing sample ids only: reruns do not duplicate or overwrite user data.
SET IDENTITY_INSERT dbo.Phones ON;
INSERT INTO dbo.Phones (Id, Name, Price, ImagePath, Description)
SELECT s.Id, s.Name, s.Price, s.ImagePath, s.Description
FROM @Sample s WHERE NOT EXISTS (SELECT 1 FROM dbo.Phones p WHERE p.Id = s.Id);
SET IDENTITY_INSERT dbo.Phones OFF;
COMMIT;
GO
