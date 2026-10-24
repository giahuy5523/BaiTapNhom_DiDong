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

## Chạy Flutter và kiểm thử

Chạy backend ở terminal riêng, mở Pixel 8 rồi chạy từ project gốc:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

Ứng dụng mặc định gọi API thật. Chế độ mẫu: `flutter run --dart-define=USE_MOCK=true`. Dữ liệu mẫu dùng chung `docs/samples/phones.json`, đã đóng gói làm asset; ảnh vẫn lấy từ backend và có ảnh thay thế nếu chưa chạy backend. Không còn một bộ giá/mô tả riêng nằm trong service mock.

Kiểm tra mã và toàn bộ hồi quy:

```powershell
flutter analyze
flutter test
```

Có kiểm thử cho điều hướng, tải/trống/lỗi/thử lại, ảnh hỏng, cỡ chữ lớn, định dạng tiền, JSON sai, lỗi HTTP/mạng, URL có dấu / cuối và dữ liệu mẫu.

## Khi ổ chứa project không đủ chỗ build

Trên Windows, có thể chuyển riêng tệp build sinh tự động sang thư mục ở ổ khác:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Use-BuildDirectory.ps1
flutter build apk --debug
```

Mặc định script dùng thư mục `Documents/Codex/BuildCache/BaiTapNhom_DiDong` của tài khoản hiện tại. Có thể chọn đích bằng `-Directory 'C:\duong-dan-build'`. Kiểm tra đích nằm trên ổ còn dung lượng. Script tạo junction tại `project/build`, không di chuyển mã nguồn và không đổi cấu hình Flutter toàn máy. Nếu đã có build cũ, chạy `flutter clean` rồi thực hiện lại script. Sau những lần `flutter clean` khác, cần chạy lại script nếu junction bị xóa. Thư mục build vẫn được Git bỏ qua. Các cache nhỏ của Gradle/Dart có thể vẫn ở ổ project; vẫn cần giữ dung lượng trống cho hệ điều hành và công cụ.

## Git và phạm vi

Gia Huy: `feature/gia-huy-api-db`. Thanh Sơn: `thanh-son`. Không sửa cùng lúc tệp chung; review Pull Request trước khi merge vào main. Xem [kiểm thử](docs/test-results.md) để xem kết quả backend, Flutter và những bước cần xác nhận trên thiết bị.

Nguồn yêu cầu: Bài tập 01 trang 19, Bai10_Chuong6_XayDungVaSuDungAPI.pdf và bản Word phân công Gia Huy/Thanh Sơn. Không triển khai Bài tập 02, 03 hoặc luồng mua hàng.
