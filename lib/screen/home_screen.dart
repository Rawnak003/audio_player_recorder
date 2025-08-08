import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? recordingPath;

  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isRecording = false;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Player')),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (recordingPath != null)
            MaterialButton(
              onPressed: () async {
                if (audioPlayer.playing) {
                  audioPlayer.stop();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  await audioPlayer.setFilePath(recordingPath!);
                  await audioPlayer.play();
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              color: Colors.blue,
              child: Text(isPlaying ? 'Stop' : 'Play'),
            ),
          if (recordingPath == null) const Text('No Recording Found :('),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      child: Icon(isRecording ? Icons.stop : Icons.mic),
      onPressed: () async {
        if (isRecording) {
          String? path = await audioRecorder.stop();
          if (path != null) {
            setState(() {
              isRecording = false;
              recordingPath = path;
            });
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocumentaryDir =
                await getApplicationDocumentsDirectory();
            final String filePath = path.join(
              appDocumentaryDir.path,
              'recording.m4a',
            );
            await audioRecorder.start(path: filePath, const RecordConfig());
            setState(() {
              isRecording = true;
              recordingPath = null;
            });
          }
        }
      },
    );
  }
}
