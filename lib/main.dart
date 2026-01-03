
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
      title: 'Cinema Audio',
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

  String profile = 'Dolby Cinema';
  String channels = 'Stereo';
  String intensity = 'Medium';

  Future<void> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = result.files.single.path!;
        status = 'Audio Selected';
      });
    }
  }

  void sendToEngine() {
    if (selectedFile == null) return;

    setState(() {
      status =
          'Ready → $profile | $channels | $intensity\n(Send to Termux next)';
    });

    // Termux bridge will be added later
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cinema Audio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

            const SizedBox(height: 25),

            ElevatedButton.icon(
              icon: const Icon(Icons.music_note),
              label: const Text('Pick Audio File'),
              onPressed: pickAudio,
            ),

            const SizedBox(height: 12),

            Text('Status: $status', textAlign: TextAlign.center),

            if (selectedFile != null) ...[
              const SizedBox(height: 8),
              Text(
                selectedFile!,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const Divider(height: 40),

            DropdownButtonFormField(
              value: profile,
              items: const [
                DropdownMenuItem(value: 'Dolby Cinema', child: Text('Dolby Cinema')),
                DropdownMenuItem(value: 'Sony Clarity', child: Text('Sony Clarity')),
                DropdownMenuItem(value: 'JBL Punch', child: Text('JBL Punch')),
                DropdownMenuItem(value: 'Bose Deep', child: Text('Bose Deep')),
              ],
              onChanged: (v) => setState(() => profile = v!),
              decoration: const InputDecoration(labelText: 'Cinema Profile'),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: channels,
              items: const [
                DropdownMenuItem(value: 'Stereo', child: Text('Stereo')),
                DropdownMenuItem(value: '5.1', child: Text('5.1 Surround')),
                DropdownMenuItem(value: '7.1', child: Text('7.1 Surround')),
              ],
              onChanged: (v) => setState(() => channels = v!),
              decoration: const InputDecoration(labelText: 'Output Channels'),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: intensity,
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'High', child: Text('High')),
              ],
              onChanged: (v) => setState(() => intensity = v!),
              decoration: const InputDecoration(labelText: 'Profile Intensity'),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: selectedFile == null ? null : sendToEngine,
              child: const Text('Send to Cinema Engine'),
            ),
          ],
        ),
      ),
    );
  }
}
