
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CinemaHomePage(),
    );
  }
}

class CinemaHomePage extends StatefulWidget {
  const CinemaHomePage({super.key});

  @override
  State<CinemaHomePage> createState() => _CinemaHomePageState();
}

class _CinemaHomePageState extends State<CinemaHomePage> {
  String? selectedFilePath;

  String selectedProfile = "Dolby Cinema";
  String selectedChannels = "Stereo";
  String selectedIntensity = "Medium";

  final profiles = ["Dolby Cinema", "Sony Clarity", "JBL Punch", "Bose Deep"];
  final channels = ["Stereo", "5.1", "7.1"];
  final intensities = ["Low", "Medium", "High"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cinema Audio")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text("Select Audio File"),
              onPressed: _pickAudioFile,
            ),

            if (selectedFilePath != null) ...[
              const SizedBox(height: 8),
              Text(
                selectedFilePath!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 24),

            _section("Cinema Profile"),
            _dropdown(profiles, selectedProfile, (v) {
              setState(() => selectedProfile = v);
            }),

            const SizedBox(height: 12),

            _section("Output Channels"),
            _dropdown(channels, selectedChannels, (v) {
              setState(() => selectedChannels = v);
            }),

            const SizedBox(height: 12),

            _section("Intensity"),
            _dropdown(intensities, selectedIntensity, (v) {
              setState(() => selectedIntensity = v);
            }),

            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.movie),
              label: const Text("Convert Audio"),
              onPressed: selectedFilePath == null ? null : _convertStub,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _dropdown(
    List<String> items,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => v != null ? onChanged(v) : null,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFilePath = result.files.single.path!;
      });
    }
  }

  void _convertStub() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Conversion Ready"),
        content: Text(
          "Input:\n$selectedFilePath\n\n"
          "Profile: $selectedProfile\n"
          "Channels: $selectedChannels\n"
          "Intensity: $selectedIntensity\n\n"
          "FFmpeg engine will be triggered next.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
