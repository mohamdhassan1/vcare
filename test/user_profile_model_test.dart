import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/data/models/user_profile_model.dart';

void main() {
  group('UserProfileModel.fromJson', () {
    const user = {
      'id': 5,
      'name': 'Mohamed',
      'email': 'm@example.com',
      'phone': '01000000000',
      'gender': 0,
    };

    test('reads the first object when "data" is a list', () {
      final profile = UserProfileModel.fromJson({
        'message': 'Success',
        'data': [user],
        'status': true,
        'code': 200,
      });

      expect(profile.hasName, isTrue);
      expect(profile.name, 'Mohamed');
      expect(profile.email, 'm@example.com');
      expect(profile.phone, '01000000000');
      expect(profile.gender, '0'); // numeric gender is stringified
    });

    test('still supports "data" as an object', () {
      final profile = UserProfileModel.fromJson({'data': user});
      expect(profile.name, 'Mohamed');
      expect(profile.gender, '0');
    });

    test('supports data.user nesting and textual gender', () {
      final profile = UserProfileModel.fromJson({
        'data': {
          'user': {...user, 'gender': 'female'}
        }
      });
      expect(profile.name, 'Mohamed');
      expect(profile.gender, 'female');
    });

    test('supports a bare profile object', () {
      expect(UserProfileModel.fromJson(user).phone, '01000000000');
    });

    test('empty list / malformed payloads yield an empty name, no throw', () {
      expect(UserProfileModel.fromJson({'data': []}).hasName, isFalse);
      expect(UserProfileModel.fromJson({'data': null}).hasName, isFalse);
      expect(UserProfileModel.fromJson('unexpected').hasName, isFalse);
      expect(UserProfileModel.fromJson(null).hasName, isFalse);
    });

    test('blank name counts as missing; optional fields stay null', () {
      final profile = UserProfileModel.fromJson({
        'data': [
          {'name': '   '}
        ]
      });
      expect(profile.hasName, isFalse);
      expect(profile.email, isNull);
      expect(profile.gender, isNull);
      expect(profile.imageUrl, isNull);
    });
  });
}
