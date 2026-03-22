import 'package:equatable/equatable.dart';

class StudentRecord extends Equatable {
  const StudentRecord({
    required this.id,
    required this.fullName,
    this.attendedSessions = 0,
    this.totalSessions = 0,
    this.midtermScore,
    this.finalScore,
  });

  final String id;
  final String fullName;
  final int attendedSessions;
  final int totalSessions;
  final double? midtermScore;
  final double? finalScore;

  bool get hasFullGrade => midtermScore != null && finalScore != null;

  double? get overallScore {
    if (!hasFullGrade) {
      return null;
    }
    return (midtermScore! * 0.4) + (finalScore! * 0.6);
  }

  double get attendanceRate {
    if (totalSessions == 0) {
      return 0;
    }
    return (attendedSessions / totalSessions) * 100;
  }

  StudentRecord copyWith({
    String? id,
    String? fullName,
    int? attendedSessions,
    int? totalSessions,
    double? midtermScore,
    double? finalScore,
    bool clearMidtermScore = false,
    bool clearFinalScore = false,
  }) {
    return StudentRecord(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      attendedSessions: attendedSessions ?? this.attendedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      midtermScore: clearMidtermScore ? null : (midtermScore ?? this.midtermScore),
      finalScore: clearFinalScore ? null : (finalScore ?? this.finalScore),
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        attendedSessions,
        totalSessions,
        midtermScore,
        finalScore,
      ];
}

class LecturerClassroom extends Equatable {
  const LecturerClassroom({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.semester,
    required this.room,
    required this.schedule,
    required this.students,
  });

  final String id;
  final String courseCode;
  final String courseName;
  final String semester;
  final String room;
  final String schedule;
  final List<StudentRecord> students;

  int get totalStudents => students.length;

  int get gradedStudentsCount {
    return students.where((student) => student.hasFullGrade).length;
  }

  double get averageAttendanceRate {
    if (students.isEmpty) {
      return 0;
    }
    final total = students.fold<double>(
      0,
      (sum, student) => sum + student.attendanceRate,
    );
    return total / students.length;
  }

  double? get averageOverallScore {
    final graded = students.where((student) => student.overallScore != null).toList();
    if (graded.isEmpty) {
      return null;
    }
    final total = graded.fold<double>(
      0,
      (sum, student) => sum + (student.overallScore ?? 0),
    );
    return total / graded.length;
  }

  LecturerClassroom copyWith({
    String? id,
    String? courseCode,
    String? courseName,
    String? semester,
    String? room,
    String? schedule,
    List<StudentRecord>? students,
  }) {
    return LecturerClassroom(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      semester: semester ?? this.semester,
      room: room ?? this.room,
      schedule: schedule ?? this.schedule,
      students: students ?? this.students,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseCode,
        courseName,
        semester,
        room,
        schedule,
        students,
      ];
}
