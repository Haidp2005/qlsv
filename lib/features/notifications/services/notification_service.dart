class NotificationService {
  /// Giả lập danh sách thông báo lấy từ server
  static Future<List<Map<String, dynamic>>> getNotifications(String role) async {
    await Future.delayed(const Duration(seconds: 1)); // Mô phỏng trễ mạng
    
    if (role == 'student') {
      return [
        {
          'id': '1',
          'title': 'Điểm danh bị trừ',
          'body': 'Bạn đã vắng mặt buổi học môn Lập trình Mobile.',
          'time': '10:00 AM - 22/03/2026',
          'isRead': false,
        },
        {
          'id': '2',
          'title': 'Có điểm mới',
          'body': 'Điểm giữa kỳ môn Hệ quản trị CSDL đã được cập nhật.',
          'time': '08:30 AM - 21/03/2026',
          'isRead': true,
        },
      ];
    } else {
      return [
        {
          'id': '3',
          'title': 'Lịch giảng dạy thay đổi',
          'body': 'Lớp học phần Cấu trúc dữ liệu dời sang phòng A201.',
          'time': '14:00 PM - 22/03/2026',
          'isRead': false,
        },
      ];
    }
  }

  /// Hàm giả lập đánh dấu đã đọc
  static Future<void> markAsRead(String notificationId) async {
    // Gọi API cập nhật trạng thái thông báo
  }
}
