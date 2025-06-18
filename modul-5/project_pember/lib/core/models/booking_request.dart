// lib/models/booking_request.dart
class BookingRequest {
  final String email;
  final String serviceName;
  final Map<String, dynamic> extra;

  BookingRequest({
    required this.email,
    required this.serviceName,
    required this.extra,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'serviceName': serviceName,
        ...extra,
      };
}
