import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure('Vui lòng nhập đầy đủ email và mật khẩu.'));
      return;
    }

    emit(AuthLoading());
    try {
      final user = await authRepository.login(email, password);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(const AuthFailure('Đăng nhập thất bại.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthInitial());
  }
}
