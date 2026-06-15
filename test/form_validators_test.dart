import 'package:flutter_test/flutter_test.dart';
import 'package:my_notebook/utils/form_validators.dart';

void main() {
  test('rejects text that is not a real email format', () {
    expect(FormValidators.email('ssss'), isNotNull);
    expect(FormValidators.email('student@example.com'), isNull);
  });
}
