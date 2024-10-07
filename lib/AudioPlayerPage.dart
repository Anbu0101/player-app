import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// ignore: must_be_immutable
class AudioPlayerPage extends StatefulWidget {
   List<String>? audioFiles;
   int? initialIndex;

  AudioPlayerPage({super.key, required this.audioFiles, required this.initialIndex});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
   AudioPlayer? _audioPlayer;
  int _currentIndex = 0;
  bool isPlaying = false;
   int? currentIndex;  // Add this line

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex!;
    currentIndex = widget.initialIndex ?? 0;  // Add this line
    _initAudioPlayer();
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer!.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _playNextAudio();
      }
    });
  }

  void _playNextAudio() {
    if (_currentIndex < widget.audioFiles!.length - 1) {
      setState(() {
        _currentIndex++;
        widget.initialIndex = _currentIndex;
      });
      playCurrentAudio();
    } else {
      // Optional: Loop back to the first track
      setState(() {
        _currentIndex = 0;
        widget.initialIndex = 0;
      });
      playCurrentAudio();
    }
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer!.setUrl(widget.audioFiles![_currentIndex]);
  }

  Future<void> playCurrentAudio() async {
    try {
      if (_audioPlayer!.audioSource?.sequence[0].tag != widget.audioFiles![_currentIndex]) {
        await _audioPlayer!.setUrl(widget.audioFiles![_currentIndex]);
      }
      await _audioPlayer!.play();
      print('Playing audio at index: $_currentIndex');
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

   void playNextAudio() {
                            if (widget.initialIndex! < widget.audioFiles!.length) {
                              // Stop the current audio if it's playing
                              _audioPlayer!.stop();
                              // Play the next audio file
                              _audioPlayer!.setFilePath(widget.audioFiles![widget.initialIndex!]);
                              _audioPlayer!.play();
                              setState(() {
                                isPlaying = true;
                              });
                            }
                          }

  Future<void> playPreviousAudio() async {
                            if (widget.initialIndex! >= 0 && widget.initialIndex! < widget.audioFiles!.length) {
                              String audioPath = widget.audioFiles![widget.initialIndex!];
                              await _audioPlayer!.stop();
                              await _audioPlayer!.setFilePath(audioPath);
                              await _audioPlayer!.play();
                              setState(() {
                                isPlaying = true;
                              });
                            }
                          }

  Future<void> pauseAudio() async {
    await _audioPlayer!.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer!.stop();
  }

  Future<void> seekToNext() async {
    if (_currentIndex < widget.audioFiles!.length - 1) {
      _currentIndex++;
      await playCurrentAudio();
    }
  }

  Future<void> seekToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await playCurrentAudio();
    }
  }

  void togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      // Start playing audio
      _audioPlayer!.play();
    } else {
      // Pause audio
      _audioPlayer!.pause();
    }
  }

  String _formatDuration(Duration duration) {
               String twoDigits(int n) => n.toString().padLeft(2, "0");
               String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
               String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
               return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
             }

  @override
  void dispose() {
    _audioPlayer!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.purple], // You can change these colors as needed
          ),
        ),

        child: Column(
          children: [
            SizedBox(height: 40), // Add some space at the top
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                widget.audioFiles![widget.initialIndex!].split('/').last,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            StreamBuilder<Duration>(
              stream: _audioPlayer!.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _audioPlayer!.duration ?? Duration.zero;
                final progress = duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0;
                
                return Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 120,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(child: SizedBox()),
             // Pushes the buttons to the bottom
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20.0),
               child: StreamBuilder<Duration>(
                 stream: _audioPlayer!.positionStream,
                 builder: (context, snapshot) {
                   final position = snapshot.data ?? Duration.zero;
                   final duration = _audioPlayer!.duration ?? Duration.zero;
                   return Column(
                     children: [
                       Slider(
                         value: position.inSeconds.toDouble(),
                         min: 0,
                         max: duration.inSeconds.toDouble(),
                         onChanged: (value) {
                           final newPosition = Duration(seconds: value.toInt());
                           _audioPlayer!.seek(newPosition);
                         },
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                             _formatDuration(position),
                             style: TextStyle(color: Colors.white),
                           ),
                           Text(
                             _formatDuration(duration),
                             style: TextStyle(color: Colors.white),
                           ),
                         ],
                       ),
                     ],
                   );
                 },
               ),
             ),

             
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous, color: Colors.white, size: 40),
                    onPressed: () {
                      setState(() {
                        // Assuming currentIndex is a property of the widget
                        if (widget.initialIndex! > 0) {
                          // Update the initialIndex in the parent widget
                          widget.initialIndex = widget.initialIndex! - 1;
                          // Play the previous audio
                          // currentIndex = widget.initialIndex!;
                          playPreviousAudio();
                          print('Playing previous audio at index: ${widget.initialIndex}');

                        
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 60,
                    ),
                    onPressed: togglePlayPause,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
                    onPressed: () {
                      setState(() {
                        if (widget.initialIndex! < widget.audioFiles!.length - 1) {
                          // Update the initialIndex in the parent widget
                          widget.initialIndex = widget.initialIndex! + 1;
                          // currentIndex = widget.initialIndex!;
                          // Play the next audio
                          playNextAudio();
                          print('Playing next audio at index: ${widget.initialIndex}');

                         
                        }
                      });
                      // setState(() {
                      //   if (widget.initialIndex! < widget.audioFiles!.length - 1) {
                      //     // Update the initialIndex in the parent widget
                      //     widget.initialIndex = widget.initialIndex! + 1;
                      //     // Play the current audio
                      //     playCurrentAudio();
                      //     print('Playing audio at index: ${widget.initialIndex}');
                      //   }
                      // });
                    },
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}