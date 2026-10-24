/// Định dạng số tiền VND với dấu chấm phân cách hàng nghìn.
String formatVnd(int amount) {
  final digits = amount.abs().toString();
  final formatted = StringBuffer();

  if (amount < 0) formatted.write('-');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) formatted.write('.');
    formatted.write(digits[i]);
  }

  return '$formatted đ';
}
