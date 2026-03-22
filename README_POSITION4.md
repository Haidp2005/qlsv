# Vị trí 4 - Export & Utility Developer (Tài liệu phân công)

Tài liệu này mô tả chi tiết các file và chức năng được thực hiện bởi **Vị trí 4: Export & Utility Developer** trong dự án Ứng Dụng Quản Lý Sinh Viên (Flutter).

## Mục tiêu của Vị trí 4
Đảm nhận các chức năng mở rộng, tiện ích và xử lý file cho dự án, cụ thể bao gồm:
1. Xây dựng logic Xuất file Excel (`.xlsx`) từ danh sách lớp.
2. Xây dựng luồng tạo PDF bảng điểm (sử dụng `pdf`, `printing` package) cho giảng viên.
3. Chịu trách nhiệm module Hồ sơ (Xem thông tin cá nhân chung của 2 Roles, Chỉnh sửa Avatar, Đổi mật khẩu).
4. Tạo luồng hiển thị thông báo.

---

## Cấu trúc thư mục và phân tích chức năng các file

### 1. Module Tiện ích Xuất File (Export Utilities)
**Đường dẫn:** `lib/core/utils/`

- `export_excel_util.dart`: 
  - **Mục đích:** Chứa logic tĩnh (static methods) để xử lý việc xuất danh sách sinh viên của một lớp ra file định dạng Excel (`.xlsx`).
  - **Thư viện sử dụng:** `excel`, `path_provider`, `open_filex`.
  - **Cách thức hoạt động:** Tạo bản số hóa danh sách sinh viên, format thành các dòng (Rows) trên file Excel và lưu vào thư mục hệ thống (Document Directory) của thiết bị. Tự động mở file sau khi xuất xong cho người dùng xem trước.

- `export_pdf_util.dart`:
  - **Mục đích:** Xử lý việc vẽ bảng điểm của lớp học phần thành file PDF có format trang A4 chuẩn chỉnh phục vụ cho việc in ấn của giảng viên.
  - **Thư viện sử dụng:** `pdf`, `printing`, `path_provider`.
  - **Cách thức hoạt động:** Sử dụng Layout Builder của gói `pdf` để thiết kế giao diện dạng bảng (Table), sau đó xuất ra file. Chức năng `Printing.layoutPdf` còn hỗ trợ giao diện xem trước (Preview) và in trực tiếp nếu thiết bị có kết nối máy in.

### 2. Module Hồ Sơ Cá Nhân (Profile Settings)
**Đường dẫn:** `lib/features/profile/`

- `screens/profile_screen.dart`:
  - **Mục đích:** Màn hình chính xem hồ sơ cá nhân, được thiết kế dùng chung để phục vụ cả 2 vai trò `student` và `lecturer`.
  - **Chức năng:** Hiển thị Avatar, tên người dùng, lấy email thật từ `FirebaseAuth.instance.currentUser`. Tích hợp nút Đổi mật khẩu và nút Đăng xuất đã được liên kết với logic thực tế gọi hàm `FirebaseAuth.instance.signOut()` và chuyển hướng.

- `screens/change_password_screen.dart`:
  - **Mục đích:** Giao diện cho phép người dùng thay đổi mật khẩu một cách an toàn.
  - **Chức năng:** Form cho phép nhập mật khẩu mới và gọi thực thi API `updatePassword()` của Firebase Auth. Có xử lý hiển thị SnackBar thông báo thành công hoặc bắt các lỗi xác thực ngoại lệ.

- `widgets/avatar_picker.dart`:
  - **Mục đích:** Widget tái sử dụng hỗ trợ cho việc bấm vào Avatar để thay đổi ảnh đại diện.
  - **Thư viện sử dụng:** `image_picker`, `shared_preferences`.
  - **Chức năng:** Mở Modal Bottom Sheet hỏi người dùng chọn ảnh từ Thư viện (Gallery) hay Chụp ảnh mới (Camera). Xử lý ảnh, cập nhật trên giao diện và lưu đường dẫn ảnh cục bộ vào thiết bị qua `SharedPreferences` để không bị mất khi thoát ứng dụng.

### 3. Module Thông Báo (Notifications)
**Đường dẫn:** `lib/features/notifications/`

- `services/notification_service.dart`:
  - **Mục đích:** Đóng vai trò làm tầng Service giao tiếp với Database hoặc tầng trung gian quản lý dữ liệu thông báo.
  - **Chức năng:** Cung cấp hàm lấy dữ liệu thông báo giả lập (fake data/delay timer) phân biệt theo Role. Chứa hàm xử lý logic đánh dấu đã đọc (Mark as Read).

- `screens/notification_screen.dart`:
  - **Mục đích:** Màn hình danh sách hiển thị các thông báo (Push Notifications format).
  - **Chức năng:** Render dữ liệu từ `NotificationService` bằng `ListView.builder`. Đổi màu/đậm nhạt cho các thông báo dựa trên trạng thái `isRead`.

## Cách thức cài đặt & Tích hợp (Cho Trưởng nhóm)
- Thành viên Vị trí 4 đã cài đặt các packages vào `pubspec.yaml` (bao gồm: `excel`, `pdf`, `printing`, `path_provider`, `open_filex`, `image_picker`).
- Trưởng nhóm (Vị trí 1) có thể import trực tiếp màn hình `ProfileScreen` hoặc `NotificationScreen` vào các mục trong Bottom Navigation Bar để ráp nối vào luồng chính.
- Các nút tính năng như "Xuất danh sách", "Tải bảng điểm" trong luồng của Sinh viên / Giảng viên có thể gọi trực tiếp `ExportExcelUtil.exportStudentList()` và `ExportPdfUtil.exportGradeSheetPDF()` mà không cần xử lý thêm logic.
