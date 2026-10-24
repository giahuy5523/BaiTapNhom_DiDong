# Kết quả kiểm thử phần Gia Huy

Ngày kiểm tra: 24/10/2026 (giờ Việt Nam). Môi trường: Windows, .NET SDK 10.0.400, ASP.NET Core 10, EF Core SQL Server 10.0.11, SQL Server cục bộ, DB PhoneStoreDb. Không lưu thông tin đăng nhập trong báo cáo.

## Kết quả backend

| Ca | Dữ liệu hoặc thao tác | Mong đợi | Thực tế |
|---|---|---|---|
| Cấu hình | Configure-Local rồi Setup-Database trên Windows PowerShell | Chuỗi kết nối hợp lệ, schema/seed chạy được | Đạt, mật khẩu không in ra màn hình |
| Build Release | dotnet build --configuration Release --warnaserror | Không lỗi/cảnh báo | Đạt, 0 lỗi và 0 cảnh báo |
| Thư viện | NuGet audit gồm các phụ thuộc gián tiếp | Không có gói bị cảnh báo theo nguồn hiện tại | Đạt; ghim Pkcs 10.0.13 và packages.lock.json |
| T01 | schema.sql, seed.sql trên DB mới | 7 sản phẩm, id 1–7 | Đạt |
| T01 bổ sung | Chạy lại seed | Không trùng, không đổi dữ liệu cũ | Đạt, đối chiếu toàn bộ bản ghi trước/sau |
| T01 ràng buộc | Thử giá -1 và tên chỉ có khoảng trắng trong transaction | SQL từ chối, rollback dữ liệu thử | Đạt |
| T02 | GET /api/phones | 200, đúng 5 trường, id tăng dần | Đạt, 7/7 bản ghi khớp SQL cả tên, giá và mô tả |
| T03 | GET /api/phones/1 đến /7 | 200, chi tiết khớp danh sách | Đạt, so sánh cả 5 trường |
| T04 | id 0, -1, abc, 2147483648, 1.5 | 400 và INVALID_ID | Đạt |
| T04 | id 8 | 404 và PHONE_NOT_FOUND | Đạt |
| Ảnh | Tải 7 imageUrl | 200, image/jpeg và chữ ký JPEG | Đạt |
| T07 phần API | DB tạm chỉ có bảng, chưa có dữ liệu | 200 và [] | Đạt |
| T09 phần API | Xóa bảng trong DB tạm riêng | 500, INTERNAL_ERROR, không lộ stack trace/bí mật | Đạt; DB chính không thay đổi |
| Phạm vi | POST /api/phones | 405 vì không có chức năng ghi | Đạt |
| Android network | Pixel_8 gọi 10.0.2.2:5000 qua HTTP từ trong máy ảo | 7 bản ghi, chi tiết id 1 khớp, ảnh JPEG tải được | Đạt; URL ảnh cũng dùng 10.0.2.2 |

DB kiểm thử tạm được tạo với tên riêng ngẫu nhiên và đã xóa sau khi thử. Không xóa bảng hoặc bản ghi trong DB chính. Phép thử INSERT bị rollback có thể tiêu thụ số IDENTITY; khóa chính không yêu cầu liên tiếp. Có thể chạy lại các kiểm thử endpoint thường dùng bằng `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Api.ps1` khi API đang chạy.

## Dựng lại từ bản clone sạch

Đã clone nhánh từ commit mã nguồn 6a101f4 vào thư mục mới không có appsettings.Local.json. Tạo cấu hình bằng Configure-Local, chạy Setup-Database với DB tạm mới, restore --locked-mode và build Release --warnaserror đều đạt. Khởi động API clone trên cổng 5002 và chạy toàn bộ Test-Api.ps1: tất cả kiểm tra danh sách, chi tiết, giá trị JSON, ảnh, id sai và id không tồn tại đều đạt. Tiến trình API clone đã dừng và DB tạm đã xóa.

Đây là phần backend của T11. Không dùng tệp cấu hình thật đã commit sẵn; cấu hình cục bộ được tạo riêng theo hướng dẫn. Thư mục Flutter không bị sửa trong nhánh Gia Huy.

## Chưa chốt phần Flutter

T05–T08 giao diện, T09 thông báo trên ứng dụng, T10 luồng hai màn Flutter và phần Flutter của T11 chờ Thanh Sơn triển khai. Project Flutter hiện vẫn là ứng dụng mẫu; không đánh dấu các ca này đạt. Việc API truy cập được từ Android không đồng nghĩa UI Flutter đã hoàn thành.
