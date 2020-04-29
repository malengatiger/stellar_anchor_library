import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () {
    final double money = 100.0;
    expect(money + 1.00, 101.0);
  });
}
