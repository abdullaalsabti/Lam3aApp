enum PaymentMethod {
  cash,
  cliq;

  static PaymentMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'cliq':
        return PaymentMethod.cliq;
      default:
        return PaymentMethod.cash;
    }
  }

  String toDisplayString() {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.cliq:
        return 'Cliq';
    }
  }
}







