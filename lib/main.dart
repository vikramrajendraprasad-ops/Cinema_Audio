import 'package:flutter/material.dart';

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
  String selectedProfile = "Dolby Cinema";
  String selectedChannels = "Stereo";
  String selectedIntensity = "Medium";

  final List<String> profiles = [
    "Dolby Cinema",
    "Sony Clarity",
    "JBL Punch",
    "Bose Deep",
  ];

  final List<String> channels = [
    "Stereo",
    "5.1",
    "7.1",
  ];

  final List<String> intensities = [
    "Low",
    "Medium",
    "High",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cinema Audio"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle("Cinema Profile"),
            _dropdown(profiles, selectedProfile, (v) {
              setState(() => selectedProfile = v);
            }),

            const SizedBox(height: 16),

            _sectionTitle("Output Channels"),
            _dropdown(channels, selectedChannels, (v) {
              setState(() => selectedChannels = v);
            }),

            const SizedBox(height: 16),

            _sectionTitle("Intensity"),
            _dropdown(intensities, selectedIntensity, (v) {
              setState(() => selectedIntensity = v);
            }),

            const Spacer(),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.movie),
              label: const Text(
                "Convert Audio",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: _onConvertPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dropdown(
    List<String> items,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }

  void _onConvertPressed() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Conversion Stub"),
        content: Text(
          "Profile: $selectedProfile\n"
          "Channels: $selectedChannels\n"
          "Intensity: $selectedIntensity\n\n"
          "FFmpeg engine will be wired here.",
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
