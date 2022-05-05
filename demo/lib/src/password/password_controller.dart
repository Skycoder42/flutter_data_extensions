import 'package:flutter_data/flutter_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_controller.freezed.dart';

late final passwordControllerProvider =
    StateNotifierProvider<PasswordController, PasswordState>(
  (ref) => PasswordController(),
);

@freezed
class PasswordState with _$PasswordState {
  const factory PasswordState.unset() = _Unset;
  const factory PasswordState.requested() = _Requested;
  const factory PasswordState.defined(String password) = _Defined;
  const factory PasswordState.consumed() = _Consumed;
}

class PasswordController extends StateNotifier<PasswordState> {
  PasswordController() : super(const PasswordState.unset());

  Future<String> requestPassword() async {
    final isUnset = state.maybeWhen(
      unset: () => true,
      orElse: () => false,
    );
    if (!isUnset) {
      throw StateError('Can only request password once');
    }

    state = const PasswordState.requested();
    final password = await stream
        .map(
          (state) => state.whenOrNull(
            defined: (password) => password,
          ),
        )
        .where((state) => state != null)
        .cast<String>()
        .first;
    state = const PasswordState.consumed();
    return password;
  }

  void setPassword(String password) => state.maybeWhen<void>(
        requested: () => state = PasswordState.defined(password),
        orElse: () {},
      );
}
