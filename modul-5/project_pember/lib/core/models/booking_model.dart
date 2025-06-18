class BookingModel {
  final String email;
  final String serviceName;
  final String? photographer;
  final String? cameraType;
  final String? studioName;
  final String date;
  final String? time;
  final int duration;

  BookingModel({
    required this.email,
    required this.serviceName,
    this.photographer,
    this.cameraType,
    this.studioName,
    required this.date,
    this.time,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'serviceName': serviceName,
      'date': date,
      'duration': duration,
    };

    if (serviceName == 'Booking Fotografer') {
      data['photographer'] = photographer;
      data['time'] = time;
    } else if (serviceName == 'Booking Kamera') {
      data['cameraType'] = cameraType;
    } else if (serviceName == 'Booking Tempat Studio') {
      data['studioName'] = studioName;
      data['time'] = time;
    }

    return data;
  }
}
