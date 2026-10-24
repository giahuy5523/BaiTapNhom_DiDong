# Giao kèo API điện thoại

Phạm vi: Bài tập 01 trang 19, chỉ đọc danh sách và chi tiết. Gia Huy phụ trách DB/API; Thanh Sơn phụ trách Flutter. Bản giao kèo này thực hiện đúng cấu trúc Word đã gửi, có thể dùng ngay để làm song song.

## Địa chỉ

- Máy tính: `http://localhost:5000`.
- Android Emulator Pixel 8: `http://10.0.2.2:5000`.
- Điện thoại thật: thay bằng IP LAN máy chạy API, cùng mạng.
- API lắng nghe `0.0.0.0:5000`. Không dùng địa chỉ này làm base URL của ứng dụng.

## Endpoint

| Request | HTTP | Body |
|---|---|---|
| `GET /api/phones` | 200 | Mảng Phone, id tăng dần; rỗng là `[]` |
| `GET /api/phones/{id}` | 200 | Một Phone |
| Id không phải số nguyên dương hoặc vượt Int32 | 400 | `{ "code": "INVALID_ID", "message": "Mã điện thoại phải là số nguyên dương." }` |
| Id hợp lệ nhưng chưa có | 404 | `{ "code": "PHONE_NOT_FOUND", "message": "Không tìm thấy điện thoại." }` |
| DB hoặc máy chủ gặp lỗi | 500 | `{ "code": "INTERNAL_ERROR", "message": "Không thể tải dữ liệu. Vui lòng thử lại sau." }` |

JSON UTF-8, camelCase, không bọc `data/items`. Tất cả 5 trường có mặt và không null.

| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| id | integer | Số nguyên dương, khóa chính |
| name | string | Tên sản phẩm |
| price | number | Giá VND; không có ký hiệu tiền hoặc dấu phân cách |
| imageUrl | string | URL JPEG tuyệt đối, gọi trực tiếp được |
| description | string | Mô tả đầy đủ; Flutter tự rút gọn ở danh sách |

Mẫu đầy đủ: [danh sách](samples/phones.json), [chi tiết](samples/phone-detail.json). `imageUrl` mẫu dùng máy ảo; API thật tạo URL theo host gọi vào. Không thay host bằng localhost trong Flutter. Khi tạo URL chi tiết, truyền `id`, không truyền tên hoặc chỉ số của dòng.

## Bàn giao cho Sơn

1. Dùng mẫu trong `docs/samples/` để dựng hai màn độc lập.
2. Model Dart: `price` đọc bằng `(json['price'] as num).toDouble()` nếu chọn double. Giá hiển thị VND bằng Flutter.
3. Gọi danh sách, chọn id, gọi endpoint chi tiết. Xử lý tải, trống, lỗi, thử lại và ảnh lỗi.
4. Android cần `<uses-permission android:name="android.permission.INTERNET" />`. Với HTTP khi phát triển, thêm `android:usesCleartextTraffic="true"` vào application của manifest phát triển phù hợp; không mặc định mở HTTP cho bản phát hành.
5. Chạy từ project gốc: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000`. Sơn cần đọc biến bằng `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:5000')`.
6. Backend không yêu cầu token; không có chức năng thêm/sửa/xóa sản phẩm trong Bài tập 01.

Android native không cần CORS. Nếu về sau chạy Chrome, đặt đúng origin tại `Cors:AllowedOrigins` trong cấu hình cục bộ; không dùng wildcard tùy tiện.
