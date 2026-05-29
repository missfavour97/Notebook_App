import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class PasswordHasher {
  static const String _algorithm = 'pbkdf2_sha256';
  static const int _defaultIterations = 12000;
  static const int _keyLength = 32;
  static const int _saltLength = 16;
  static const int _sha256BlockSize = 64;

  static String hashPassword(String password) {
    final salt = _randomBytes(_saltLength);
    final hash = _pbkdf2(password, salt, _defaultIterations, _keyLength);

    return [
      _algorithm,
      _defaultIterations.toString(),
      base64Encode(salt),
      base64Encode(hash),
    ].join(r'$');
  }

  static bool verifyPassword(String password, String storedPassword) {
    if (needsUpgrade(storedPassword)) {
      return _constantTimeStringEquals(password, storedPassword);
    }

    final parts = storedPassword.split(r'$');

    if (parts.length != 4 || parts[0] != _algorithm) {
      return false;
    }

    final iterations = int.tryParse(parts[1]);

    if (iterations == null || iterations <= 0) {
      return false;
    }

    try {
      final salt = base64Decode(parts[2]);
      final expectedHash = base64Decode(parts[3]);
      final actualHash = _pbkdf2(
        password,
        Uint8List.fromList(salt),
        iterations,
        expectedHash.length,
      );

      return _constantTimeBytesEqual(actualHash, expectedHash);
    } on FormatException {
      return false;
    }
  }

  static bool needsUpgrade(String storedPassword) {
    return !storedPassword.startsWith('$_algorithm\$');
  }

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  static Uint8List _pbkdf2(
    String password,
    Uint8List salt,
    int iterations,
    int keyLength,
  ) {
    final passwordBytes = utf8.encode(password);
    final blockCount = (keyLength / _keyLength).ceil();
    final output = BytesBuilder();

    for (var blockIndex = 1; blockIndex <= blockCount; blockIndex++) {
      final saltBlock = Uint8List(salt.length + 4)
        ..setRange(0, salt.length, salt);

      saltBlock[salt.length] = (blockIndex >> 24) & 0xff;
      saltBlock[salt.length + 1] = (blockIndex >> 16) & 0xff;
      saltBlock[salt.length + 2] = (blockIndex >> 8) & 0xff;
      saltBlock[salt.length + 3] = blockIndex & 0xff;

      var roundHash = _hmacSha256(passwordBytes, saltBlock);
      final blockHash = Uint8List.fromList(roundHash);

      for (var i = 1; i < iterations; i++) {
        roundHash = _hmacSha256(passwordBytes, roundHash);

        for (var j = 0; j < blockHash.length; j++) {
          blockHash[j] ^= roundHash[j];
        }
      }

      output.add(blockHash);
    }

    return Uint8List.fromList(output.toBytes().take(keyLength).toList());
  }

  static Uint8List _hmacSha256(List<int> key, List<int> message) {
    final normalizedKey = key.length > _sha256BlockSize
        ? _sha256(key)
        : Uint8List.fromList(key);

    final paddedKey = Uint8List(_sha256BlockSize)
      ..setRange(0, normalizedKey.length, normalizedKey);
    final outerKey = Uint8List(_sha256BlockSize);
    final innerKey = Uint8List(_sha256BlockSize);

    for (var i = 0; i < _sha256BlockSize; i++) {
      outerKey[i] = paddedKey[i] ^ 0x5c;
      innerKey[i] = paddedKey[i] ^ 0x36;
    }

    final innerMessage = BytesBuilder()
      ..add(innerKey)
      ..add(message);
    final innerHash = _sha256(innerMessage.toBytes());

    final outerMessage = BytesBuilder()
      ..add(outerKey)
      ..add(innerHash);

    return _sha256(outerMessage.toBytes());
  }

  static Uint8List _sha256(List<int> message) {
    final h = [
      0x6a09e667,
      0xbb67ae85,
      0x3c6ef372,
      0xa54ff53a,
      0x510e527f,
      0x9b05688c,
      0x1f83d9ab,
      0x5be0cd19,
    ];

    const k = [
      0x428a2f98,
      0x71374491,
      0xb5c0fbcf,
      0xe9b5dba5,
      0x3956c25b,
      0x59f111f1,
      0x923f82a4,
      0xab1c5ed5,
      0xd807aa98,
      0x12835b01,
      0x243185be,
      0x550c7dc3,
      0x72be5d74,
      0x80deb1fe,
      0x9bdc06a7,
      0xc19bf174,
      0xe49b69c1,
      0xefbe4786,
      0x0fc19dc6,
      0x240ca1cc,
      0x2de92c6f,
      0x4a7484aa,
      0x5cb0a9dc,
      0x76f988da,
      0x983e5152,
      0xa831c66d,
      0xb00327c8,
      0xbf597fc7,
      0xc6e00bf3,
      0xd5a79147,
      0x06ca6351,
      0x14292967,
      0x27b70a85,
      0x2e1b2138,
      0x4d2c6dfc,
      0x53380d13,
      0x650a7354,
      0x766a0abb,
      0x81c2c92e,
      0x92722c85,
      0xa2bfe8a1,
      0xa81a664b,
      0xc24b8b70,
      0xc76c51a3,
      0xd192e819,
      0xd6990624,
      0xf40e3585,
      0x106aa070,
      0x19a4c116,
      0x1e376c08,
      0x2748774c,
      0x34b0bcb5,
      0x391c0cb3,
      0x4ed8aa4a,
      0x5b9cca4f,
      0x682e6ff3,
      0x748f82ee,
      0x78a5636f,
      0x84c87814,
      0x8cc70208,
      0x90befffa,
      0xa4506ceb,
      0xbef9a3f7,
      0xc67178f2,
    ];

    final bytes = List<int>.from(message);
    final bitLength = bytes.length * 8;

    bytes.add(0x80);

    while (bytes.length % 64 != 56) {
      bytes.add(0);
    }

    for (var shift = 56; shift >= 0; shift -= 8) {
      bytes.add((bitLength >> shift) & 0xff);
    }

    for (var chunkStart = 0; chunkStart < bytes.length; chunkStart += 64) {
      final words = List<int>.filled(64, 0);

      for (var i = 0; i < 16; i++) {
        final index = chunkStart + i * 4;
        words[i] = _mask32(
          (bytes[index] << 24) |
              (bytes[index + 1] << 16) |
              (bytes[index + 2] << 8) |
              bytes[index + 3],
        );
      }

      for (var i = 16; i < 64; i++) {
        final s0 =
            _rightRotate(words[i - 15], 7) ^
            _rightRotate(words[i - 15], 18) ^
            (words[i - 15] >> 3);
        final s1 =
            _rightRotate(words[i - 2], 17) ^
            _rightRotate(words[i - 2], 19) ^
            (words[i - 2] >> 10);

        words[i] = _mask32(words[i - 16] + s0 + words[i - 7] + s1);
      }

      var a = h[0];
      var b = h[1];
      var c = h[2];
      var d = h[3];
      var e = h[4];
      var f = h[5];
      var g = h[6];
      var workingH = h[7];

      for (var i = 0; i < 64; i++) {
        final s1 =
            _rightRotate(e, 6) ^ _rightRotate(e, 11) ^ _rightRotate(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final temp1 = _mask32(workingH + s1 + ch + k[i] + words[i]);
        final s0 =
            _rightRotate(a, 2) ^ _rightRotate(a, 13) ^ _rightRotate(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = _mask32(s0 + maj);

        workingH = g;
        g = f;
        f = e;
        e = _mask32(d + temp1);
        d = c;
        c = b;
        b = a;
        a = _mask32(temp1 + temp2);
      }

      h[0] = _mask32(h[0] + a);
      h[1] = _mask32(h[1] + b);
      h[2] = _mask32(h[2] + c);
      h[3] = _mask32(h[3] + d);
      h[4] = _mask32(h[4] + e);
      h[5] = _mask32(h[5] + f);
      h[6] = _mask32(h[6] + g);
      h[7] = _mask32(h[7] + workingH);
    }

    final output = BytesBuilder();

    for (final value in h) {
      output.add([
        (value >> 24) & 0xff,
        (value >> 16) & 0xff,
        (value >> 8) & 0xff,
        value & 0xff,
      ]);
    }

    return Uint8List.fromList(output.toBytes());
  }

  static int _rightRotate(int value, int shift) {
    return _mask32((value >> shift) | (value << (32 - shift)));
  }

  static int _mask32(int value) {
    return value & 0xffffffff;
  }

  static bool _constantTimeStringEquals(String left, String right) {
    return _constantTimeBytesEqual(utf8.encode(left), utf8.encode(right));
  }

  static bool _constantTimeBytesEqual(List<int> left, List<int> right) {
    var difference = left.length ^ right.length;
    final maxLength = max(left.length, right.length);

    for (var i = 0; i < maxLength; i++) {
      final leftByte = i < left.length ? left[i] : 0;
      final rightByte = i < right.length ? right[i] : 0;
      difference |= leftByte ^ rightByte;
    }

    return difference == 0;
  }
}
