import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionProvider extends ChangeNotifier {
  bool _isConnected = true;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicCheck;
  
  bool get isConnected => _isConnected;
  
  ConnectionProvider() {
    _initConnectivity();
    _startListening();
    _startPeriodicCheck();
  }
  
  Future<void> _initConnectivity() async {
    await _checkRealConnectivity();
  }
  
  void _startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        await _checkRealConnectivity();
      },
      onError: (error) {
        debugPrint('Connectivity error: $error');
        _updateConnectionStatus(false);
      }
    );
  }
  
  void _startPeriodicCheck() {
    _periodicCheck = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkRealConnectivity();
    });
  }
  
  Future<void> _checkRealConnectivity() async {
    try {
    
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasNetworkInterface = connectivityResults.any(
        (result) => result != ConnectivityResult.none
      );
      
      if (!hasNetworkInterface) {
        _updateConnectionStatus(false);
        return;
      }
      
      
      final hasInternet = await _hasInternetConnection();
      _updateConnectionStatus(hasInternet);
      
    } catch (e) {
      debugPrint('Connection check error: $e');
      _updateConnectionStatus(false);
    }
  }
  
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      debugPrint('Socket exception: $e');
      return false;
    } on TimeoutException catch (e) {
      debugPrint('Timeout exception: $e');
      return false;
    } catch (e) {
      debugPrint('Other exception: $e');
      return false;
    }
  }
  
  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      debugPrint('Connection status changed: $_isConnected');
      notifyListeners();
    }
  }
  Future<void> checkConnectivity() async {
    await _checkRealConnectivity();
  }
  
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicCheck?.cancel();
    super.dispose();
  }
}