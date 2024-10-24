import 'package:flutter/services.dart';

class AudioFileService {
  static const platform = MethodChannel('com.example.playerflutter/audio');

  Future<List<Map<String, dynamic>>> getAudioFiles() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getAudioFiles');
      return result.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        } else if (item is String) {
          return {'path': item};
        } else {
          throw FormatException('Unexpected item format: $item');
        }
      }).toList();
    } on PlatformException catch (e) {
      print("Failed to get audio files: '${e.message}'.");
      return [];
    }
  }
}
