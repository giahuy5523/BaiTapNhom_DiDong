# Bài tập nhóm Di động Bài tập 01

Hiển thị điện thoại bằng Flutter, lấy dữ liệu từ ASP.NET Core API và SQL Server. Gia Huy phụ trách backend/CSDL; Thanh Sơn phụ trách hai màn Flutter. Project Flutter ở thư mục gốc đã có màn danh sách, màn chi tiết và điều hướng. Mặc định ứng dụng gọi API; có thể bật dữ liệu mẫu bằng --dart-define=USE_MOCK=true.

## Cấu trúc

- `backend/PhoneApi/`: API Controller, EF Core SQL Server, DTO và ảnh tĩnh.
- `database/`: script tạo bảng và dữ liệu 7 điện thoại.
- `docs/`: giao kèo API, JSON mẫu, thiết kế DB, kiểm thử và bàn giao.
- `scripts/`: cấu hình cục bộ, dựng DB, chạy và kiểm thử API.
- `lib/`, `android/`, ...: phần Flutter của Thanh Sơn.

## Yêu cầu

- Windows, .NET SDK 10, SQL Server và công cụ `sqlcmd` có trong PATH.
- SQL Server đang chạy; có tài khoản được phép tạo DB và bảng.
- Flutter và Android Emulator cho phần Thanh Sơn.
- Lần restore đầu cần Internet. Thư viện EF Core được ghim trong csproj; không cần cài Visual Studio để chạy API.

## Chạy backend từ PowerShell

Mở terminal ở thư mục chứa README này.

```powershell
# Nhập tên server và tài khoản của máy đang chạy; mật khẩu sẽ được hỏi kín.
.\scripts\Configure-Local.ps1 -Server 'TEN_MAY_SQL_SERVER' -UserName 'sa'
.\scripts\Setup-Database.ps1
.\scripts\Run-Api.ps1
```

Mặc định DB mới là `PhoneStoreDb`. Có thể truyền `-Database TenDbKhac` cho Configure-Local. Không sử dụng DB chứa dữ liệu quan trọng để thử nghiệm. Khi PowerShell chặn script, có thể chạy từng script bằng `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\TenScript.ps1` (chỉ áp dụng cho tiến trình đó).

Mở `http://localhost:5000/api/phones` và `http://localhost:5000/api/phones/1`. Giữ terminal API chạy; mở terminal thứ hai để kiểm thử:

```powershell
.\scripts\Test-Api.ps1
```

Nếu chỉ muốn build: `dotnet build backend/PhoneApi`. Để khôi phục đúng các phiên bản đã kiểm thử: `dotnet restore backend/PhoneApi --locked-mode`. Dừng API bằng Ctrl+C.

Cấu hình thật nằm ở `backend/PhoneApi/appsettings.Local.json`, đã loại khỏi Git; mỗi máy tự tạo bằng Configure-Local. Không gửi hoặc commit tệp này. Có thể ghi đè bằng biến môi trường `ConnectionStrings__PhoneStore`. Tệp example chỉ chứa placeholder.

## Kết nối Android Emulator

Base URL của Sơn: `http://10.0.2.2:5000`. Đây là địa chỉ máy tính từ trong máy ảo Android. Không dùng `localhost` trong máy ảo. Đọc [giao kèo API](docs/api-contract.md) và [bàn giao](docs/handoff-gia-huy.md) trước khi viết service Flutter. API và ảnh dùng chung cổng 5000.

Nếu không kết nối được, kiểm tra API đang chạy và URL trên máy tính trước; sau đó kiểm tra quyền Internet/HTTP của ứng dụng. Không cần mở SQL Server cho máy ảo: chỉ backend kết nối SQL Server. Với điện thoại thật, cần IP LAN và quyền mạng phù hợp cho tiến trình API.

## Git và phạm vi

Gia Huy: `feature/gia-huy-api-db`. Thanh Sơn: `feature/thanh-son-flutter`. Không sửa cùng lúc tệp chung; review Pull Request trước khi merge vào main. Xem [kiểm thử](docs/test-results.md) để phân biệt backend đã kiểm tra với UI còn chờ Sơn.

Nguồn yêu cầu: Bài tập 01 trang 19, Bai10_Chuong6_XayDungVaSuDungAPI.pdf và bản Word phân công Gia Huy/Thanh Sơn. Không triển khai Bài tập 02, 03 hoặc luồng mua hàng.
