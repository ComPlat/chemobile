// This class represents a user as returned by the Chemotion ELN Api.
// It does not hold any information pertaining to login, as we do not want to
// persist any unneeded private information!

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:jwt_decode/jwt_decode.dart';

part 'eln_user.g.dart';

@JsonSerializable(explicitToJson: true)
class ElnUser {
  // Fields returned by ELN Api
  final String token;
  final String uuid;
  final String firstName;
  final String lastName;
  final String elnIdentifier;
  final String elnUrl;

  ElnUser(
    this.token,
    this.uuid,
    this.firstName,
    this.lastName,
    this.elnIdentifier,
    this.elnUrl,
  );

  factory ElnUser.fromLogin(String token, String elnUrl) {
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    String firstName = payload['first_name'] as String;
    String lastName = payload['last_name'] as String;
    int userId = payload['user_id'] as int;

    String uuid = const Uuid().v5(Uuid.NAMESPACE_OID, "$elnUrl $userId");
    String elnIdentifier = Uri.parse(elnUrl).host;

    return ElnUser(token, uuid, firstName, lastName, elnIdentifier, elnUrl);
  }

  factory ElnUser.fromJson(Map<String, dynamic> data) => _$ElnUserFromJson(data);

  Map<String, dynamic> toJson() => _$ElnUserToJson(this);

  String get fullName {
    return "$firstName $lastName";
  }
}
