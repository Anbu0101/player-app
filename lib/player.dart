import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playerflutter/AudioPlayerPage.dart';
import 'package:sizer/sizer.dart';

import 'AudioService.dart';

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  List<Map<String, dynamic>> audioFiles = [];

  @override
  void initState() {
    super.initState();
    requestAudioPermission();  // First request for audio permission
  }

  // Function to request audio permission
  Future<void> requestAudioPermission() async {
    // Check and request audio permission
    PermissionStatus status = await Permission.audio.request();

    // Check if the permission was granted
    if (status.isGranted) {
      // Permission granted, fetch audio files
      fetchAudioFiles();
    } else if (status.isDenied) {
      // Permission denied, show a dialog or an info message
      showPermissionDeniedDialog();
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, navigate to app settings
      showPermissionPermanentlyDeniedDialog();
    }
  }

  void showPermissionPermanentlyDeniedDialog() {
    // Show a dialog informing the user that permission was permanently denied
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Permanently Denied'),
        content: Text('You need to enable audio permissions in the app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings(); // Open app settings to enable permission
            },
            child: Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );

  }

  // Function to fetch audio files
  Future<void> fetchAudioFiles() async {
    List<Map<String, dynamic>> files = await AudioFileService().getAudioFiles();
    setState(() {
      audioFiles = files;
      print("audiofiles ---");
      print(audioFiles.length);
      print(audioFiles);
    });
  }

  // Handle permission denied case
  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Denied"),
        content: Text("Audio file access permission is required to use this feature."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(186, 238, 219, 219),
      // extendBodyBehindAppBar: true,
      body: audioFiles.isEmpty
          ? Center(child: Text('No audio files found or permission not granted.'))
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.purple], // You can adjust these colors as needed
                ),
              ),
              child: ListView.builder(
                itemCount: audioFiles.length,
                itemBuilder: (context, index) {
                  final audioFile = audioFiles[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: const Color.fromARGB(255, 198, 235, 231).withOpacity(0.8),
                      child: ListTile(
                        leading: audioFile['thumbnailId'] != null
                            ? Image.memory(
                                audioFile['thumbnailId'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.music_note, size: 50),
                        title: Text(
                          audioFile['title'] ?? audioFile['path'].split('/').last,
                          style: TextStyle(fontSize: 17, color: Colors.purple),
                        ),
                        subtitle: Text(
                          audioFile['artist'] ?? 'Unknown Artist',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        onTap: () {
                          print("Selected audio file: ${audioFile['path']}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AudioPlayerPage(
                                audioFiles: audioFiles.map((file) => file['path'] as String).toList(),
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
