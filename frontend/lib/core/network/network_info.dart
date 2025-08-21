/// Abstract class for network connectivity information
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For now, return true. This will be implemented properly in later tasks
    // when we add connectivity checking functionality
    return true;
  }
}

/// Factory for creating NetworkInfo instances
class NetworkInfoFactory {
  static final NetworkInfo _instance = NetworkInfoImpl();
  
  static NetworkInfo get instance => _instance;
}