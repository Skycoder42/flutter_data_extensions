import 'package:json_annotation/json_annotation.dart';

part 'firebase_account.g.dart';

@JsonSerializable()
class FirebaseAccount {
  final String idToken;
  final String localId;

  const FirebaseAccount({
    required this.idToken,
    required this.localId,
  });

  factory FirebaseAccount.fromJson(Map<String, dynamic> json) =>
      _$FirebaseAccountFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseAccountToJson(this);
}
