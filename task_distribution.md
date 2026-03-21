# Bảng Phân Chia Công Việc Nhóm (4 Thành viên)

Để tối ưu hóa hiệu suất làm việc nhóm trên GitHub và hạn chế xung đột code (conflict) khi merge, dưới đây là bản phân công dựa trên các tính năng của `implementation_plan.md`.

## 1. Phân chia vai trò và nhiệm vụ

### 🧑‍💻 [Vị trí 1] Core & Auth Developer (Team Leader)
Trọng tâm: Xây dựng nền móng, hệ thống kết nối và xác thực.
- **Nhiệm vụ chính:**
  - Setup kiến trúc ban đầu (Folder structure, Color/Theme, cài package).
  - Viết các Base Widget dùng chung (Custom Button, TextInput, Appbar).
  - Cấu hình `go_router` (luồng điều hướng Sinh Viên/Giảng Viên).
  - Thiết kế màn hình Đăng nhập + Setup dự án kết nối với Firebase (`firebase_core`, `firebase_auth`).
  - Viết logic Xác thực đăng nhập bằng Firebase Auth. Kéo thông tin Role từ Firestore.
  - *Quản lý GitHub:* Review các Pull Request (PR) của các thành viên trước khi merge vào nhánh `main`.
- **Nhánh làm việc gợi ý:** `core-setup`, `feature/auth`

### 🧑‍💻 [Vị trí 2] Student Module Developer
Trọng tâm: Xây dựng toàn bộ giao diện và luồng dữ liệu cho phân hệ Sinh viên.
- **Nhiệm vụ chính:**
  - Xây dựng Layout Bottom Navigation cho Sinh viên.
  - Làm trang Dashboard của Sinh viên (Tổng quan lịch học).
  - Làm trang Thời khóa biểu.
  - Làm trang Danh sách môn học, hiển thị Điểm và Điểm danh.
- **Nhánh làm việc gợi ý:** `feature/student-home`, `feature/student-grades`

### 🧑‍💻 [Vị trí 3] Lecturer Module Developer
Trọng tâm: Xây dựng toàn bộ phân hệ cho Giảng viên.
- **Nhiệm vụ chính:**
  - Xây dựng Layout Bottom Navigation cho Giảng viên.
  - Làm trang Danh sách Lớp học phần đang phụ trách.
  - Làm màn hình Chi tiết danh sách lớp (Hiển thị danh sách sinh viên).
  - Code logic cho tính năng đánh dấu Điểm danh điện tử và Form nhập điểm báo cáo.
- **Nhánh làm việc gợi ý:** `feature/lecturer-classes`, `feature/lecturer-grading`

### 🧑‍💻 [Vị trí 4] Export & Utility Developer
Trọng tâm: Đảm nhận các chức năng mở rộng, tiện ích và xử lý file.
- **Nhiệm vụ chính:**
  - Xây dựng logic Xuất file Excel (`.xlsx`) từ danh sách lớp.
  - Xây dựng luồng tạo PDF bảng điểm (`pdf`, `printing` package) cho giảng viên.
  - Chịu trách nhiệm module Hồ sơ (Xem thông tin cá nhân chung của 2 Roles, Chỉnh sửa Avatar, Đổi mật khẩu).
  - Tạo luồng hiển thị thông báo (nếu có).
- **Nhánh làm việc gợi ý:** `feature/export-docs`, `feature/profile-settings`

---

## 2. Quy trình làm việc trên GitHub (Git Workflow)

Gợi ý áp dụng **Feature Branch Workflow** (Quy trình nhánh tính năng):

1. **Nhánh gốc (Branch Mặc định):**
   - Không ai được push trực tiếp code lên nhánh `main` (hoặc `master`).
   - Nên tạo một nhánh trung gian tên là `develop` để tất cả cùng merge code vào đó trước (để test chung).
2. **Khi bắt đầu code:**
   - Dev kéo code mới nhất từ nhánh `develop` về máy: `git pull origin develop`.
   - Tạo nhánh mới theo tên tính năng: `git checkout -b feature/ten-tinh-nang` (VD: `feature/student-timetable`).
3. **Commit & Cập nhật thường xuyên:**
   - Chia nhỏ các thay đổi và commit với message rõ ràng: `git commit -m "feat: thêm màn hình thời khóa biểu sinh viên"`.
4. **Tạo Pull Request (PR):**
   - Push nhánh chức năng lên GitHub: `git push origin feature/ten-tinh-nang`.
   - Vào GitHub tạo Pull Request xin merge từ `feature/...` vào `develop`.
   - Team Leader hoặc Dev khác review code -> Nhấn **Merge** trên GitHub.
5. **Xử lý Xung đột (Conflict):**
   - Vị trí 1 (Core) chỉ định tạo các file `Theme`, `go_router` trước, các thành viên khác phải pull về dùng, tránh tự chia file trùng lặp.
   - Thư mục màn hình tách biệt, ví dụ `/lib/features/student/...` và `/lib/features/lecturer/...` sẽ giúp Dev 2 và Dev 3 không file đụng chạm nhau. 
