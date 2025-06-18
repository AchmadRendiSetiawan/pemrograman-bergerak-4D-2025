class LocationService {
  Future<String> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    return "Current Location: Jakarta, Indonesia";
  }
}
