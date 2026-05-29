import '../mock/mock_config.dart';

class ServiceFactory {
  static T resolve<T>(T Function() real, T Function() mock) {
    return MockConfig.useMock ? mock() : real();
  }
}