// DTO là đối tượng truyền dữ liệu ra ngoài, tách cấu trúc API khỏi thực thể trong CSDL.
// Chỉ trả đúng 5 trường đã thống nhất với Sơn; ImageUrl là URL ảnh đầy đủ, khác ImagePath trong DB.
// record tạo kiểu dữ liệu gọn với các thuộc tính khởi tạo qua hàm dựng, phù hợp mang kết quả truy vấn.
// ASP.NET Core chuyển tên thuộc tính thành camelCase: Id → id, ImageUrl → imageUrl.
namespace PhoneApi.DTOs;

public sealed record PhoneDto(int Id, string Name, decimal Price, string ImageUrl, string Description);
