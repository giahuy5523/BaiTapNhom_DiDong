# Bàn giao phần Gia Huy cho Thanh Sơn

## Dùng ngay để làm song song

- Repo giữ Flutter ở gốc, không chuyển vào mobile để tránh làm hỏng project hiện có.
- Giao kèo: `docs/api-contract.md`; mẫu: `docs/samples/phones.json`, `phone-detail.json`.
- Base URL Android Emulator: `http://10.0.2.2:5000`.
- Danh sách: GET `/api/phones`; chi tiết: GET `/api/phones/{id}`.
- 5 trường: id, name, price, imageUrl, description. Giá là số VND; ảnh URL tuyệt đối.
- Code hai phần đã gộp trên `main`. Nhánh làm việc trước đó: Gia Huy `feature/gia-huy-api-db`, Thanh Sơn `thanh-son`. Lưu thay đổi cục bộ trước khi chuyển nhánh/pull.

## Phần Gia Huy

CSDL, dữ liệu 7 sản phẩm, EF Core DbContext, hai API, lỗi JSON, phục vụ ảnh, cấu hình mẫu và script chạy/kiểm thử. Kết quả kiểm tra thực tế ghi trong `test-results.md`. Đã thử từ Pixel_8 tới 10.0.2.2:5000, nhận danh sách, chi tiết và ảnh thành công.

## Phần Thanh Sơn

Flutter hiện có model/service HTTP, màn danh sách và chi tiết, điều hướng, định dạng tiền, trạng thái tải/trống/lỗi; cấu hình HTTP chỉ áp dụng cho bản Android debug. Đã có kiểm thử hồi quy cho T05–T09 và sửa lỗi nút thử lại, JSON sai cấu trúc, dấu / cuối base URL; xem test-results.md. Cần phân biệt widget/service test với nghiệm thu hai màn trên thiết bị.

## Mốc tích hợp

Huy chạy DB/API trên máy demo; Sơn chạy Flutter với API mặc định, thử hai id khác nhau, xem ảnh và quay lại. Cả hai đối chiếu với DB, ghi kết quả và chụp hai màn. Chỉ xác nhận hoàn tất sau khi các ca Flutter và clone sạch đều đạt.
