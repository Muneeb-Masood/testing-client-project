import 'package:test/models/order.dart';

class PaymentHelper {
  Future<bool> payAmount(String customerAccount, String tailorAccount,
      double amount, PaymentMethod method) async {
    switch (method) {
      case PaymentMethod.easypaisa:
        return _payViaEasypaisa(customerAccount, tailorAccount, amount);
      case PaymentMethod.jazzcash:
        return _payViaJazzCash(customerAccount, tailorAccount, amount);
    }
  }

  Future<bool> _payViaJazzCash(
      String customerAccount, String tailorAccount, double amount) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  Future<bool> _payViaEasypaisa(
      String customerAccount, String tailorAccount, double amount) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}
