import 'package:flutter_test/flutter_test.dart';
import 'package:my_notebook/utils/password_hasher.dart';

void main() {
  test('hashes and verifies passwords', () {
    const password = 'correct horse battery staple';

    final hash = PasswordHasher.hashPassword(password);

    expect(hash, isNot(password));
    expect(PasswordHasher.needsUpgrade(hash), isFalse);
    expect(PasswordHasher.verifyPassword(password, hash), isTrue);
    expect(PasswordHasher.verifyPassword('wrong password', hash), isFalse);
  });

  test('supports legacy plain-text passwords for upgrade on login', () {
    const legacyPassword = 'notebook123';

    expect(PasswordHasher.needsUpgrade(legacyPassword), isTrue);
    expect(
      PasswordHasher.verifyPassword(legacyPassword, legacyPassword),
      isTrue,
    );
    expect(PasswordHasher.verifyPassword('different', legacyPassword), isFalse);
  });

  test('matches a known PBKDF2 SHA-256 vector', () {
    const storedHash =
        r'pbkdf2_sha256$1$c2FsdA==$Eg+2z/z4syxD5yJSVsT4N6hlSMkszDVICAWYfLcL4Xs=';

    expect(PasswordHasher.verifyPassword('password', storedHash), isTrue);
    expect(PasswordHasher.verifyPassword('passw0rd', storedHash), isFalse);
  });
}
