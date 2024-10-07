import 'package:flutter/services.dart';

class AudioFileService {
  static const platform = MethodChannel('com.example.playerflutter/audio');

  Future<List<Map<String, dynamic>>> getAudioFiles() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getAudioFiles');
      return List<Map<String, dynamic>>.from(result);
    } on PlatformException catch (e) {
      print("Failed to get audio files: '${e.message}'.");
      return [];
    }
  }

///old working method without images

  // Future<List<String>> getAudioFiles() async {
  //   try {
  //     final List<dynamic> audioFiles = await platform.invokeMethod('getAudioFiles');
  //     return audioFiles.cast<String>();
  //   } on PlatformException catch (e) {
  //     print("Failed to get audio files: '${e.message}'.");
  //     return [];
  //   }
  // }
}
