class FirebaseService {
  // Simulate Firebase initialization
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    print("Firebase initialized");
  }
}
