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

## Kiểm tra sau sửa lỗi toàn dự án

Ngày 24/10/2026. Đã sửa các mục QA01–QA05 trong báo cáo tester: hai nút tải lại, URL có dấu / cuối, lỗi ánh xạ JSON, mẫu Redmi A3 và tài liệu tên nhánh/trạng thái kiểm thử.

| Kiểm tra | Kết quả |
|---|---|
| Flutter analyze | Đạt, không có vấn đề |
| Flutter test | 23/23 đạt |
| Ba ca trước đây lỗi setState | Đạt: danh sách rỗng/tải lại, mất mạng/thử lại, chi tiết lỗi/thử lại |
| JSON sai root hoặc thiếu trường | Đạt, trả BAD_RESPONSE thay vì để TypeError lọt ra |
| Base URL có/không có dấu / cuối và khoảng trắng ngoài | Đạt, endpoint không bị ghép thành //api/phones |
| Mã lỗi HTTP 400/404/500 | Đạt, giữ code và status cho giao diện |
| HTTP trả lỗi không phải JSON, timeout, mất kết nối | Đạt |
| Dữ liệu mock | Đạt, dùng chung JSON bàn giao, gồm giá Redmi A3 2.500.000 đ |
| Backend Release warnaserror | Đạt, 0 lỗi và 0 cảnh báo |

Bộ test mới nằm tại test/phone_states_test.dart và test/phone_service_test.dart; giữ bài điều hướng tại test/widget_test.dart. Việc từng ghi lỗi LICENSE của Pub cache không còn là trạng thái hiện tại: toàn bộ flutter test đã chạy thành công trên máy này.

Ổ D từng hết dung lượng khi build APK. Đã thêm scripts/Use-BuildDirectory.ps1 để ghi phần build lớn sang thư mục còn chỗ bằng junction; không xóa tệp cá nhân và không thay đổi vị trí source. Đã phục hồi cache Gradle bị khóa sau lỗi đầy ổ và build APK debug thành công từ chính project ổ D, với thư mục build thực tế trên ổ C. Service/model Flutter thật tiếp tục đọc đủ 7 sản phẩm và ảnh qua API/SQL; URL base có dấu / cuối đã gọi thành công. Trạng thái kiểm tra trực tiếp thiết bị được ghi riêng bên dưới.

### Kiểm tra APK trên Pixel 8

Đã cài APK debug vừa build và khởi chạy trên phiên Pixel_8 tạm, không ghi thay đổi lên dữ liệu máy ảo gốc. Cây trợ năng của ứng dụng ghi nhận đủ 7 tên điện thoại, mô tả và giá theo dữ liệu SQL thật, trong đó Redmi A3 2.500.000 đ. Không phát hiện ngoại lệ Flutter/AndroidRuntime trong lần kiểm tra log ứng dụng này.

Ảnh chụp từ phiên máy ảo chạy ẩn chỉ có nền đen/thanh hệ thống; chưa xác định đầy đủ phần hiển thị đồ họa và thao tác chạm ở chế độ này. Không dùng ảnh đó làm minh chứng giao diện và không đánh dấu luồng chạm hai màn trên thiết bị là đạt. Luồng điều hướng, quay lại và phục hồi lỗi đã được kiểm chứng trong widget test. Cần mở máy ảo bình thường để xác nhận trực quan cuối cùng khi demo.

### Khắc phục màn hình đen của Pixel 8

Đã tái hiện màn hình đen trên cửa sổ máy ảo bình thường, nên giới hạn trước đó không chỉ là vấn đề chụp ảnh của phiên chạy ẩn. Kiểm tra thấy Pixel_8 dùng Graphics auto, Android 37.1. Thử tắt Impeller riêng vẫn đen. Cold boot với Graphics software đã phục hồi hình ảnh danh sách cùng ảnh thật và mở được chi tiết iPhone 15 pro Max bằng thao tác chạm. Đã lưu cấu hình Software/Cold Boot cục bộ và giữ nguyên dữ liệu AVD. Không sửa renderer trong mã ứng dụng cho mọi thiết bị.

Kiểm chứng sau khi lưu cấu hình và khởi động lại: Graphics software được đọc từ config.ini, không truyền GPU override. Ảnh chụp thật đã hiện thanh tiêu đề xanh, nội dung danh sách và ảnh điện thoại. Đã thao tác vào iPhone 15 pro Max (18.000.000 đ), quay lại bằng nút trên giao diện, mở iPhone 15 (14.000.000 đ) rồi quay lại danh sách; tất cả đạt với API/SQL thật. Giới hạn màn hình đen và thao tác chạm đã ghi ở mục trước nay đã được xử lý trên máy demo này.
