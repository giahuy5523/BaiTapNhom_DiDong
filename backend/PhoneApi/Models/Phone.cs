// Lớp thực thể tương ứng một bản ghi bảng dbo.Phones; dùng bên trong tầng truy cập dữ liệu.
// Phone không phải DTO trả trực tiếp cho Flutter: ImagePath còn cần chuyển thành ImageUrl.
namespace PhoneApi.Models;

public sealed class Phone
{
    // Khóa chính do SQL Server tự tăng, được Flutter dùng để yêu cầu chi tiết đúng điện thoại.
    public int Id { get; set; }
    // Tên sản phẩm. string.Empty tránh giá trị null khi mới tạo đối tượng C#; ràng buộc DB do schema/DbContext quy định.
    public string Name { get; set; } = string.Empty;
    // Dùng decimal để lưu tiền chính xác theo hệ thập phân; JSON vẫn trả số, không ghép ký hiệu đ hoặc dấu phân cách.
    public decimal Price { get; set; }
    // Đường dẫn tương đối với gốc API, ví dụ /images/iphone15.jpg, không phải đường dẫn ổ đĩa Windows.
    public string ImagePath { get; set; } = string.Empty;
    // Mô tả đầy đủ để màn chi tiết hiển thị; việc rút gọn ở danh sách thuộc Flutter.
    public string Description { get; set; } = string.Empty;
}
