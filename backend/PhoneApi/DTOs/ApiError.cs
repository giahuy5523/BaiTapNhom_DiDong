// Mẫu JSON lỗi thống nhất cho Flutter: code để phân loại lỗi, message để hiển thị thông báo.
// Mã HTTP vẫn được Controller hoặc bộ xử lý ngoại lệ đặt riêng; record này chỉ chứa phần nội dung phản hồi.
// Không đưa mật khẩu, chuỗi kết nối hoặc dấu vết lỗi nội bộ vào đối tượng trả cho ứng dụng.
namespace PhoneApi.DTOs;

public sealed record ApiError(string Code, string Message);
