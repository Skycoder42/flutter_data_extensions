import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final String idToken;
  final String localId;

  const Account({
    required this.idToken,
    required this.localId,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable()
class DeleteAccountPostModel {
  final String idToken;

  DeleteAccountPostModel(this.idToken);

  // ignore: unused_element
  factory DeleteAccountPostModel.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountPostModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAccountPostModelToJson(this);
}
