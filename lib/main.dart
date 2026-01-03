import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CinemaAudioApp());
}

class CinemaAudioApp extends StatelessWidget {
  const CinemaAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema Audio',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
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
  static const MethodChannel _channel = MethodChannel('cinema/termux');

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

  final List<String> intensityLevels = [
    'Low',
    'Medium',
    'High',
  ];

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

  Future<void> sendToEngine() async {
    if (selectedFile == null) return;

    setState(() {
      status = 'Processing...';
    });

    try {
      await _channel.invokeMethod('runEngine', {
        'input': selectedFile!,
        'profile': selectedProfile,
        'channels': selectedChannels,
        'intensity': selectedIntensity,
      });

      setState(() {
        status = 'Sent to Cinema Engine';
      });
    } catch (e) {
      setState(() {
        status = 'Engine Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema Audio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
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
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.music_note),
              label: const Text('Pick Audio File'),
              onPressed: pickAudio,
            ),

            const SizedBox(height: 16),
            Text(
              'Status: $status',
              textAlign: TextAlign.center,
            ),

            if (selectedFile != null) ...[
              const SizedBox(height: 8),
              Text(
                selectedFile!,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const Divider(height: 32),

            const Text('Cinema Profile'),
            DropdownButtonFormField<String>(
              value: selectedProfile,
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

            const SizedBox(height: 16),

            const Text('Output Channels'),
            DropdownButtonFormField<String>(
              value: selectedChannels,
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

            const SizedBox(height: 16),

            const Text('Profile Intensity'),
            DropdownButtonFormField<String>(
              value: selectedIntensity,
              items: intensityLevels
                  .map(
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(i),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedIntensity = v!),
            ),

            const SizedBox(height: 32),

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
