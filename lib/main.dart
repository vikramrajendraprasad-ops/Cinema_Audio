
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const AudioCinemaApp());
}

class AudioCinemaApp extends StatelessWidget {
  const AudioCinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audio Cinema Studio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CinemaHome(),
    );
  }
}

class CinemaHome extends StatefulWidget {
  const CinemaHome({super.key});

  @override
  State<CinemaHome> createState() => _CinemaHomeState();
}

class _CinemaHomeState extends State<CinemaHome> {
  String status = 'Idle';
  String? selectedFile;

  Future<void> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = result.files.single.path!;
        status = 'Audio Selected';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Cinema Studio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.deepPurple.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'This app uses an external FFmpeg engine via Termux.\nKeep Termux running in background.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.music_note),
              label: const Text('Pick Audio File'),
              onPressed: pickAudio,
            ),
            const SizedBox(height: 20),
            Text(
              'Status: $status',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (selectedFile != null) ...[
              const SizedBox(height: 10),
              Text(
                selectedFile!,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
