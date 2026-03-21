# Kế Hoạch Triển Khai: Ứng Dụng Quản Lý Sinh Viên (Flutter)

## 1. Đánh giá hiện trạng

Dự án tại \`e:\qlsv\` hiện là một project Flutter mới hoàn toàn vừa được khởi tạo (template mặc định). Do đó, chúng ta sẽ bắt tay vào quy hoạch cấu trúc, kiến trúc ứng dụng và định hình danh sách tính năng một cách hệ thống ngay từ đầu.

## 2. Phân tích Yêu cầu & Tính năng

Hệ thống yêu cầu hỗ trợ 2 vai trò truy cập chính với các chức năng phân biệt: **Giảng viên (Lecturer)** và **Sinh viên (Student)**. Trọng tâm của app là quản lý lớp học phần, điểm danh và điểm số.

### Tính năng cốt lõi (Core Features):
- **Xác thực (Authentication):** Đăng nhập an toàn, quản lý phiên làm việc thông qua token. Route tự động nhận diện Role sau khi đăng nhập để đưa vào màn hình tương ứng.
- **Hồ sơ cá nhân:** Xem thông tin cá nhân, cập nhật mật khẩu.
- **Thông báo (Push Notifications):** Gửi các cảnh báo lịch học, cập nhật điểm.

### Tính năng cho Sinh viên:
1. **Trang chủ/Dashboard:** Tổng quan lịch học sắp tới.
2. **Thời khóa biểu:** Xem lịch học, lịch thi cá nhân theo tuần/tháng.
3. **Lớp học phần:** Xem danh sách các môn đã đăng ký trong học kỳ hiện tại.
4. **Kết quả học tập:** Tra cứu điểm số (giữa kỳ, cuối kỳ) và điểm danh (số buổi nghỉ).

### Tính năng cho Giảng viên:
1. **Trang chủ/Dashboard:** Lịch giảng dạy trong ngày/tuần.
2. **Quản lý lớp học phần:** Xem danh sách các lớp đang phụ trách.
3. **Danh sách sinh viên:** Xem chi tiết sinh viên thuộc một lớp học phần.
4. **Điểm danh:** Chức năng check-in/điểm danh nhanh từng sinh viên theo buổi.
5. **Nhập điểm:** Tạo form nhập điểm và đánh giá cho sinh viên trong lóp.
6. **Xuất file Excel/PDF:** Xuất danh sách sinh viên của một lớp học phần ra định dạng `.xlsx` và xuất bảng điểm của lớp ra file định dạng PDF.

## 3. Tech Stack & Thư Viện Khuyên Dùng

Trong hệ sinh thái Flutter hiện nay, các công nghệ sau được khuyến nghị để tối ưu cho một ứng dụng có cấu trúc phân quyền rõ ràng:

- **State Management:** `flutter_bloc` hoặc `riverpod`. App quản lý có nhiều trạng thái phức tạp nên dùng BLoC để tách bạch Business Logic.
- **Routing:** `go_router` để dễ dàng phân luồng Auth Guard (Đá người dùng chưa đăng nhập về trang Login, chia Route nhánh Sinh Viên/Giảng viên).
- **Backend & Database:** **Firebase**. Sử dụng `firebase_auth` để xác thực đăng nhập người dùng và `cloud_firestore` để lưu trữ, truy vấn dữ liệu lớp học, điểm số realtime.
- **Local Storage:** `shared_preferences` để lưu các cài đặt thiết bị cá nhân (vd: Dark Mode, ngôn ngữ).
- **UI & Tối ưu Responsive:** Sử dụng `flutter_screenutil` nếu cần đáp ứng tốt cho nhiều cỡ màn hình (hoặc code base thuần với LayoutBuilder/MediaQuery). Thiết kế theo hệ thống Material 3.
- **Xử lý File (Excel & PDF):** Thư viện `excel` để xuất file `.xlsx` và thư viện `pdf` (kèm `printing`) để tạo, xem trước và lưu bảng điểm PDF. Kết hợp cùng `path_provider` để xử lý lưu tệp tin về máy.

*Về Backend (DB & API):* Ứng dụng sẽ hoạt động theo mô hình Serverless bằng toàn bộ công nghệ của **Firebase** (Firestore + Auth). Không cần viết Backend API rườm rà, giúp tập trung tốc độ làm app Flutter.

## 4. Mô hình Dữ Liệu Khái Quát (Database Schema)

Dù lưu trữ qua API hay Firebase, dữ liệu cần có các Collection/Bảng sau:
- **Users**: \`id, email, role (student/lecturer)\`.
- **Students**: \`id, user_id, student_id (MSSV), full_name, class_name (Lớp danh nghĩa), dob\`.
- **Lecturers**: \`id, user_id, full_name, faculty\`.
- **Courses (Môn học)**: \`id, course_code, name, credits\`.
- **Classes/Sections (Lớp học phần)**: \`id, course_id, lecturer_id, semester, room, schedule\`.
- **Enrollments (Đăng ký học)**: \`class_id, student_id, grade_mid, grade_final, list<attendance_dates>\...

## 5. Lộ trình Triển khai (Roadmap)

### Giai đoạn 1: Khởi tạo Kiến trúc & Cơ sở (Setup)
- Tạo cấu trúc thư mục (Features-based layer: \`lib/features/auth\`, \`lib/features/student\`, \`lib/features/lecturer\`, \`lib/core/...\`).
- Khai báo và cài đặt các Packages cần thiết trong \`pubspec.yaml\`.
- Thiết lập \`go_router\` và cấu hình Theme mặc định.

### Giai đoạn 2: Mô-đun Xác thực (Authentication)
- Thiết kế UI màn hình Đăng nhập (Login).
- Logic xử lý đăng nhập, lưu trữ Token và chuyển hướng phân quyền.
- Thiết kế UI khung App cho từng vai trò (Bottom Navigation Bar cho Sinh viên và Giảng viên).

### Giai đoạn 3: Phân hệ Sinh viên
- Xây dựng màn hình Home (Tóm tắt lịch học).
- Xây dựng màn hình Thời khóa biểu.
- Xây dựng màn hình Các môn học và Điểm số.

### Giai đoạn 4: Phân hệ Giảng viên
- Xây dựng màn hình Danh sách lớp quản lý.
- Giao diện chi tiết lớp học (Danh sách Sinh viên).
- Tính năng: Chức năng checkbox Điểm danh tự động cập nhật & chức năng nhập điểm.
- Tính năng: Xuất danh sách hệ thống ra tệp tin Excel (.xlsx) và xuất bảng điểm ra tệp tin PDF để tiện in ấn, lưu trữ.

### Giai đoạn 5: Tinh chỉnh & Sẵn sàng
- Fake API / Nối API thật (nếu có).
- Xử lý các lỗi ngoại lệ (Mất mạng, loading indicator...).
- Test luồng ứng dụng giữa 2 Role.
