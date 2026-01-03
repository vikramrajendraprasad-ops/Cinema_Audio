import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CinemaAudioApp());
}

/// MethodChannel for Android ↔ Flutter
const MethodChannel _channel = MethodChannel('cinema_audio/engine');

class CinemaAudioApp extends StatelessWidget {
  const CinemaAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema Audio',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  String selectedProfile = 'Sony Clarity';
  String selectedChannels = 'Stereo';
  String selectedIntensity = 'Medium';

  final List<String> profiles = [
    'Dolby Cinema',
    'Sony Clarity',
    'JBL Punch',
    'Bose Deep',
  ];

  final List<String> channels = [
    'Stereo',
    '5.1 Surround',
    '7.1 Surround',
  ];

  final List<String> intensities = [
    'Low',
    'Medium',
    'High',
  ];

  /// Pick audio file
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

  /// Send data to Android → Termux → FFmpeg
  Future<void> sendToEngine() async {
    if (selectedFile == null) {
      setState(() => status = 'No audio selected');
      return;
    }

    try {
      final response = await _channel.invokeMethod(
        'processAudio',
        {
          'inputPath': selectedFile,
          'profile': selectedProfile,
          'channels': selectedChannels,
          'intensity': selectedIntensity,
        },
      );

      setState(() {
        status = response ?? 'Processing started';
      });
    } catch (e) {
      setState(() {
        status = 'Engine error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema Audio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Info card
            Card(
              color: Colors.deepPurple.withOpacity(0.15),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'External FFmpeg engine via Termux\nKeep Termux running',
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Pick audio
            ElevatedButton.icon(
              icon: const Icon(Icons.music_note),
              label: const Text('Pick Audio File'),
              onPressed: pickAudio,
            ),

            const SizedBox(height: 20),

            /// Status
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

            const SizedBox(height: 30),
            const Divider(),

            /// Profile
            const Text('Cinema Profile'),
            DropdownButton<String>(
              value: selectedProfile,
              isExpanded: true,
              items: profiles
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedProfile = v!),
            ),

            const SizedBox(height: 20),

            /// Channels
            const Text('Output Channels'),
            DropdownButton<String>(
              value: selectedChannels,
              isExpanded: true,
              items: channels
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedChannels = v!),
            ),

            const SizedBox(height: 20),

            /// Intensity
            const Text('Profile Intensity'),
            DropdownButton<String>(
              value: selectedIntensity,
              isExpanded: true,
              items: intensities
                  .map(
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(i),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedIntensity = v!),
            ),

            const SizedBox(height: 30),

            /// Send button
            ElevatedButton(
              onPressed: sendToEngine,
              child: const Text('Send to Cinema Engine'),
            ),
          ],
        ),
      ),
    );
  }
}
