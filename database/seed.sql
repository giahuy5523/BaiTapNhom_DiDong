-- Thêm 7 điện thoại mẫu; chạy sau schema.sql bằng cùng biến DatabaseName.
-- Sáu mức giá đầu theo hình trang 19; giá Redmi A3 là dữ liệu mẫu vì hình bị cắt mất phần giá.
-- Các chuỗi N'...' là chuỗi Unicode để lưu tên và mô tả tiếng Việt đúng trong SQL Server.
USE [$(DatabaseName)];
GO
-- Không in số dòng bị ảnh hưởng sau từng lệnh, giúp đầu ra chạy script gọn hơn.
SET NOCOUNT ON;
-- Khi có lỗi thực thi trong giao dịch, SQL Server hủy giao dịch để tránh nạp dữ liệu dang dở.
SET XACT_ABORT ON;
-- Gom phần nạp mẫu thành một giao dịch; chỉ xác nhận khi đi đến COMMIT thành công.
BEGIN TRANSACTION;
-- Biến bảng giữ bộ dữ liệu mẫu trong lần chạy này, không tạo thêm bảng cố định trong CSDL.
DECLARE @Sample TABLE (Id INT, Name NVARCHAR(150), Price DECIMAL(18,0), ImagePath NVARCHAR(500), Description NVARCHAR(MAX));
INSERT INTO @Sample VALUES
(1, N'iPhone 15 pro Max', 18000000, N'/images/iphone15promax.jpg', N'iPhone 15 Pro Max là điện thoại cao cấp ra mắt năm 2023. Thiết kế hiện đại, màn hình lớn và hiệu năng mạnh mẽ, phù hợp nhu cầu học tập, làm việc và giải trí.'),
(2, N'iPhone 15', 14000000, N'/images/iphone15.jpg', N'Điện thoại iPhone 15 với thiết kế gọn gàng và màu sắc trẻ trung. Sản phẩm chính hãng, phục vụ liên lạc, chụp ảnh và sử dụng ứng dụng hằng ngày.'),
(3, N'Oppo Reno 10 Pro+', 13000000, N'/images/oppo-reno10-pro-plus.jpg', N'Oppo Reno 10 Pro+ có thiết kế thanh lịch, màn hình lớn và camera phục vụ nhu cầu chụp ảnh. Sản phẩm chính hãng.'),
(4, N'Oppo Reno 11F', 10000000, N'/images/oppo-reno11f.jpg', N'Oppo Reno 11F có kiểu dáng mỏng và màu sắc hiện đại. Phù hợp học tập, giải trí và kết nối hằng ngày. Sản phẩm chính hãng.'),
(5, N'Galaxy 24 Plus', 16500000, N'/images/galaxy24-plus.jpg', N'Samsung Galaxy S24 Plus có màn hình lớn và thiết kế cao cấp, phù hợp làm việc, xem nội dung và chụp ảnh. Sản phẩm chính hãng.'),
(6, N'Xiaomi 14', 12000000, N'/images/xiaomi14.jpg', N'Xiaomi 14 có thiết kế hiện đại và hiệu năng đáp ứng nhiều nhu cầu sử dụng. Sản phẩm chính hãng.'),
(7, N'Xiaomi-Redmi A3', 2500000, N'/images/redmi-a3.jpg', N'Xiaomi Redmi A3 là điện thoại phổ thông phục vụ liên lạc, học tập và giải trí cơ bản. Sản phẩm chính hãng.');
-- Tạm cho phép ghi Id cố định 1–7 dù cột là IDENTITY, để dữ liệu mẫu và JSON bàn giao thống nhất.
-- NOT EXISTS chỉ thêm các id chưa có; không ghi đè bản ghi đã tồn tại, kể cả khi đã được người dùng chỉnh sửa.
SET IDENTITY_INSERT dbo.Phones ON;
INSERT INTO dbo.Phones (Id, Name, Price, ImagePath, Description)
SELECT s.Id, s.Name, s.Price, s.ImagePath, s.Description
FROM @Sample s WHERE NOT EXISTS (SELECT 1 FROM dbo.Phones p WHERE p.Id = s.Id);
-- Tắt chế độ ghi Id thủ công để những lần thêm thông thường tiếp tục dùng cơ chế tự sinh mã.
SET IDENTITY_INSERT dbo.Phones OFF;
-- Xác nhận giao dịch nạp mẫu. Không có lệnh DELETE hoặc UPDATE nên không xóa hay sửa dữ liệu cũ.
COMMIT;
GO
