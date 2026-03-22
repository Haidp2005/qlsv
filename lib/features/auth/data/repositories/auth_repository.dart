import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> login(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        // Fetch dữ liệu phân quyền từ collection users
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, user.uid);
        } else {
          // Fallback tạo model tạm nếu tài khoản có mà chưa có document
          return UserModel(uid: user.uid, email: user.email ?? email, role: 'student');
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Lỗi Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
