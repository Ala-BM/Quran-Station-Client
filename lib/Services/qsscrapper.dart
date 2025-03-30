import 'dart:convert';
import 'package:flutter/material.dart';

import '../Classes/KhinsiderAlbums.dart';

import 'package:http/http.dart' as http;

class Qsscrapper {
 ValueNotifier<bool> station = ValueNotifier(true); 
  Future<List<KhinAudio>> fetchDataQS() async {
    final url = Uri.parse("https://quran-station.com/ar/sahaba?_rsc=ye9sh");
    final headers = {
      "Accept": "*/*",
      "RSC": "1",
      "Next-Url": "/ar/sahaba",
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Manually parse the response

        final responseBody = utf8.decode(response.bodyBytes);

        // Extract the relevant part of the response (e.g., the array of stories)
        final startIndex = responseBody.indexOf('"sahabaStories":');
        if (startIndex == -1) {
          throw Exception('sahabaStories not found in the response');
        }

        final endIndex = responseBody.indexOf(']', startIndex);
        if (endIndex == -1) {
          throw Exception('Invalid response format');
        }

        final storiesString = responseBody.substring(startIndex, endIndex + 1);

        // Convert the extracted string into a valid JSON array
        final jsonString = '{$storiesString}';
        final Map<String, dynamic> data = json.decode(jsonString);

        // Extract the stationData array
        final stationData = data['sahabaStories'] as List<dynamic>?;

        if (stationData != null) {
          // Convert the array into a list of maps for easy use
           station.value=false;
          return stationData.map((sData) {
            return KhinAudio(
              audioname: sData['name'] ?? 'No Name',
              audiolink: sData['url'] ?? 'No URL',
              duration: '0:00', // Default duration (you can update this based on the response)
              id: sData['id${sData['name']}'] ?? '0',
              albumImg: 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRztwKzgTguIrjpLNvqoCFXqpJBq9wmGq3M3cBZg82m8tfeMq35', // Default album image (you can update this based on the response)
            );
          }).toList();
         
        } else {
          throw Exception('No stationData found in the response');
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<List<KhinAudio>> fetchDataQSstations() async {
    final url = Uri.parse("https://quran-station.com/ar?_rsc=1q0rp");
    final headers = {
      "Accept": "*/*",
      "RSC": "1",
      "Next-Url": "/ar",
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Manually parse the response

        final responseBody = utf8.decode(response.bodyBytes);

        // Extract the relevant part of the response (e.g., the array of stories)
        final startIndex = responseBody.indexOf('"stationsData":');
        if (startIndex == -1) {
          throw Exception('stationsData not found in the response');
        }

        final endIndex = responseBody.indexOf(']', startIndex);
        if (endIndex == -1) {
          throw Exception('Invalid response format');
        }

        final storiesString = responseBody.substring(startIndex, endIndex + 1);

        // Convert the extracted string into a valid JSON array
        final jsonString = '{$storiesString}';
        final Map<String, dynamic> data = json.decode(jsonString);

        // Extract the stationData array
        final stationData = data['stationsData'] as List<dynamic>?;

        if (stationData != null) {
          // Convert the array into a list of maps for easy use
           station.value=true;
          return stationData.map((sData) {
            return KhinAudio(
              audioname: sData['name'] ?? 'No Name',
              audioNameEx:sData['name_en'] ?? 'No En Name',
              audiolink: sData['url'] ?? 'No URL',
              duration: '0:00', // Default duration (you can update this based on the response)
              id: sData['id${sData['name']}'] ?? '0',
              albumImg: 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRztwKzgTguIrjpLNvqoCFXqpJBq9wmGq3M3cBZg82m8tfeMq35',
              cat:sData['category'], // Default album image (you can update this based on the response)
              catEx:sData['category_en']
               // Default album image (you can update this based on the response)
            );
          }).toList();
        } else {
          throw Exception('No stationData found in the response');
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

}