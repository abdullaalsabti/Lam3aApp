enum ServiceStatus {
  pending,
  accepted,
  rejected,
  orderPlaced,
  providerOnTheWay,
  providerArrived,
  washingStarted,
  paying,
  completed,
  cancelled;

  static ServiceStatus fromString(String value) {
    final normalized = value
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .toLowerCase();

    switch (normalized) {
      case 'pending':
        return ServiceStatus.pending;
      case 'accepted':
        return ServiceStatus.accepted;
      case 'rejected':
        return ServiceStatus.rejected;
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
        return ServiceStatus.pending;
    }
  }

  /// For UI display
  String toDisplayString() {
    switch (this) {
      case ServiceStatus.pending:
        return 'Pending';
      case ServiceStatus.accepted:
        return 'Accepted';
      case ServiceStatus.rejected:
        return 'Rejected';
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

  /// For sending back to backend (converts to PascalCase to match C# enum)
  String toApiString() {
    // Convert camelCase to PascalCase
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }
}


