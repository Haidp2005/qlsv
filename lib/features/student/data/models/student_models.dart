import 'package:equatable/equatable.dart';

class StudentProfile extends Equatable {
  const StudentProfile({
    required this.studentId,
    required this.fullName,
    required this.className,
    this.avatarBase64,
  });

  final String studentId;
  final String fullName;
  final String className;
  final String? avatarBase64;

  @override
  List<Object?> get props => [studentId, fullName, className, avatarBase64];
}

class TimetableItem extends Equatable {
  const TimetableItem({
    required this.subjectCode,
    required this.subjectName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.lecturer,
  });

  final String subjectCode;
  final String subjectName;
  final String day;
  final String startTime;
  final String endTime;
  final String room;
  final String lecturer;

  @override
  List<Object?> get props => [
    subjectCode,
    subjectName,
    day,
    startTime,
    endTime,
    room,
    lecturer,
  ];
}

class SubjectProgress extends Equatable {
  const SubjectProgress({
    required this.subjectCode,
    required this.subjectName,
    required this.credit,
    required this.midterm,
    required this.finalScore,
    required this.attendancePercent,
  });

  final String subjectCode;
  final String subjectName;
  final int credit;
  final double midterm;
  final double finalScore;
  final int attendancePercent;

  double get totalScore => (midterm * 0.4) + (finalScore * 0.6);

  @override
  List<Object?> get props => [
    subjectCode,
    subjectName,
    credit,
    midterm,
    finalScore,
    attendancePercent,
  ];
}

class StudentHomeData extends Equatable {
  const StudentHomeData({
    required this.profile,
    required this.todaySchedule,
    required this.weekSchedule,
    required this.subjects,
  });

  final StudentProfile profile;
  final List<TimetableItem> todaySchedule;
  final List<TimetableItem> weekSchedule;
  final List<SubjectProgress> subjects;

  @override
  List<Object?> get props => [profile, todaySchedule, weekSchedule, subjects];
}
