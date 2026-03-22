import '../models/student_models.dart';

class StudentMockRepository {
  Future<StudentHomeData> fetchStudentHomeData() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    const weekSchedule = <TimetableItem>[
      TimetableItem(
        subjectCode: 'INT3306',
        subjectName: 'Phát triển ứng dụng di động',
        day: 'Thứ 2',
        startTime: '07:30',
        endTime: '09:30',
        room: 'A2-305',
        lecturer: 'TS. Nguyễn Văn A',
      ),
      TimetableItem(
        subjectCode: 'INT2208',
        subjectName: 'Cơ sở dữ liệu',
        day: 'Thứ 2',
        startTime: '13:00',
        endTime: '15:00',
        room: 'A1-204',
        lecturer: 'ThS. Trần Thị B',
      ),
      TimetableItem(
        subjectCode: 'INT3402',
        subjectName: 'Lập trình Web nâng cao',
        day: 'Thứ 3',
        startTime: '09:30',
        endTime: '11:30',
        room: 'B3-101',
        lecturer: 'TS. Phạm Văn C',
      ),
      TimetableItem(
        subjectCode: 'INT2215',
        subjectName: 'Mạng máy tính',
        day: 'Thứ 4',
        startTime: '07:30',
        endTime: '09:30',
        room: 'B1-210',
        lecturer: 'TS. Lê Quốc D',
      ),
      TimetableItem(
        subjectCode: 'INT3117',
        subjectName: 'Kỹ thuật phần mềm',
        day: 'Thứ 5',
        startTime: '13:00',
        endTime: '15:00',
        room: 'A3-107',
        lecturer: 'ThS. Võ Minh E',
      ),
    ];

    const subjects = <SubjectProgress>[
      SubjectProgress(
        subjectCode: 'INT3306',
        subjectName: 'Phát triển ứng dụng di động',
        credit: 3,
        midterm: 8.2,
        finalScore: 8.6,
        attendancePercent: 95,
      ),
      SubjectProgress(
        subjectCode: 'INT2208',
        subjectName: 'Cơ sở dữ liệu',
        credit: 3,
        midterm: 7.8,
        finalScore: 8.1,
        attendancePercent: 90,
      ),
      SubjectProgress(
        subjectCode: 'INT3402',
        subjectName: 'Lập trình Web nâng cao',
        credit: 3,
        midterm: 8.5,
        finalScore: 8.0,
        attendancePercent: 88,
      ),
      SubjectProgress(
        subjectCode: 'INT2215',
        subjectName: 'Mạng máy tính',
        credit: 2,
        midterm: 7.0,
        finalScore: 7.4,
        attendancePercent: 86,
      ),
      SubjectProgress(
        subjectCode: 'INT3117',
        subjectName: 'Kỹ thuật phần mềm',
        credit: 3,
        midterm: 8.8,
        finalScore: 9.0,
        attendancePercent: 97,
      ),
    ];

    return StudentHomeData(
      profile: const StudentProfile(
        studentId: '22012345',
        fullName: 'Nguyễn Văn Sinh Viên',
        className: 'K67-CNTT1',
      ),
      todaySchedule: weekSchedule.where((item) => item.day == 'Thứ 2').toList(),
      weekSchedule: weekSchedule,
      subjects: subjects,
    );
  }
}
