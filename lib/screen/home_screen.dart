import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace stackTrace) {
        debugPrint('A stream error occurred: $e');
      },
    );
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(
            'https://orangefreesounds.com/wp-content/uploads/2023/10/Calm-sea-sound-effect.mp3',
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  Widget _playerControlButton() {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final processingState = snapshot.data?.processingState;
        final playing = snapshot.data?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: 64.0,
            height: 64.0,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: 64.0,
            onPressed: _player.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.pause),
            iconSize: 64.0,
            onPressed: _player.pause,
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.replay),
            iconSize: 64.0,
            onPressed: () => _player.seek(const Duration(seconds: 0)),
          );
        }
      },
    );
  }

  Widget _playerProcessingBar() {
    return StreamBuilder<Duration?>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        return ProgressBar(
          progress: snapshot.data ?? Duration.zero,
          buffered: _player.bufferedPosition,
          total: _player.duration ?? Duration.zero,
          onSeek: (duration) => _player.seek(duration),
        );
      },
    );
  }

  Widget _controlButtons() {
    return Column(
      children: [
        StreamBuilder(
          stream: _player.speedStream,
          builder: (context, snapshot) {
            return Row(
              children: [
                Icon(Icons.speed),
                Slider(
                  min: 0.5,
                  max: 2.0,
                  divisions: 4,
                  value: snapshot.data ?? 1,
                  onChanged: (value) async {
                    await _player.setSpeed(value);
                  },
                ),
              ],
            );
          },
        ),
        SizedBox(height: 10,),
        StreamBuilder(
          stream: _player.volumeStream,
          builder: (context, snapshot) {
            return Row(
              children: [
                Icon(Icons.volume_up),
                Slider(
                  min: 0,
                  max: 2.0,
                  divisions: 4,
                  value: snapshot.data ?? 1,
                  onChanged: (value) async {
                    await _player.setVolume(value);
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Player")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _playerProcessingBar(),
              Row(children: [_playerControlButton(), _controlButtons()]),
            ],
          ),
        ),
      ),
    );
  }
}
