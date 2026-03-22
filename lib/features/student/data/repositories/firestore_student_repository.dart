import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_models.dart';

class FirestoreStudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StudentHomeData> fetchStudentHomeData(String studentId, String email) async {
    // Array-Contains: Tìm những lớp học có chứa studentId này
    final classesQuery = await _firestore
        .collection('classes')
        .where('studentIds', arrayContains: studentId)
        .get();

    final weekSchedule = <TimetableItem>[];
    final subjects = <SubjectProgress>[];
    String resolvedFullName = email;
    String resolvedClassName = 'Tra cứu Realtime';
    
    for (final classDoc in classesQuery.docs) {
      final classData = classDoc.data();
      final courseCode = classData['courseCode'] ?? classDoc.id;
      final courseName = classData['courseName'] ?? 'Không rõ môn học';
      final lecturerId = classData['lecturerId'] ?? '';
      
      String lecturerName = lecturerId;
      if (lecturerId.isNotEmpty) {
        final gvDoc = await _firestore.collection('users').doc(lecturerId).get();
        if (gvDoc.exists && gvDoc.data() != null) {
          lecturerName = gvDoc.data()!['email'] ?? lecturerName;
        }
      }

      final scheduleRaw = classData['schedule'] ?? 'Không rõ';
      String day = 'Không rõ';
      String startTime = '--:--';
      String endTime = '--:--';
      
      final parts = scheduleRaw.split(',');
      if (parts.length >= 2) {
        day = parts[0].trim();
        final timeParts = parts[1].split('-');
        if (timeParts.length >= 2) {
          startTime = timeParts[0].trim();
          endTime = timeParts[1].trim();
        }
      } else {
        day = scheduleRaw;
      }

      weekSchedule.add(TimetableItem(
        subjectCode: courseCode,
        subjectName: courseName,
        day: day,
        startTime: startTime,
        endTime: endTime,
        room: classData['room'] ?? 'Không rõ',
        lecturer: lecturerName,
      ));

      // Lấy điểm thật từ subcollection students
      final studentSnap = await classDoc.reference.collection('students').doc(studentId).get();
      if (studentSnap.exists && studentSnap.data() != null) {
        final studentData = studentSnap.data()!;

        // Lấy đúng Họ Tên thật của sinh viên do giảng viên nhập vào từ subcollection
        if (studentData.containsKey('fullName') && (resolvedFullName == email || resolvedFullName == 'Chưa Cập Nhật')) {
          resolvedFullName = studentData['fullName'] as String;
          // Thông qua mã lớp để lấy tên lớp danh nghĩa nếu được cung cấp (tạm thời thay cho ClassName)
          resolvedClassName = courseCode;
        }

        final attended = (studentData['attendedSessions'] as num?)?.toInt() ?? 0;
        final total = (studentData['totalSessions'] as num?)?.toInt() ?? 0;
        final percent = total > 0 ? ((attended / total) * 100).toInt() : 100;
        
        subjects.add(SubjectProgress(
          subjectCode: courseCode,
          subjectName: courseName,
          credit: 3, 
          midterm: (studentData['midtermScore'] as num?)?.toDouble() ?? 0.0,
          finalScore: (studentData['finalScore'] as num?)?.toDouble() ?? 0.0,
          attendancePercent: percent,
        ));
      } else {
        subjects.add(SubjectProgress(
          subjectCode: courseCode,
          subjectName: courseName,
          credit: 3, 
          midterm: 0.0,
          finalScore: 0.0,
          attendancePercent: 100,
        ));
      }
    }

    final today = 'Thứ 2';

    return StudentHomeData(
      profile: StudentProfile(
        studentId: studentId,
        fullName: resolvedFullName,
        className: resolvedClassName,
      ),
      todaySchedule: weekSchedule.where((item) => item.day.contains(today)).toList(),
      weekSchedule: weekSchedule,
      subjects: subjects,
    );
  }
}
