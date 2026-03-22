import 'package:flutter_test/flutter_test.dart';
import 'package:qlsv/features/lecturer/domain/models/lecturer_models.dart';

void main() {
  group('Lecturer models', () {
    test('tính attendanceRate đúng khi có buổi học', () {
      const student = StudentRecord(
        id: 'SV001',
        fullName: 'Nguyen Van A',
        attendedSessions: 3,
        totalSessions: 4,
      );

      expect(student.attendanceRate, 75);
    });

    test('tính overallScore theo trọng số 40/60', () {
      const student = StudentRecord(
        id: 'SV001',
        fullName: 'Nguyen Van A',
        midtermScore: 7,
        finalScore: 9,
      );

      expect(student.overallScore, closeTo(8.2, 0.0001));
    });

    test('classroom thống kê gradedStudentsCount và averageOverallScore đúng', () {
      const classroom = LecturerClassroom(
        id: 'SE114',
        courseCode: 'SE114',
        courseName: 'LTHDT',
        semester: 'HK2',
        room: 'B3-203',
        schedule: 'Thứ 2',
        students: [
          StudentRecord(
            id: 'SV001',
            fullName: 'A',
            midtermScore: 8,
            finalScore: 8,
          ),
          StudentRecord(
            id: 'SV002',
            fullName: 'B',
            midtermScore: 6,
            finalScore: 10,
          ),
          StudentRecord(
            id: 'SV003',
            fullName: 'C',
          ),
        ],
      );

      expect(classroom.totalStudents, 3);
      expect(classroom.gradedStudentsCount, 2);
      expect(classroom.averageOverallScore, closeTo(8.2, 0.0001));
    });
  });
}
