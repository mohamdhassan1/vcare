// B10 — practical email validation: normal addresses pass, obvious
// garbage fails. Phase 3: messages come from the active locale.

import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/utils/validators.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();
  final ar = AppLocalizationsAr();

  group('Validators.email', () {
    final email = Validators.email(en);

    const valid = [
      'john@example.com',
      'john.doe@example.com',
      'john+test@example.com',
      'john_doe@example.co.uk',
      'first-last@example.org',
      'user%tag@sub.example.io',
      'someone@example.photography', // TLD longer than 4 chars
      'a@b.co',
    ];

    for (final value in valid) {
      test('accepts "$value"', () => expect(email(value), isNull));
    }

    test('accepts surrounding whitespace (trimmed before validation)', () {
      expect(email('  john@example.com  '), isNull);
    });

    const invalid = [
      'abc',
      'abc@',
      '@example.com',
      'abc@example',
      'abc example@example.com',
      'john@exa mple.com',
      'john@@example.com',
      'john@example.',
      'john@.com',
      'john@example.c',
    ];

    for (final value in invalid) {
      test('rejects "$value"',
          () => expect(email(value), 'Enter a valid email'));
    }

    test('empty / null / blank are "required"', () {
      expect(email(''), 'Email is required');
      expect(email('   '), 'Email is required');
      expect(email(null), 'Email is required');
    });

    test('messages follow the locale (Arabic)', () {
      final arEmail = Validators.email(ar);
      expect(arEmail(''), ar.emailRequired);
      expect(arEmail('abc'), ar.emailInvalid);
      expect(arEmail('abc'), isNot('Enter a valid email'));
    });
  });

  group('other validators are localized too', () {
    test('password', () {
      expect(Validators.password(en)(''), en.passwordRequired);
      expect(Validators.password(en)('123'),
          en.passwordTooShort(Validators.minPasswordLength));
      expect(Validators.password(en)('123456'), isNull);
      expect(Validators.password(ar)(''), ar.passwordRequired);
    });

    test('confirm password compares against the live original', () {
      var original = 'abc123';
      final confirm = Validators.confirmPassword(en, () => original);
      expect(confirm(''), en.confirmPasswordRequired);
      expect(confirm('nope'), en.passwordsDoNotMatch);
      expect(confirm('abc123'), isNull);
      original = 'changed';
      expect(confirm('abc123'), en.passwordsDoNotMatch);
    });

    test('phone and name', () {
      expect(Validators.phone(en)(''), en.phoneRequired);
      expect(Validators.phone(en)('01a'), en.phoneDigitsOnly);
      expect(Validators.phone(en)('0100'), isNull);
      expect(Validators.name(ar)('  '), ar.nameRequired);
      expect(Validators.name(en)('Mo'), isNull);
    });
  });
}
