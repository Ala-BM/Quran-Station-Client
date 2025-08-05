import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../Providers/KhinsiderAlbums.dart';
import 'package:http/http.dart' as http;

class QSScrapperException implements Exception {
  final String message;
  final QSErrorType type;
  
  QSScrapperException(this.message, this.type);
  
  @override
  String toString() => message;
}

enum QSErrorType {
  networkError,
  timeoutError,
  serverError,
  dataParsingError,
  dataNotFound,
  hostLookupFailed,
  noInternetConnection
}

class Qsscrapper {
  ValueNotifier<int> station = ValueNotifier<int>(1);
  
  static const Duration _requestTimeout = Duration(seconds: 15);
  
  static const Map<String, String> _commonHeaders = {
    "Accept": "*/*",
    "RSC": "1",
    "User-Agent": "Mozilla/5.0 (compatible; Flutter App)",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
  };

  Future<List<KhinAudio>> fetchDataQS() async {
    final url = Uri.parse("https://quran-station.com/ar/sahaba?_rsc=ye9sh");
    final headers = {
      ..._commonHeaders,
      "Next-Url": "/ar/sahaba",
    };

    try {
      final response = await http.get(url, headers: headers)
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final sahabaData = _extractSahabaData(responseBody);
        
        if (sahabaData.isNotEmpty) {
          station.value = 0;
          return sahabaData.map((sData) {
            return KhinAudio(
              audioname: _getStringValue(sData, 'name', 'No Name'),
              audiolink: _getStringValue(sData, 'url', 'No URL'),
              duration: '0:00',
              id: _generateId(sData),
              albumImg: _getDefaultAlbumImage(),
            );
          }).toList();
        } else {
          throw QSScrapperException(
            'No sahaba stories found in the response',
            QSErrorType.dataNotFound
          );
        }
      } else {
        throw QSScrapperException(
          'Server returned status code: ${response.statusCode}',
          QSErrorType.serverError
        );
      }
    } on TimeoutException {
      throw QSScrapperException(
        'Request timeout after ${_requestTimeout.inSeconds} seconds. Please check your internet connection.',
        QSErrorType.timeoutError
      );
    } on SocketException catch (e) {
      if (e.message.contains('Failed host lookup')) {
        throw QSScrapperException(
          'Unable to connect to quran-station.com. Please check your internet connection.',
          QSErrorType.hostLookupFailed
        );
      } else {
        throw QSScrapperException(
          'Network error: ${e.message}',
          QSErrorType.networkError
        );
      }
    } on http.ClientException catch (e) {
      throw QSScrapperException(
        'Connection failed: ${e.message}',
        QSErrorType.networkError
      );
    } on FormatException catch (e) {
      throw QSScrapperException(
        'Invalid data format received from server: ${e.message}',
        QSErrorType.dataParsingError
      );
    } catch (e) {
      throw QSScrapperException(
        'Unexpected error occurred: $e',
        QSErrorType.dataParsingError
      );
    }
  }

  Future<List<KhinAudio>> fetchDataQSstations() async {
    final url = Uri.parse("https://quran-station.com/ar?_rsc=1q0rp");
    final headers = {
      ..._commonHeaders,
      "Next-Url": "/ar",
    };

    try {
      final response = await http.get(url, headers: headers)
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);

        final stationsData = _extractStationsData(responseBody);
        
        if (stationsData.isNotEmpty) {
          station.value = 1;
          return stationsData.map((sData) {
            return KhinAudio(
              audioname: _getStringValue(sData, 'name', 'No Name'),
              audioNameEx: _getStringValue(sData, 'name_en', 'No En Name'),
              audiolink: _getStringValue(sData, 'url', 'No URL'),
              duration: '0:00',
              id: _generateId(sData),
              albumImg: _getDefaultAlbumImage(),
              cat: _getStringValue(sData, 'category', ""),
              catEx: _getStringValue(sData, 'category_en', ""),
            );
          }).toList();
        } else {
          throw QSScrapperException(
            'No station data found in the response',
            QSErrorType.dataNotFound
          );
        }
      } else {
        throw QSScrapperException(
          'Server returned status code: ${response.statusCode}',
          QSErrorType.serverError
        );
      }
    } on TimeoutException {
      throw QSScrapperException(
        'Request timeout after ${_requestTimeout.inSeconds} seconds. Please check your internet connection.',
        QSErrorType.timeoutError
      );
    } on SocketException catch (e) {
      if (e.message.contains('Failed host lookup')) {
        throw QSScrapperException(
          'Unable to connect to quran-station.com. Please check your internet connection.',
          QSErrorType.hostLookupFailed
        );
      } else {
        throw QSScrapperException(
          'Network error: ${e.message}',
          QSErrorType.networkError
        );
      }
    } on http.ClientException catch (e) {
      throw QSScrapperException(
        'Connection failed: ${e.message}',
        QSErrorType.networkError
      );
    } on FormatException catch (e) {
      throw QSScrapperException(
        'Invalid data format received from server: ${e.message}',
        QSErrorType.dataParsingError
      );
    } catch (e) {
      throw QSScrapperException(
        'Unexpected error occurred: $e',
        QSErrorType.dataParsingError
      );
    }
  }

  List<dynamic> _extractSahabaData(String responseBody) {
    try {
      final startIndex = responseBody.indexOf('"sahabaStories":');
      if (startIndex == -1) {
        throw QSScrapperException(
          'sahabaStories section not found in server response',
          QSErrorType.dataNotFound
        );
      }
      final arrayStart = responseBody.indexOf('[', startIndex);
      if (arrayStart == -1) {
        throw QSScrapperException(
          'Invalid sahabaStories format - no opening bracket found',
          QSErrorType.dataParsingError
        );
      }

      int bracketCount = 0;
      int arrayEnd = arrayStart;
      
      for (int i = arrayStart; i < responseBody.length; i++) {
        if (responseBody[i] == '[') bracketCount++;
        if (responseBody[i] == ']') {
          bracketCount--;
          if (bracketCount == 0) {
            arrayEnd = i;
            break;
          }
        }
      }

      if (bracketCount != 0) {
        throw QSScrapperException(
          'Invalid sahabaStories format - malformed JSON array',
          QSErrorType.dataParsingError
        );
      }

      final storiesString = responseBody.substring(startIndex, arrayEnd + 1);
      final jsonString = '{$storiesString}';
      
      final Map<String, dynamic> data = json.decode(jsonString);
      return data['sahabaStories'] as List<dynamic>? ?? [];
      
    } catch (e) {
      if (e is QSScrapperException) rethrow;
      throw QSScrapperException(
        'Failed to extract sahaba data: $e',
        QSErrorType.dataParsingError
      );
    }
  }

  List<dynamic> _extractStationsData(String responseBody) {
    try {
      final startIndex = responseBody.indexOf('"stationsData":');
      if (startIndex == -1) {
        throw QSScrapperException(
          'stationsData section not found in server response',
          QSErrorType.dataNotFound
        );
      }

      final arrayStart = responseBody.indexOf('[', startIndex);
      if (arrayStart == -1) {
        throw QSScrapperException(
          'Invalid stationsData format - no opening bracket found',
          QSErrorType.dataParsingError
        );
      }

      int bracketCount = 0;
      int arrayEnd = arrayStart;
      
      for (int i = arrayStart; i < responseBody.length; i++) {
        if (responseBody[i] == '[') bracketCount++;
        if (responseBody[i] == ']') {
          bracketCount--;
          if (bracketCount == 0) {
            arrayEnd = i;
            break;
          }
        }
      }

      if (bracketCount != 0) {
        throw QSScrapperException(
          'Invalid stationsData format - malformed JSON array',
          QSErrorType.dataParsingError
        );
      }

      final storiesString = responseBody.substring(startIndex, arrayEnd + 1);
      final jsonString = '{$storiesString}';
      
      final Map<String, dynamic> data = json.decode(jsonString);
      return data['stationsData'] as List<dynamic>? ?? [];
      
    } catch (e) {
      if (e is QSScrapperException) rethrow;
      throw QSScrapperException(
        'Failed to extract stations data: $e',
        QSErrorType.dataParsingError
      );
    }
  }

  String _getStringValue(dynamic data, String key, String defaultValue) {
    try {
      if (data is Map<String, dynamic> && data.containsKey(key)) {
        final value = data[key];
        return value?.toString() ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  String _generateId(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final name = data['name']?.toString() ?? '';
        final id = data['id$name']?.toString();
        if (id != null && id.isNotEmpty) {
          return id;
        }
     
        return name.isNotEmpty ? name.hashCode.toString() : DateTime.now().millisecondsSinceEpoch.toString();
      }
      return DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  String _getDefaultAlbumImage() {
    return 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRztwKzgTguIrjpLNvqoCFXqpJBq9wmGq3M3cBZg82m8tfeMq35';
  }

  Future<List<KhinAudio>> fetchDataQSstationsWithRetry({int maxRetries = 3}) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await fetchDataQSstations();
      } on QSScrapperException catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }

        if (e.type == QSErrorType.dataParsingError || 
            e.type == QSErrorType.dataNotFound) {
          rethrow;
        }
        
        final delay = Duration(seconds: (1 << (attempts - 1)));
        await Future.delayed(delay);
      }
    }
    
    throw QSScrapperException(
      'Failed after $maxRetries attempts',
      QSErrorType.networkError
    );
  }

  Future<bool> isConnected() async {
    try {
      final result = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'User-Agent': 'connectivity-check'},
      ).timeout(Duration(seconds: 5));
      return result.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}