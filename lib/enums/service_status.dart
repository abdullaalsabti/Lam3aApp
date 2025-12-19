enum ServiceStatus {
  orderPlaced,
  providerOnTheWay,
  providerArrived,
  washingStarted,
  paying,
  completed,
  cancelled;

  static ServiceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'orderplaced':
        return ServiceStatus.orderPlaced;
      case 'providerontheway':
        return ServiceStatus.providerOnTheWay;
      case 'providerarrived':
        return ServiceStatus.providerArrived;
      case 'washingstarted':
        return ServiceStatus.washingStarted;
      case 'paying':
        return ServiceStatus.paying;
      case 'completed':
        return ServiceStatus.completed;
      case 'cancelled':
        return ServiceStatus.cancelled;
      default:
        return ServiceStatus.orderPlaced;
    }
  }

  String toDisplayString() {
    switch (this) {
      case ServiceStatus.orderPlaced:
        return 'Order Placed';
      case ServiceStatus.providerOnTheWay:
        return 'Provider On The Way';
      case ServiceStatus.providerArrived:
        return 'Provider Arrived';
      case ServiceStatus.washingStarted:
        return 'Washing Started';
      case ServiceStatus.paying:
        return 'Paying';
      case ServiceStatus.completed:
        return 'Completed';
      case ServiceStatus.cancelled:
        return 'Cancelled';
    }
  }
}







